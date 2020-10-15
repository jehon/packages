@echo off

IF "%~1" == "" goto error
goto ok

:error
echo Please specify the port
goto eof

:ok
echo Killing port %~1: 
FOR /F "tokens=5 delims= " %%P IN ('netstat -a -n -o ^| findstr "LISTENING" ^| findstr 0.0.0.0:%~1') DO (
	if %%P == 0 goto done 
	echo "Killing %%P for %~1"
	TaskKill.exe /F /PID %%P
	:done
	echo .
)

:eof
exit /b 0
