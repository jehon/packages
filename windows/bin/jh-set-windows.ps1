
. $PSScriptRoot\..\lib\screens.ps1

Move-Window-To-Screen -Name "firefox"    -Screen $secondary -Maximize
Move-Window-To-Screen -Name "MobaXterm"  -Screen $secondary -Maximize
Move-Window-To-Screen -Name "OUTLOOK"    -Screen $secondary -Maximize
Move-Window-To-Screen -Name "Teams"      -Screen $secondary -Maximize

Move-Window-To-Screen -Name "Code"       -Screen $primary -Maximize
Move-Window-To-Screen -Name "PowerPoint" -Screen $primary
Move-Window-To-Screen -Name "Word"       -Screen $primary
Move-Window-To-Screen -Name "Excel"      -Screen $primary
