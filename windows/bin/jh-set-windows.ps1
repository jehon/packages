. $PSScriptRoot\..\lib\set-window.ps1
. $PSScriptRoot\..\lib\get-screen.ps1

# Screens
$primary = My-Get-Screen -Primary
$secondary = My-Get-Screen -Secondary

My-Set-Screen-For -Name "firefox"    -Screen $secondary
My-Set-Screen-For -Name "OUTLOOK"    -Screen $secondary
My-Set-Screen-For -Name "Teams"      -Screen $secondary

My-Set-Screen-For -Name "Code"       -Screen $primary 
My-Set-Screen-For -Name "PowerPoint" -Screen $primary -Maximize $FALSE
My-Set-Screen-For -Name "Word"       -Screen $primary -Maximize $FALSE
My-Set-Screen-For -Name "Excel"      -Screen $primary -Maximize $FALSE      
