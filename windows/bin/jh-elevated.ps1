
Start-Process powershell.exe -Verb runAs -ArgumentList '-NoExit', '-Command', 'cd C:\Users\jho'

echo "Look for the elevated command"

exit 0