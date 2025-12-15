$ErrorActionPreference='Stop'
Get-Process gui -ErrorAction SilentlyContinue | ForEach-Object { $_.Kill() }
Start-Sleep -Milliseconds 300
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = '.\build\gui.exe'
$psi.RedirectStandardInput = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $false
$psi.EnvironmentVariables['GUI_AUTO_START'] = '1'
$proc = [System.Diagnostics.Process]::Start($psi)
Start-Sleep -Milliseconds 200
$proc.StandardInput.WriteLine('1')
Start-Sleep -Milliseconds 500
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class W { [DllImport("user32.dll", CharSet=System.Runtime.InteropServices.CharSet.Auto)] public static extern IntPtr FindWindow(string lpClassName, string lpWindowName); }
'@
# Enumerate top-level windows and print some titles for diagnosis
Add-Type @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public static class E {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll")] public static extern int GetWindowTextLength(IntPtr hWnd);
}
'@
$windows = @()
$callback = [E+EnumWindowsProc]{ param($hwnd,$lparam) $len = [E]::GetWindowTextLength($hwnd); if ($len -gt 0) { $sb = New-Object System.Text.StringBuilder ($len+1); [E]::GetWindowText($hwnd,$sb,$sb.Capacity) | Out-Null; $windows += @{h=$hwnd; t=$sb.ToString()} } return $true }
[E]::EnumWindows($callback, [IntPtr]::Zero)
$windows | ForEach-Object { Write-Host "HWND:" $_.h "Title:'$($_.t)'" }
$found = $windows | Where-Object { $_.t -like '*Progress*' }
if ($found) { Write-Host 'FOUND' $found.h } else { Write-Host 'NOT FOUND' }
