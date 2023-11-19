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
ECHO     SETUP INSTRUCTIONS ::
ECHO     ---------------------
ECHO     1. Make sure you have `DEVELOPER_MODE` turned on before
ECHO        proceeding with this process.
ECHO        From your TaskBar, search `Developer Settings`. Open it
ECHO        to see the `DEVELOPER_MODE` option and turn it ON.
ECHO.
ECHO     2. This setup process will download large sized files ~1.5G
ECHO        including `flutter_3.10.1`, `java_17`, `gradle_8.1.1` and
ECHO        `android-command-line-tools`.
ECHO        Be sure your internet connection is fast before starting.
ECHO.
ECHO     3. While running, READ and ACCEPT all prompts during license
ECHO        preview.
ECHO.
ECHO     4. By running this software, you affirm your acceptance of 
ECHO        the terms specified in its `LICENSE` file.
ECHO.
ECHO     ............................................................
ECHO.
SET /p UserInput=.   All Set To Continue? ENTER 1 [Yes] OR Any Key [No] 
IF NOT "%UserInput%"=="1" ECHO. & SET status_message=Oh No! Well, You Can Re-run Anytime. & CALL :show_message & EXIT /b 0
ECHO. & ECHO     In The Beginning.. & ECHO.

:: Project globals
SET project_root=%~dp0
SET status_message=

:: Get latest environment variables
CALL res_env_var.bat

:: FLUTTER
:flutter
SET sdk_folder=flutter
SET sdk_file=flutter_windows_3.10.1-stable.zip
SET sdk_source=https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.10.1-stable.zip
SET sdk_env_var=%sdk_folder%\flutter\bin
:: Check for command
WHERE flutter >NUL 2>&1 && ( ECHO     Detected Existing Flutter SDK. & GOTO java )
:: Check for folder
IF EXIST %sdk_folder%\ (
    :: Check for bin path
    IF EXIST %sdk_env_var% (
        :: CD to path and test command
        CD %sdk_env_var% & WHERE flutter >NUL 2>&1 && ( CD %project_root% & GOTO flutter_set_path )
    )
) ELSE (
    MD %sdk_folder% & GOTO flutter_download
)
:: Check for zip and clear if not found
IF EXIST %sdk_folder%\%sdk_file% ( GOTO flutter_unzip ) ELSE ( RD /s /q %sdk_folder%\ & MD %sdk_folder%  )
:: Download SDK
:flutter_download
ECHO     Downloading Flutter SDK..
POWERSHELL -command "Start-BitsTransfer -Source %sdk_source% -Destination %sdk_folder%/%sdk_file%"
IF %errorlevel% GTR 0 SET status_message=Unable To Download Flutter SDK. & CALL :show_message & EXIT /b 0
:: Unzip SDK
:flutter_unzip
ECHO     Unzipping Flutter SDK..
POWERSHELL -command "Expand-Archive %sdk_folder%/%sdk_file% %sdk_folder%"
IF %errorlevel% GTR 0 SET status_message=Unable To Unzip Flutter SDK. & CALL :show_message & EXIT /b 0
DEL %sdk_folder%\%sdk_file%
ECHO     Successfully Unzipped Flutter SDK.
:: Set environment variable
:flutter_set_path
POWERSHELL -ExecutionPolicy Bypass -File "set_env_var.ps1" -newPath "%project_root%%sdk_env_var%"
IF %errorlevel% GTR 0 SET status_message=Unable To Set PATH Variable. & CALL :show_message & EXIT /b 0
ECHO     Flutter SDK Setup Successful.
:: Get latest environment variables
CALL res_env_var.bat

:: JAVA
:java
SET sdk_folder=java
SET sdk_file=jdk-17_windows-x64_bin.zip
SET sdk_source=https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.zip
SET sdk_env_var=%sdk_folder%\jdk-17.0.7\bin
SET sdk_jar_sub=%sdk_folder%\jdk-17.0.7
:: Check for commands
WHERE java >NUL 2>&1 && ( ECHO     Detected Existing Java JDK. & GOTO gradle )
:: Check for folder
IF EXIST %sdk_folder%\ (
    :: Check for bin path
    IF EXIST %sdk_env_var% (
        :: CD to path and test command
        CD %sdk_env_var% & WHERE java >NUL 2>&1 && ( CD %project_root% & GOTO java_set_path )
    )
) ELSE (
    MD %sdk_folder% & GOTO java_download
)
:: Check for zip and clear if not found
IF EXIST %sdk_folder%\%sdk_file% ( GOTO java_unzip ) ELSE ( RD /s /q %sdk_folder%\ & MD %sdk_folder%  )
:: Download SDK
:java_download
ECHO     Downloading Java JDK..
POWERSHELL -command "Start-BitsTransfer -Source %sdk_source% -Destination %sdk_folder%/%sdk_file%"
IF %errorlevel% GTR 0 SET status_message=Unable To Download Java JDK. & CALL :show_message & EXIT /b 0
:: Unzip JDK
:java_unzip
ECHO     Unzipping Java JDK..
POWERSHELL -command "Expand-Archive %sdk_folder%/%sdk_file% %sdk_folder%"
IF %errorlevel% GTR 0 SET status_message=Unable To Unzip Java JDK. & CALL :show_message & EXIT /b 0
DEL %sdk_folder%\%sdk_file%
ECHO     Successfully Unzipped Java JDK.
:: Get dynamic versioned jdk file for path
CALL dyn_fil_nme.bat %sdk_folder% ../
:: Build dynamic PATH
SET sdk_env_var=%sdk_folder%\%dyn_file_found%\bin
SET sdk_jar_sub=%sdk_folder%\%dyn_file_found%
:: Set environment variable
:java_set_path
SETX JAVA_HOME "%project_root%%sdk_jar_sub%"
POWERSHELL -ExecutionPolicy Bypass -File "set_env_var.ps1" -newPath "%project_root%%sdk_env_var%"
IF %errorlevel% GTR 0 SET status_message=Unable To Set PATH Variable. & CALL :show_message & EXIT /b 0
ECHO     Java JDK Setup Successful.
:: Get latest environment variables
CALL res_env_var.bat

