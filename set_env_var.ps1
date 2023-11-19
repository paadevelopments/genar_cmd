# @license
# Author: Paa ( paa.code.me@gmail.com )
# Copyright: (c) 2023.

param ([Parameter(Mandatory=$true)][string]$newPath)
$oldPath = [Environment]::GetEnvironmentVariable('PATH', 'User');
[Environment]::SetEnvironmentVariable('PATH', "$newPath;$oldPath",'User');
write-output "Environment Variable { $newPath } Set Successfully."
