 
Get-Process | where {$_.mainWindowTItle} | format-table id,name,mainwindowtitle –AutoSize

