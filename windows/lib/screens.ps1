
# Thanks to

# Set state of the window:
#   See https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow

Add-Type -name NativeMethods -namespace Win32 `
    -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' `

Function Get-Screen {

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

        $selected_list = [System.Windows.Forms.Screen]::AllScreens | Sort-Object -Property { $_.WorkingArea.X }
        If ($PSBoundParameters.ContainsKey('Primary')) {
            $selected_list = $selected_list | Where-Object Primary
        }

        If ($PSBoundParameters.ContainsKey('Secondary')) {
            $selected_list = $selected_list | Where-Object { ! $_.Primary }
        }

        # $selected_list = selected_list | select -First $ScreenId

        # Only take a screen
        $selected = $selected_list | select -First 1

        return $selected

    }
}

Function Set-Window-To-Screen {
    <#
        .SYNOPSIS
            !! Helper for below function !!
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

        .OUTPUT
            System.Automation.WindowInfo

    #>
    [OutputType('System.Automation.WindowInfo')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipelineByPropertyName = $True)]
        [int]$windowHandle,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height
    )
    Begin {
        Try {
            [void][Window]
        }
        Catch {
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
        $Return = [Window]::GetWindowRect($windowHandle, [ref]$Rectangle)
        If (-NOT $PSBoundParameters.ContainsKey('Width')) {
            $Width = $Rectangle.Right - $Rectangle.Left
        }
        If (-NOT $PSBoundParameters.ContainsKey('Height')) {
            $Height = $Rectangle.Bottom - $Rectangle.Top
        }
        If ($Return) {
            $Return = [Window]::MoveWindow($windowHandle, $x, $y, $Width, $Height, $True)
        }
    }
}

function Get-ChildWindow {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelinebyPropertyName = $true)]
        [ValidateNotNullorEmpty()]
        [System.IntPtr]$MainWindowHandle
    )

    BEGIN {
        function Get-WindowName($hwnd) {
            $len = [apifuncs]::GetWindowTextLength($hwnd)
            if ($len -gt 0) {
                $sb = New-Object text.stringbuilder -ArgumentList ($len + 1)
                $rtnlen = [apifuncs]::GetWindowText($hwnd, $sb, $sb.Capacity)
                $sb.tostring()
            }
        }

        if (("APIFuncs" -as [type]) -eq $null) {
            Add-Type  @"
            using System;
            using System.Runtime.InteropServices;
            using System.Collections.Generic;
            using System.Text;
            public class APIFuncs
              {
                [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
                public static extern int GetWindowText(IntPtr hwnd,StringBuilder lpString, int cch);

                [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
                public static extern IntPtr GetForegroundWindow();

                [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
                public static extern Int32 GetWindowThreadProcessId(IntPtr hWnd,out Int32 lpdwProcessId);

                [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
                public static extern Int32 GetWindowTextLength(IntPtr hWnd);

                [DllImport("user32")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool EnumChildWindows(IntPtr window, EnumWindowProc callback, IntPtr i);
                public static List<IntPtr> GetChildWindows(IntPtr parent)
                {
                   List<IntPtr> result = new List<IntPtr>();
                   GCHandle listHandle = GCHandle.Alloc(result);
                   try
                   {
                       EnumWindowProc childProc = new EnumWindowProc(EnumWindow);
                       EnumChildWindows(parent, childProc,GCHandle.ToIntPtr(listHandle));
                   }
                   finally
                   {
                       if (listHandle.IsAllocated)
                           listHandle.Free();
                   }
                   return result;
               }
                private static bool EnumWindow(IntPtr handle, IntPtr pointer)
               {
                   GCHandle gch = GCHandle.FromIntPtr(pointer);
                   List<IntPtr> list = gch.Target as List<IntPtr>;
                   if (list == null)
                   {
                       throw new InvalidCastException("GCHandle Target could not be cast as List<IntPtr>");
                   }
                   list.Add(handle);
                   //  You can modify this to check to see if you want to cancel the operation, then return a null here
                   return true;
               }
                public delegate bool EnumWindowProc(IntPtr hWnd, IntPtr parameter);
               }
"@
        }
    }

    PROCESS {
        foreach ($child in ([apifuncs]::GetChildWindows($MainWindowHandle))) {
            Write-Output (, ([PSCustomObject] @{
                        MainWindowHandle = $MainWindowHandle
                        ChildId          = $child
                        ChildTitle       = (Get-WindowName($child))
                    }))
        }
    }
}

Function Move-Window-To-Screen {
    <#
        .SYNOPSIS
            Move a process (by name) to a specific window

        .PARAMETER Screen
            Id of the screen (0 = primary, 1 = secondary)

        .PARAMETER Name
            Name of the process to move

        .PARAMETER Maximize
            Maximize the window on the screen
    #>

    Param (
        $Screen,
        $Name,
        [switch]$Maximize
    )

    Begin {
        $screenWA = $screens[$Screen].WorkingArea

        $threads = Get-Process | Where-Object { $_.Name -eq $Name } | Where-Object { $_.MainWindowTitle }

        foreach ($t in $threads) {
            $wHandle = $t.MainWindowHandle
            Write-Output "Setting $Name $wHandle"

            Write-Output "- Restore size"
            # Restore window (4)
            [Win32.NativeMethods]::ShowWindow($wHandle, 4) | Out-Null
            Start-Sleep -Seconds 1

            # Move the window
            Write-Output "- Moving it"
            Set-Window-To-Screen -windowHandle $wHandle -X $screenWA.X -Y  $screenWA.Y
            Start-Sleep -Seconds 1

            if ($Maximize) {
                # Maximize the window (3)
                Write-Output "- Maximize it"
                [Win32.NativeMethods]::ShowWindow($wHandle, 3) | Out-Null
                # Start-Sleep -Seconds 1
            }
            else {
                Write-Output "- Leaving like that"
            }

            # Activate the window (5)
            #Write-Output "- Activating it"
            #[Win32.NativeMethods]::ShowWindow($wHandle, 5) | Out-Null
        }
    }
}

#
# Initialization
#

$screens = @()
$screens += Get-Screen -Primary
$screens += Get-Screen -Secondary

$primary = 0
$secondary = 1
