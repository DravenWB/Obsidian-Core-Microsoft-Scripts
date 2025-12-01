Get-OcmsSensitivityLabelPolicy {
    [CmdletBinding()]
    param (
        [ValidateCount(1)]
        [Parameter()]
        [String]$UserUPN
    )

    #Test for runtime dependencies.
    Test-OcmsModule -Module Exchange
    Test-OcmsConnection -Service Exchange
    Test-OcmsConnection -Service IPPS

    #Get user current formatenumerationlimit for restoration upon script completion then set enumeration limit for script.
    $InitEnumLimit = $formatenumerationlimit
    $formatenumerationlimit=-1

    if ($UserUPN) {Get-Mailbox -Identity $UserUPN | Format-List -ErrorAction SilentlyContinue}
        else {continue}
    Get-OMEConfiguration | Format-List
    Get-RMSTemplate -ResultSize Unlimited
    Get-LabelPolicy | Format-List
    Get-Label | Format-List

    $formatenumerationlimit = $InitEnumLimit
}
