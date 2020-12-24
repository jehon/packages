
# must be at C:\ to work !  how bizarre

. $PSScriptRoot\..\lib\require-admin.ps1

if (Enter-Admin) {
    Write-Output "This script is restated as admin"
    Exit 0
}

Write-Output "Starting..."

if (Test-Path "$env:windir\System32\GroupPolicyUsers") {
    Write-Output "Deleting GroupPolicyUsers"
    Remove-Item -Recurse -Force "$env:windir\System32\GroupPolicyUsers"
}

if (Test-Path "$env:windir\System32\GroupPolicy") {
    Write-Output "Deleting GroupPolicy"
    Remove-Item -Recurse -Force "$env:windir\System32\GroupPolicy"
}

Write-Output "GP Update..."
gpupdate /force

Write-Output "...done"

pause
