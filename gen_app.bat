@REM  @license
@REM  Author: Paa ( paa.code.me@gmail.com )
@REM  Copyright: (c) 2023.

@ECHO OFF

:: Intro
ECHO.
ECHO     ............................................................
ECHO     Genar - v1.2.0
ECHO     License: MIT (c) 2023 Paa ( paa.code.me@gmail.com )
ECHO     ............................................................
ECHO.
ECHO     APP GENERATION INSTRUCTIONS ::
ECHO     ------------------------------
ECHO     1. FIRST build will require internet access to patch/update
ECHO        some build values.
ECHO        Patch/update can cost ~1.7G internet data.
ECHO        Be sure you are connected to a network before starting.
ECHO.
ECHO     2. General speed of all build processes is highly dependent
ECHO        on your processor's speed and RAM size.
ECHO        Expect slower builds on a low spec'd computer.
ECHO.
ECHO     3. Build will be stored in the `output` folder in the root
ECHO        directory of this `gen_app.bat` program when successfully
ECHO        complete.
ECHO.
ECHO     ............................................................
ECHO.
SET /p UserInput=.   All Set To Continue? ENTER 1 [Yes] OR Any Key [No] 
IF NOT "%UserInput%"=="1" ECHO. & SET status_message=You Can Re-run Anytime. & CALL :show_message & EXIT /b 0
ECHO. & ECHO     Starting App Generation Process.. & ECHO.

:: Project globals
SET project_root=%~dp0
SET status_message=

:: Get latest environment variables
CALL res_env_var.bat

:: 1. Check for all commands
ECHO     Checking For Essential Commands..
WHERE flutter >NUL 2>&1 & IF %errorlevel% GTR 0 SET status_message=Flutter SDK Not Found. & CALL :show_message & EXIT /b 0
WHERE java >NUL 2>&1 & IF %errorlevel% GTR 0 SET status_message=Java JDK Not Found. & CALL :show_message & EXIT /b 0
WHERE gradle >NUL 2>&1 & IF %errorlevel% GTR 0 SET status_message=Gradle Not Found. & CALL :show_message & EXIT /b 0
WHERE sdkmanager >NUL 2>&1 & IF %errorlevel% GTR 0 SET status_message=Android SDK Not Found. & CALL :show_message & EXIT /b 0
ECHO     Essential Commands.. All Set! & ECHO.

:: 2. Check for `gen_config.json` file & `gen_assets` folder
ECHO     Checking For Essential Files And Folders..
IF NOT EXIST gen_config.json SET status_message=Missing `gen_config.json`. & CALL :show_message & EXIT /b 0
IF NOT EXIST gen_assets\ SET status_message=Missing `gen_assets` Directory. & CALL :show_message & EXIT /b 0
IF NOT EXIST base_app\assets SET status_message=BaseApp Setup Incomplete. & CALL :show_message & EXIT /b 0
ECHO     Essentials.. All Set! & ECHO.

:: 4. Run files sync of `gen_assets` + `base_app/assets/build/`
ECHO     Updating `base_app/assets/build/` with `gen_assets`..
CALL java jar_helpers/FileUtil -s_assets
IF %errorlevel% GTR 0 SET status_message=Update Failed. & CALL :show_message & EXIT /b 0
ECHO.

:: 5. Run sync of `gen_config.json` + `base_app/assets/raw/config.json`
ECHO     Synchronizing `base_app/assets/raw/config.json` with `gen_config.json`..
CALL java jar_helpers/FileUtil -s_config
IF %errorlevel% GTR 0 SET status_message=Sync Failed. & CALL :show_message & EXIT /b 0
ECHO.

:: 6. Generate app_icons with RUN `flutter pub run flutter_launcher_icons`
CD %project_root%base_app
CALL flutter pub run flutter_launcher_icons
IF %errorlevel% GTR 0 CD %project_root% & SET status_message=Unable To Generate AppIcons. & CALL :show_message & EXIT /b 0

:: 7. `Run flutter build apk`
CALL flutter build apk
IF %errorlevel% GTR 0 CD %project_root% & SET status_message=Unable To Build Application. & CALL :show_message & EXIT /b 0
CD %project_root%

:: 8. Move .apk from `base_app/build/app/outputs/flutter-apk/` to `output`
IF EXIST output\ ( RD /s /q output\ & MD output ) ELSE ( MD output )
CALL java jar_helpers/FileUtil -m_output
IF %errorlevel% GTR 0 SET status_message=Unable To Move Build Output. & CALL :show_message & EXIT /b 0

:: 9. All done
SET status_message=App Build Successful!@@@@APK Can Be Found In `%project_root%output` Folder.
POWERSHELL -ExecutionPolicy Bypass -File "sho_sta_msg.ps1" -title "Genar ~ Generate" -message "%status_message%" -action "Ok" -icon "Info"
ECHO.
ECHO     ............................................................
ECHO     App Build Successful.
ECHO     APK Can Be Found In `%project_root%output` Folder. 
EXIT /b 0

:: Alert message function
:show_message
POWERSHELL -ExecutionPolicy Bypass -File "sho_sta_msg.ps1" -title "Genar ~ Generate" -message "App Build Failed!@@@@%status_message%" -action "Ok" -icon "Error"
