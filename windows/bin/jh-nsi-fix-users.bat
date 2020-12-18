@echo off

echo "Starting..."

RD /S /Q "%WinDir%\System32\GroupPolicyUsers"

RD /S /Q "%WinDir%\System32\GroupPolicy"

gpupdate /force

@echo off
pause

REM must be at C:\ to work !
REM how bizarre