:: GRADLE
:gradle
SET sdk_folder=gradle
SET sdk_file=gradle-8.1.1-all.zip
SET sdk_source=https://services.gradle.org/distributions/gradle-8.1.1-all.zip
SET sdk_env_var=%sdk_folder%\gradle-8.1.1\bin
:: Check for commands
WHERE gradle >NUL 2>&1 && ( ECHO     Detected Existing Gradle SDK. & GOTO android )
:: Check for folder
IF EXIST %sdk_folder%\ (
    :: Check for bin path
    IF EXIST %sdk_env_var% (
        :: CD to path and test command
        CD %sdk_env_var% & WHERE gradle >NUL 2>&1 && ( CD %project_root% & GOTO gradle_set_path )
    )
) ELSE (
    MD %sdk_folder% & GOTO gradle_download
)
:: Check for zip and clear if not found
IF EXIST %sdk_folder%\%sdk_file% ( GOTO gradle_unzip ) ELSE ( RD /s /q %sdk_folder%\ & MD %sdk_folder%  )
:: Download SDK
:gradle_download
ECHO     Downloading Gradle SDK..
POWERSHELL -command "Start-BitsTransfer -Source %sdk_source% -Destination %sdk_folder%/%sdk_file%"
IF %errorlevel% GTR 0 SET status_message=Unable To Download Gradle SDK. & CALL :show_message & EXIT /b 0
:: Unzip SDK
:gradle_unzip
ECHO     Unzipping Gradle SDK..
POWERSHELL -command "Expand-Archive %sdk_folder%/%sdk_file% %sdk_folder%"
IF %errorlevel% GTR 0 SET status_message=Unable To Unzip Gradle SDK. & CALL :show_message & EXIT /b 0
DEL %sdk_folder%\%sdk_file%
ECHO     Successfully Unzipped Gradle SDK.
:: Set environment variable
:gradle_set_path
POWERSHELL -ExecutionPolicy Bypass -File "set_env_var.ps1" -newPath "%project_root%%sdk_env_var%"
IF %errorlevel% GTR 0 SET status_message=Unable To Set PATH Variable. & CALL :show_message & EXIT /b 0
ECHO     Gradle SDK Setup Successful.
:: Get latest environment variables
CALL res_env_var.bat


