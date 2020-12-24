
. $PSScriptRoot\..\lib\require-admin.ps1

if (Enter-Admin) {
    Write-Output "This script is restated as admin"
    Exit 0
}

$reg = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient\DnsPolicyConfig'

Get-ChildItem -Path $reg | ForEach-Object { Remove-Item $_.pspath }

Restart-Service DNSCache -force
