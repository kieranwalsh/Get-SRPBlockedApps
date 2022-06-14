<#
    Filename: Get-SRPBlockedApps.ps1
    Contributors: Kieran Walsh, Joe Sheehan
    Created: 2022-03-30
    Last Updated: 2022-03-30
    Version: 0.01.00
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName = '',
    [int]$MaxDays = 366
)

Write-Host "I am querying blocked applications on '$ComputerName'."

$StartTime = (Get-Date).AddDays(-$MaxDays)
try
{
    $BlockedApps = (Get-WinEvent -ComputerName $ComputerName -FilterHashtable @{
            logname   = 'Application'
            ID        = '866'
            StartTime = $StartTime
        } -ErrorAction Stop).message | ForEach-Object {((($_ -split 'Access to ')[1]) -split ' has been restricted')[0]} | Select-Object -Unique
}
catch [System.Diagnostics.Eventing.Reader.EventLogException]
{
    'Unable to connect to computer.'
    break
}
catch [System.Exception]
{
    "No blocked applications detected since $($StartTime)."
    break
}
catch
{
    'Unknown Error.'
    break
}
' '
$BlockedApps | ForEach-Object {$Sections = $_ -split '\\'
    $Sections[2] = '*'
    $Sections -join '\' -replace '(\d+(\.\d+){1,3})', '*'
} | Sort-Object -Unique