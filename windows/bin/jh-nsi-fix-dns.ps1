
#Requires -RunAsAdministrator

$reg = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient\DnsPolicyConfig'

Get-ChildItem -Path $reg | ForEach-Object { Remove-Item $_.pspath }

Restart-Service DNSCache -force
