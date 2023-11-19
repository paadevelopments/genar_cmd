# @license
# Author: Paa ( paa.code.me@gmail.com )
# Copyright: (c) 2023.

param (
    [Parameter(Mandatory=$true)][string]$title,
    [Parameter(Mandatory=$true)][string]$message,
    [Parameter(Mandatory=$true)][string]$action,
    [Parameter(Mandatory=$true)][string]$icon
)
$a = $message -split "@@"
$b = ""
foreach ($aa in $a) { $b += $aa + "`n" }
Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show($b,$title,$action,$icon)
