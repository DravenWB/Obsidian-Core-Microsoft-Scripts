Test-OcmsPSVersion -Version 5.2
Test-OcmsSpoConnection

###############################################################################################################################################################
Write-Host "Now gathering available tenant sites for processing..."

#Gathers all sites in the tenant without an M365 Group ID.
try{
    $SiteDirectory = Get-SPOSite -Limit All | Where-Object {$_.GroupId -eq "00000000-0000-0000-0000-000000000000" -or $_.GroupId -eq ""}
    Write-Verbose -ForegroundColor Green "Successfully gathered SharePoint site information!"
}
    catch{throw "There was an error gathering the required site data: $_"}

###############################################################################################################################################################
#Ensure operator is a site collection admin and create a site M365 Private group for all items.
Write-Host -ForegroundColor Green "Now processing changes..."

Start-Sleep -Seconds 1

#Initialize processing counter.
$ProcessingCounter = 0
$TotalItems = $SiteDirectory.Count()
$ReversionIndex = @() #Variable to contain sites that the operator was not originally a site collection administrator of for later reversion.
$ErrorRecord = @() #Index to record errors for later review.

foreach($Site in $SiteDirectory) {
    $PercentComplete = ($ProcessingCounter/$TotalItems) * 100
    Write-Progress -Activity "Configuring private M365 Groups..." -Status "$ProcessingCounter out of $SiteDirectory completed." -PercentComplete $PercentComplete

    try {Get-SPOUser -Site $Site.Url -LoginName $AdminUPN | Out-Null}
        catch {
            $ReversionIndex += $Site

            Set-SPOUser -Site $Site.Url -LoginName $AdminUPN -IsSiteCollectionAdmin $true | Out-Null
        }

    try {
        $Title = $Site.Title
        Set-SPOSiteOffice365Group -Site $Site.Url -DisplayName $Title -Description "Regenerated group for site collection $Title" -Alias $Title | Out-Null

        Write-Verbose -ForegroundColor Green "$Title successfully associated with M365 Private group."
    }
        catch {
            Write-Host -ForegroundColor Yellow "An error occurred while creating the group. Now attempting to modify M365 group title."

            try {
                    $ModTitle = $Title += "-Mod"
                    Set-SPOSiteOffice365Group -Site $Site.Url -DisplayName $ModTitle -Description "Regenerated group for site collection $Title" -Alias $ModTitle
                }
                catch 
                    {
                        $SiteURLCurrent = $Site.Url
                        $XError = "Error: Second attempt to associate M365 Private group failed for $Title ($SiteURLCurrent)."
                        Write-Host -ForegroundColor Red $XError
                        $ErrorRecord += $XError
                    }
        }
}

#Revert operator permissions back to previous state, print error report to local desktop and clear memory.

foreach ($Site in $ReversionIndex)
    {Set-SPOUser -Site $Site -LoginName $AdminUPN -IsSiteCollectionAdmin $false}

#If the error record is not empty, print to the local desktop.
if($ErrorRecord -ne $null)
    {$ErrorRecord | Out-File -FilePath ~/desktop/M365Group_Error_Record.txt}

Write-Host -ForegroundColor Green "All operations complete! You may find a record of errors on the local desktop if any were present."
