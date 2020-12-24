
Function Enter-Admin {
    Begin {
        if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            return $False
        }

        $call = (Get-PSCallStack) | Select-Object -Last 1 -Skip 1

        # Write-Output $call
        # Write-Output $call.ScriptName
        # Write-Output $call.Arguments

        $command = @( $call.ScriptName )
        # $command += $call.Arguments

        Write-Output "This script needs to be run as admin : " $command

        Start-Process powershell.exe -Verb runAs -ArgumentList $command
        # -Wait

        # TODO: how to exit called script
        return $True
    }
}