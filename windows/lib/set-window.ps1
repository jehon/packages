# Thanks to 

# Set state of the window:
#   See https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow

Add-Type -name NativeMethods -namespace Win32 `
    -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' `

Function My-Set-Window {
    <#
        .SYNOPSIS
            Sets the window size (height,width) and coordinates (x,y) of
            a process window.

        .DESCRIPTION
            Sets the window size (height,width) and coordinates (x,y) of
            a process window.

        .PARAMETER ProcessId
            Id of the process to determine the window characteristics

        .PARAMETER X
            Set the position of the window in pixels from the top.

        .PARAMETER Y
            Set the position of the window in pixels from the left.

        .PARAMETER Width
            Set the width of the window.

        .PARAMETER Height
            Set the height of the window.

        .NOTES
            Name: Set-Window
            Author: Boe Prox
            Version History
                1.0//Boe Prox - 11/24/2015
                    - Initial build

        .OUTPUT
            System.Automation.WindowInfo

        .EXAMPLE
            Get-Process powershell | Set-Window -X 2040 -Y 142 -Passthru

            ProcessName Size     TopLeft  BottomRight
            ----------- ----     -------  -----------
            powershell  1262,642 2040,142 3302,784   

            Description
            -----------
            Set the coordinates on the window for the process PowerShell.exe
        
    #>
    [OutputType('System.Automation.WindowInfo')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipelineByPropertyName=$True)]
        $ProcessId,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height
    )
    Begin {
        Try{
            [void][Window]
        } Catch {
        Add-Type @"
              using System;
              using System.Runtime.InteropServices;
              public class Window {
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

                [DllImport("User32.dll")]
                public extern static bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);
              }
              public struct RECT
              {
                public int Left;        // x position of upper-left corner
                public int Top;         // y position of upper-left corner
                public int Right;       // x position of lower-right corner
                public int Bottom;      // y position of lower-right corner
              }
"@
        }
    }
    Process {
        $Rectangle = New-Object RECT
        $Handle = (Get-Process -Id $ProcessId).MainWindowHandle
        $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle)
        If (-NOT $PSBoundParameters.ContainsKey('Width')) {            
            $Width = $Rectangle.Right - $Rectangle.Left            
        }
        If (-NOT $PSBoundParameters.ContainsKey('Height')) {
            $Height = $Rectangle.Bottom - $Rectangle.Top
        }
        If ($Return) {
            $Return = [Window]::MoveWindow($Handle, $x, $y, $Width, $Height, $True)
        }
    }
}

Function My-Set-Screen-For {
    Param (
        $Screen,
        $Name,
        $Maximize = $TRUE
    )

    Begin {
        $screenWA = $Screen.WorkingArea

        $threads = Get-Process | Where-Object { $_.Name -like $Name} | Where-Object { $_.MainWindowTitle }

        foreach($t in $threads) {
            $uPid = $t | select Id
            echo "Setting $Name $uPid"
    
            echo "- Restore size"
            # Restore window (4)
            [Win32.NativeMethods]::ShowWindow($t.MainWindowHandle, 4) | Out-Null
            Start-Sleep -Seconds 1
            
            # Move the window
            echo "- Moving it"
            My-Set-Window -ProcessId $uPid.Id -X $screenWA.X -Y  $screenWA.Y
            Start-Sleep -Seconds 1

            if ($Maximize) {
                # Maximize the window (3)
                echo "- Maximize it"
                [Win32.NativeMethods]::ShowWindow($t.MainWindowHandle, 3) | Out-Null
                # Start-Sleep -Seconds 1
            } else {
                echo "- Leaving like that"
            }

            # Activate the window (5)
            #echo "- Activating it"
            #[Win32.NativeMethods]::ShowWindow($t.MainWindowHandle, 5) | Out-Null
        }
    }
}