:: ANDROID
:android
SET sdk_folder=android
SET sdk_file=commandlinetools-win-9477386_latest.zip
SET sdk_source=https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip
SET sdk_env_var=%sdk_folder%\cmdline-tools\latest\bin
:: Check for commands
WHERE sdkmanager >NUL 2>&1 && ( ECHO     Detected Existing Command-Line-Tool. & GOTO project )
:: Check for folder
IF EXIST %sdk_folder%\ (
    :: Check for bin path
    IF EXIST %sdk_env_var% (
        :: CD to path and test command
        CD %sdk_env_var% & WHERE sdkmanager >NUL 2>&1 && ( CD %project_root% & GOTO android_set_path )
    )
) ELSE (
    MD %sdk_folder% & GOTO android_download
)
:: Check for zip and clear if not found
IF EXIST %sdk_folder%\%sdk_file% ( GOTO android_unzip ) ELSE ( RD /s /q %sdk_folder%\ & MD %sdk_folder%  )
:: Download SDK
:android_download
ECHO     Downloading Command-Line-Tool..
POWERSHELL -command "Start-BitsTransfer -Source %sdk_source% -Destination %sdk_folder%/%sdk_file%"
IF %errorlevel% GTR 0 SET status_message=Unable To Download Command-Line-Tool. & CALL :show_message & EXIT /b 0
:: Unzip SDK
:android_unzip
ECHO     Unzipping Command-Line-Tool..
POWERSHELL -command "Expand-Archive %sdk_folder%/%sdk_file% %sdk_folder%"
IF %errorlevel% GTR 0 SET status_message=Unable To Unzip Command-Line-Tool. & CALL :show_message & EXIT /b 0
DEL %sdk_folder%\%sdk_file%
ECHO     Successfully Unzipped Command-Line-Tool.
:: Download platform & android tools
CD %project_root%%sdk_folder%\cmdline-tools\bin
:: Add `cmdline-tools;latest`
CALL sdkmanager.bat "cmdline-tools;latest" --sdk_root=%project_root%%sdk_folder%
IF %errorlevel% GTR 0 CD %project_root% & SET status_message=`cmdline-tools;latest` Download Failed. & CALL :show_message & EXIT /b 0
CALL sdkmanager.bat "platforms;android-33" --sdk_root=%project_root%%sdk_folder%
IF %errorlevel% GTR 0 CD %project_root% & SET status_message=`platforms;android-33` Download Failed. & CALL :show_message & EXIT /b 0
CALL sdkmanager.bat "build-tools;33.0.2" --sdk_root=%project_root%%sdk_folder%
IF %errorlevel% GTR 0 CD %project_root% & SET status_message=`build-tools;33.0.2` Download Failed. & CALL :show_message & EXIT /b 0
CD %project_root%
ECHO     Finishing Up Android SDK Setup..
:: Set environment variable(s)
:android_set_path
SETX ANDROID_SDK_ROOT "%project_root%%sdk_folder%"
POWERSHELL -ExecutionPolicy Bypass -File "set_env_var.ps1" -newPath "%project_root%%sdk_folder%\cmdline-tools\latest\bin"
IF %errorlevel% GTR 0 SET status_message=Unable To Set PATH Variable. & CALL :show_message & EXIT /b 0
POWERSHELL -ExecutionPolicy Bypass -File "set_env_var.ps1" -newPath "%project_root%%sdk_folder%\tools"
IF %errorlevel% GTR 0 SET status_message=Unable To Set PATH Variable. & CALL :show_message & EXIT /b 0
POWERSHELL -ExecutionPolicy Bypass -File "set_env_var.ps1" -newPath "%project_root%%sdk_folder%\platform-tools"
IF %errorlevel% GTR 0 SET status_message=Unable To Set PATH Variable. & CALL :show_message & EXIT /b 0
ECHO     Android SDK Setup Successful.
:: Get latest environment variables
CALL res_env_var.bat


:: PRE-PROJECT
CALL flutter config --android-sdk %project_root%%sdk_folder%
IF %errorlevel% GTR 0 SET status_message=Unable To Set Android SDK For Flutter Config. & CALL :show_message & EXIT /b 0
:: Accept all licences
CALL flutter doctor --android-licenses
IF %errorlevel% GTR 0 SET status_message=Failed To Accept All Licenses. & CALL :show_message & EXIT /b 0


:: PROJECT
:project
SET prj_folder=base_app
ECHO. & ECHO     Starting Build Project Setup.. & ECHO     Checking For Existing Project..
IF NOT EXIST %prj_folder%\ MD %prj_folder% & GOTO project_create
:: Prompt user for conflict action
:project_conflict
ECHO. & SET /p override_prj=.    An Existing Project Found. Override? ENTER 1 [Yes] OR Any Key [No]  
IF NOT "%override_prj%"=="1" GOTO all_done
:: Clean existing project
ECHO     Cleaning Previous Project..
RD /s /q %prj_folder%\ & MD %prj_folder%
:: Create project
:project_create
ECHO     Creating New Project..
CALL flutter create %prj_folder%
IF %errorlevel% GTR 0 SET status_message=Setup Complete But Unable To Create Base Project. & CALL :show_message & EXIT /b 0
:: CD Into project
CD %project_root%%prj_folder%
CALL flutter pub add permission_handler url_launcher path_provider flutter_launcher_icons shared_preferences flutter_inappwebview
IF %errorlevel% GTR 0 CD %project_root% & SET status_message=Setup Complete But Unable To Complete Base Project Setup. & CALL :show_message & EXIT /b 0
CD %project_root%
:: Run { jar_helpers/FileUtil -d } to setup default mergers. 
CALL java jar_helpers/FileUtil -d
IF %errorlevel% GTR 0 SET status_message=Setup Complete But Unable To Cleanup. & CALL :show_message & EXIT /b 0


:: ALL SUCCESS
:all_done
SET status_message=Setup Successful!@@@@Edit `gen_config.json` To Your Prefered Options And run `gen_app.exe` To Generate Your App.@@For more info, check `readme.txt`.
POWERSHELL -ExecutionPolicy Bypass -File "sho_sta_msg.ps1" -title "Genar ~ Setup" -message "%status_message%" -action "Ok" -icon "Info"
ECHO.
ECHO     ............................................................
ECHO     Genar Setup Successful.
ECHO     Edit `gen_config.json` To Your Prefered Options And run `gen_app.exe` To Generate Your App.
ECHO     For more info, check `readme.txt`.
EXIT /b 0

:: Alert message function
:show_message
POWERSHELL -ExecutionPolicy Bypass -File "sho_sta_msg.ps1" -title "Genar ~ Setup" -message "Setup Failed!@@@@%status_message%" -action "Ok" -icon "Error"
