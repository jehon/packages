. $PSScriptRoot\..\lib\set-window.ps1
. $PSScriptRoot\..\lib\get-screen.ps1

# Set state of the window:
#   See https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow

Add-Type -name NativeMethods -namespace Win32 `
    -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' `

Function My-Set-Screen-For {
    Param (
        $Screen,
        $Title,
        $Maximize = $TRUE
    )

    Begin {
        $screenWA = $Screen.WorkingArea

        $threads = Get-Process | Where-Object { $_.MainWindowTitle -like $Title }

        foreach($t in $threads) {
            $uPid = $t | select Id
            echo "Setting $Title $uPid"

            # Restore window (4)
            # [Win32.NativeMethods]::ShowWindow($t.MainWindowHandle, 4) | Out-Null
            # Start-Sleep -Seconds 1
            
            # Move the window
            echo "- Moving it"
            My-Set-Window -ProcessId $uPid.Id -X $screenWA.X -Y  $screenWA.Y
            Start-Sleep -Seconds 1

            if ($Maximize) {
                # Maximize the window (3)
                echo "- Maximize it"
                [Win32.NativeMethods]::ShowWindow($t.MainWindowHandle, 3) | Out-Null
                Start-Sleep -Seconds 1
            } else {
                echo "- Leaving like that"
            }

            # Activate the window (5)
            echo "- Activating it"
            [Win32.NativeMethods]::ShowWindow($t.MainWindowHandle, 5) | Out-Null
            # Start-Sleep -Seconds 1
        }
    }
}

# Screens
$primary = My-Get-Screen -Primary
$secondary = My-Get-Screen -Secondary

My-Set-Screen-For -Screen $secondary -Title "*- Outlook"
My-Set-Screen-For -Screen $secondary -Title "*Microsoft Teams*"
My-Set-Screen-For -Screen $secondary -Title "*Mozilla Firefox*"

My-Set-Screen-For -Screen $primary -Title "*- Excel" -Maximize $FALSE
My-Set-Screen-For -Screen $primary -Title "*- Word" -Maximize $FALSE
My-Set-Screen-For -Screen $primary -Title "*- PowerPoint" -Maximize $FALSE
