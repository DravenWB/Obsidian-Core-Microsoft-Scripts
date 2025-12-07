function Write-OcmsLog {

    <#
    .SYNOPSIS
    Unified object logging module.

    .DESCRIPTION
    Module used for all OCMS log handling. Includes two-stage automated naming conflict handling to prevent data loss in case of long script operation.

    .PARAMETER Data
    Input object for parsing and logging.

    .PARAMETER FileName
    The name of the final output file.
    Default: ocms-log

    .PARAMETER LogPath
    The location the file should be saved to.
    Default: User desktop.

    .PARAMETER ThrowOnFail
    Whether or not to throw on failure. A.K.A. Continue or not whether logging is working.
    Valid Options: $true, $false
    Default: $false

    .EXAMPLE
    Write-OcmsLog -Data $object

    .EXAMPLE
    Write-OcmsLog -Data $object -FileName ChangeReport.csv

    .EXAMPLE
    Write-OcmsLog -Data $object -LogPath ~/Documents/Logs/ -FileName ChangeReport.csv

    .NOTES
    Planned Updates
        Ready for testing and filepath validation update once complete to avoid false positives.
        
    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 06, 2025
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]$Data,

        [ValidateCount(1)]
        [string]$FileName = "ocms-log.csv",

        [ValidateCount(1)]
        [string]$LogPath = [Environment]::GetFolderPath("Desktop"),

        [ValidateCount(1)]
        [bool]$ThrowOnFail = $false
    )

    # Review and testing is necessary before anyone should even attempt to use this.
    throw "This function is not ready for use at this time. Additional changes, review and testing required."

    $CompletePath = $LogPath + "\$FileName"

    $LogModifier = Get-Date -Format "MM_dd_yyyy-HHmm"

    Write-Verbose "Testing output to $CompletePath"

    if (Test-Path $CompletePath) {
        try {
            Export-Csv -InputObject $Data -Path $CompletePath -NoClobber
            Write-Verbose "File at path already exists. Attempting modified file name."
        
            $CompletePath = $LogPath + "\$FileName" + "-$LogModifier"

            Write-Verbose "File save successful with modified file name."
        }
            catch {
                Write-Error "Unhandled exception: $($_.Exception.Message)"
                Write-Verbose "Attempting secondary alternative file name to output file."

                try {
                    $BackupModifier = (Get-Date).Second
                    $CompletePath = $LogPath + "\$FileName" + "-$LogModifier" + "-$BackupModifier"
                    Export-Csv -InputObject $Data -Path $CompletePath -NoClobber

                    Write-Verbose "Secondary file succeeded in save operation."
                }

                catch {
                    if ($ThrowOnFail) {
                        throw "Unhandled exception: $($_.Exception.Message)"
                    }
                    else {Write-Error "Unhandled exception: $($_.Exception.Message)"} 
                }
            }
    }

    else {Export-Csv -InputObject $Data -Path $CompletePath -NoClobber}
}