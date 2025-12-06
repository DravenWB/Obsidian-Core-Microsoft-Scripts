Get-OcmsSensitivityLabelPolicy {
    [CmdletBinding()]

    <#
    .SYNOPSIS
    A simple script to get organizational sensitivity labeling.

    .DESCRIPTION
    Gather sensitivity labeling with the option to input a user, should you want to get mailbox information for that user at the same time.

    .PARAMETER User
    Select a user by email to get mailbox information from.

    .EXAMPLE
    Get-OcmsSensitivityLabelPolicy

    .EXAMPLE
    Get-OcmsSensitivityLabelPolicy -User jane.doe@contoso.com

    .NOTES
    Planned Updates:
        Data parsing and log output as object instead of writing to terminal.

    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 06, 2025
    #>

    param (
        [ValidateCount(1)]
        [Parameter()]
        [String]$User
    )

    # Review and testing is necessary before anyone should even attempt to use this.
    throw "This function is not ready for use at this time. Additional changes, review and testing required."    

    #Test for runtime dependencies.
    Test-OcmsModule -Module Exchange
    Test-OcmsConnection -Service Exchange
    Test-OcmsConnection -Service IPPS

    #Get user current formatenumerationlimit for restoration upon script completion then set enumeration limit for script.
    $InitEnumLimit = $formatenumerationlimit
    $formatenumerationlimit=-1

    if ($User) {Get-Mailbox -Identity $User | Format-List -ErrorAction SilentlyContinue}
        else {continue}
    Get-OMEConfiguration | Format-List
    Get-RMSTemplate -ResultSize Unlimited
    Get-LabelPolicy | Format-List
    Get-Label | Format-List

    $formatenumerationlimit = $InitEnumLimit
}
