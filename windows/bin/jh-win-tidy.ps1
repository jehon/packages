
# must be at C:\ to work !  how bizarre

. $PSScriptRoot\..\lib\require-admin.ps1

if (Enter-Admin) {
    # As Normal user

    

    Write-Output "This script is restated as admin"
} else {
    # As Admin

    Write-Output "Updating..."
    choco update all
}

Write-Output "...done"
pause
