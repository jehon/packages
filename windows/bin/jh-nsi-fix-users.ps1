
#Requires -RunAsAdministrator

# must be at C:\ to work !  how bizarre

Write-Output "Starting..."

if (Test-Path "%WinDir%\System32\GroupPolicyUsers") {
    Write-Output "Deleting GroupPolicyUsers"
    Remove-Item -Recurse -Force "%WinDir%\System32\GroupPolicyUsers"
}

if (Test-Path "%WinDir%\System32\GroupPolicy") {
    Write-Output "Deleting GroupPolicy"
    Remove-Item -Recurse -Force "%WinDir%\System32\GroupPolicy"
}

Write-Output "GP Update..."
gpupdate /force

Write-Output "...done"

pause
