
Function My-Get-Screen {

    <#
        .SYNOPSIS
            Get infos about the screens

        .DESCRIPTION
            Return the size of the screen

        .PARAMETER Primary
            Wether it is a primary screen or not

        .PARAMETER Secondary
            Wether it is a secondary screen or not

        .OUTPUT
            System.Drawing.Rectangle

    #>
    
    [OutputType('System.Windows.Forms')]
    [cmdletbinding()]
    Param (
        [switch]$Primary,
        [switch]$Secondary
    )
    Begin {
        Add-Type -AssemblyName System.Windows.Forms
    }
    Process {
        # https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.screen.workingarea?view=netcore-3.1#System_Windows_Forms_Screen_WorkingArea

        $selected_list = [System.Windows.Forms.Screen]::AllScreens | sort -Property {$_.WorkingArea.X}
        If ($PSBoundParameters.ContainsKey('Primary')) {
            $selected_list = $selected_list | Where Primary
        } 

        If ($PSBoundParameters.ContainsKey('Secondary')) {
            $selected_list = $selected_list | Where-Object  { ! $_.Primary }
        }

        # $selected_list = selected_list | select -First $ScreenId

        # Only take a screen
        $selected = $selected_list | select -First 1

        return $selected
        
    }
}
