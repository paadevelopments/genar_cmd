@REM  @license
@REM  Author: Paa ( paa.code.me@gmail.com )
@REM  Copyright: (c) 2023.

@ECHO OFF

SET arg1=%1
SET arg2=%2
CD %arg1%
DIR /a:d /b > file_temp~.txt
SET /p dyn_file_found=<file_temp~.txt
ECHO %dyn_file_found%
DEL file_temp~.txt
CD %arg2%