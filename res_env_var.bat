@REM Solution from: https://stackoverflow.com/questions/171588/is-there-a-command-to-refresh-environment-variables-from-the-command-prompt-in-w

@ECHO OFF
%~dp0res_env_var.vbs
CALL "%TEMP%\res_env_var.bat"
