
. $PSScriptRoot\..\lib\screens.ps1

Move-Window-To-Screen -Name "Teams"      -Screen $secondary -Maximize
Move-Window-To-Screen -Name "chrome"     -Screen $secondary -Maximize

Move-Window-To-Screen -Name "Excel"      -Screen $secondary
Move-Window-To-Screen -Name "Word"       -Screen $secondary
Move-Window-To-Screen -Name "PowerPoint" -Screen $secondary

Move-Window-To-Screen -Name "firefox"    -Screen $secondary -Maximize
Move-Window-To-Screen -Name "Code"       -Screen $secondary -Maximize
