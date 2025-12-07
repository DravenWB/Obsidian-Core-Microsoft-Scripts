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
    Planned Updates: Ready for testing and debugging (if required.)

    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 06, 2025
    #>

    param (
        [ValidateCount(1)]
        [Parameter()]
        [String]$User
    )

    # Use List for efficiency
    $SensitivityData = [System.Collections.Generic.List[LicenseChangeMatrix]]::new()

    # Review and testing is necessary before anyone should even attempt to use this.
    throw "This function is not ready for use at this time. Additional changes, review and testing required."    

    #Test for runtime dependencies.
    Test-OcmsModule -Module Exchange
    Test-OcmsConnection -Service Exchange
    Test-OcmsConnection -Service IPPS

    #Get user current formatenumerationlimit for restoration upon script completion then set enumeration limit for script.
    $InitEnumLimit = $formatenumerationlimit
    $formatenumerationlimit=-1

    if ($User) {$MailboxData = Get-Mailbox -Identity $User | Format-List -ErrorAction SilentlyContinue}
        else {continue}
    $OMEConfig = Get-OMEConfiguration | Format-List
    $RMSTemplate = Get-RMSTemplate -ResultSize Unlimited
    $LabelPolicies = Get-LabelPolicy | Format-List
    $SensitivityLabels Get-Label | Format-List

    if ($User) {Write-OcmsLog -Object $MailboxData -FileName "User_Mailbox_Info.csv"}
    Write-OcmsLog -Object $OMEConfig -FileName "OME_Configuration.csv"
    Write-OcmsLog -Object $RMSTemplate -FileName "RMS_Template.csv"
    Write-OcmsLog -Object $LabelPolicies = "Label_Policy.csv"
    Write-OcmsLog -Object $SensitivityLabels = "Sensitivity_Labels.csv"

    $formatenumerationlimit = $InitEnumLimit
}
