. $PSScriptRoot\..\lib\set-window.ps1
. $PSScriptRoot\..\lib\get-screen.ps1

# Set state of the window:
#   See https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow

# Screens
$primary = My-Get-Screen -Primary
$secondary = My-Get-Screen -Secondary

My-Set-Screen-For -Name "Teams"      -Screen $secondary 
My-Set-Screen-For -Name "chrome"     -Screen $secondary

My-Set-Screen-For -Name "Excel"      -Screen $secondary -Maximize $FALSE
My-Set-Screen-For -Name "Word"       -Screen $secondary -Maximize $FALSE
My-Set-Screen-For -Name "PowerPoint" -Screen $secondary -Maximize $FALSE

My-Set-Screen-For -Name "firefox"    -Screen $secondary 
My-Set-Screen-For -Name "Code"       -Screen $secondary 
