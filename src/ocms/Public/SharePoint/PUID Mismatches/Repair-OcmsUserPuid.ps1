# ADD -Mode Nuke
# ADD -Mode Repair

####################################################################################################################################################################################
# Description: This script is built to reset PUID mismatches for a user that is experiencing issues with sharing files, accessing sites they've been given permissions to, etc.
#
# How it Works: Effectively, this script will remove the user from the User Information List in a SharePoint site or OneDrive entirely by using the Remove-SPOUser command. This
#               will remove 100% of current permissions for that user from the location the script is run against. Data such as files, sites, etc. will remain in place but the
#               user will no longer have access to them until they are added back to the locations, re-shared previously shared documents from that location, etc.
#
# Dependencies: + SharePoint Online PowerShell Module (Version check and installation command included in script.)
#
# Before You Run: Important information to take into consideration before running this script! Please be sure to read these details in their entirety.
#
#               + The operator will need to be a site collection administrator for all locations it is run on. This is required by Get-SPOUser as a check is placed in the script
#                 to see if that user is part of the site/OneDrive before attempting to run the command to remove them.
#
#                 This script is currently configured to add you to any sites/OneDrives you do not currently have site collection permissions for!
#
#                 While this has no currently known major drawbacks, it may look suspicious if logged. Prior to the script finishing, any sites that you were not previously a site 
#                 collection admin of before running will be removed from your account as part of the cleanup process. This information is logged and stored in a text file saved 
#                 by this script for your records locally.
#
#               + For your ease of review, each section has been blocked out using the pound sign (#). Different operations take place within each section.
#
# Terms found within this script:
#
#               + UIL = User Information List (See README.md for more details)
#               + SPO = SharePoint Online
#               + UPN = User Principal Name
#               + PUID = Persistent Unique Identifier (See README.md for more details)
#
####################################################################################################################################################################################
#Set error view and action for clean entry into the output file. Additionally gets the operator's current setting to change it back at script cleanup time. 

#Get operator current error output length and set to concise.
$OriginalErrorView = $ErrorView
$ErrorView = [System.Management.Automation.ActionPreference]::ConciseView

#Get operator current error action and set to stop.
$OriginalErrorAction = $ErrorActionPreference
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Continue


Write-Verbose "Now checking running PowerShell version..."
Test-OcmsPSVersion -Version 5
Test-OcmsSpoConnection

####################################################################################################################################################################################

#Get the admin center URL.
Write-Host "Please enter the URL for your SharePoint Admin Center for connecting."
Write-Host "Ex: https://contoso-admin.sharepoint.com"
Write-Host " "
$SharePointAdminURL = Read-Host "URL"

Write-Host " "

#Get the admin UPN.
Write-Host "Please enter your SharePoint Administrator email for connection and temporary permissions assignment."
Write-Host "Commercial Example: UPN@tenant.com"
Write-Host " "
$SharePointAdminUPN = Read-Host "Email"

Write-Host " "

#Get the UPN to run the UIL PUID mismatch for.
Write-Host "Please enter the email of the user to run a PUID mismatch for."
Write-Host " "
$UserUPN = Read-Host "User UPN"

####################################################################################################################################################################################

Write-Host " "

Write-Host "Now gathering available tenant sites for processing..."
Start-Sleep -Seconds 1

#Gathers all sites in the tenant to include OneDrive accounts. Completed early to give operator site count in the next section's disclaimer readout.
try {$SiteDirectory = Get-SPOSite -Limit All -IncludePersonalSite $true | Sort-Object -Property Url}
    catch {throw "There was an error gathering the required site data: $_"}

####################################################################################################################################################################################

Write-Host " "

#Inform operator how the operation works and provide important considerations.
Write-Host -ForegroundColor Red " << IMPORTANT >>"
Write-Host -ForegroundColor Yellow "+ PUID mismatch correction is completed by removing the user from the User Information List."
Write-Host -ForegroundColor Yellow "+ As such, all permissions for the particular user on every site will be removed."
Write-Host -ForegroundColor Yellow "+ This script does not make ID mismatch checks but instead, runs manually for all sites."
Write-Host " "
Write-Host -ForegroundColor Yellow "+ The command Get-SPOUser requires that you are a sharepoint site administrator of every site you want to make changes for"
Write-Host -ForegroundColor Yellow "  to check for user presence."
Write-Host -ForegroundColor Yellow "+ This script checks if you are an active SharePoint site admin for the sites being processed before assigning permissions."
Write-Host -ForegroundColor Yellow "+ A check is also in place to restore original site collection administrator assignments for all sites processed at the end."
Write-Host " "
Write-Host "This operation will be run for the user >" $UserUPN "< on" $SiteDirectory.Count "site locations and OneDrive locations combined."
Write-Host " "
Write-Host "To confirm that you would like to proceed, please enter the word > Confirm < (Case Sensitive)."
Write-Host " "

#Get Confirmation that the operator is ready to proceed with the operation after being provided with details on currently configured functions.
do
{
    $DisclaimerTwo = Read-Host "Proceed?"

    if ($DisclaimerTwo -cne "Confirm") {
        Write-Host -ForegroundColor DarkYellow "Input did not match the word Confirm."
        Write-Host -ForegroundColor DarkYellow "Please try again or press Ctrl + C to exit the script."
    }
}
    until ($DisclaimerTwo -ceq "Confirm")

####################################################################################################################################################################################
#The following operations are combined into single block for easier data handling. Separated into sub-blocks for readability.

#Data storage class definition.
class OperationData
{
    [int]    $Index
    [string] $Date
    [string] $AdminCheckTime
    [string] $Location
    [bool]   $OriginallyAdmin
    [bool]   $AdminReverted
    [string] $UserCheckTime
    [string] $UserUPN
    [bool]   $UserRemoved
    [string] $AdminErrors
    [string] $UserErrors   
}

$LoggingIndex = @() #Index to store data for operational logging and file output.

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
$IndexCounter = 0 #Initialize counter for index numbering.

Write-Host "Now processing all site collection changes for $UserUPN."
Write-Host "This may take an extended period of time dependent on the size of your tenant's SharePoint configuration..."
Start-Sleep -Seconds 3

#For each site in the tenant...
foreach ($Site in $SiteDirectory)
    {
        #Display progress bar for PUID mismatch resets.
        $ProgressPercent = ($IndexCounter / $SiteDirectory.Count) * 100
        $ProgressPercent = $ProgressPercent.ToString("#.##")
        Write-Progress -Activity "Manual PUID Reset Processing..." -Status "$ProgressPercent% Complete:" -PercentComplete $ProgressPercent

        #Initialize errors to blank space to ensure proper listing + clearing of old data if available.
        $A_Error = " "
        $U_Error = " "

        #Check if the operator is currently a site collection admin for the current site being processed.
        try
            {
                $Test = (Get-SPOUser -Site $Site.Url -LoginName $SharePointAdminUPN -ErrorAction SilentlyContinue).IsSiteAdmin
                $SiteCheck = $true
                $Test = $null
            }

            catch {$SiteCheck = $false}

        #If they are, set current admin variable to true. If not, add them temporarily as a site collection admin.
        if($SiteCheck) {
            $AdminTime = Get-Date -Format "HH:mm"
            $AdminCurrent = $true
        }
            else {
                $AdminTime = Get-Date -Format "HH:mm"
                $AdminCurrent = $false

                try {Set-SPOUser -Site $Site.Url -LoginName $SharePointAdminUPN -IsSiteCollectionAdmin $true}
                    catch {
                        $AdminCurrent = $false
                        $A_Error = $_
                        }
                }
        
        #Check user presence on the site being processed. If they exist, remove them. If not, move to the next item.
        if (Get-SPOUser -Site $Site.Url | Where-Object {$_.LoginName -eq $UserUPN}) {
            $UserTime = Get-Date -Format "HH:mm"
            try {
                Remove-SPOUser -Site $Site.Url -LoginName $UserUPN
                $UserWasRemoved = $true
            }
                catch {
                    $UserWasRemoved = $false
                    $U_Error = $_
                }
        }
            else {
                $UserTime = Get-Date -Format "HH:mm"
                $UserWasRemoved = $false
            }

        #Write data to instantiated class object for temporary storage and file output.
        $DataTable = New-Object -TypeName OperationData -Property $([Ordered]@{
    
        Index = $IndexCounter + 1
        Date = Get-Date -Format "MM/dd/yyyy"
        AdminCheckTime = $AdminTime
        Location = $Site.Url
        OriginallyAdmin = $AdminCurrent
        AdminReverted = "" #Placeholder.
        UserCheckTime = $UserTime
        UserUPN = $UserUPN
        UserRemoved = $UserWasRemoved
        AdminErrors = $A_Error
        UserErrors = $U_Error
        })

        #Send the data table to the index.
        $LoggingIndex += $DataTable

        #Clear data table and increment counter for next site.
        $DataTable = $null
        $IndexCounter++
    }

####################################################################################################################################################################################
#Cleanup admin permissions.

Write-Host -ForegroundColor Green "User removal completed!"
Write-Host -ForegroundColor Green "Now reverting administrator permissions..."

#For each processed item...
foreach ($Entry in $LoggingIndex)
    {
        #If the operator was not originally an admin and there were no errors, reset permissions to original
        if ($Entry.OriginallyAdmin -eq $false -and $Entry.AdminErrors -eq " ") {
            try {
                Set-SPOUser -Site $Entry.Location -LoginName $SharePointAdminUPN -IsSiteCollectionAdmin $false
                $Entry.AdminReverted = $true
            }
                #If operation fails, set reverted variable to false and create output to error admin error variable.
                catch {
                    $Entry.AdminReverted = $false

                    #Checks if the admin error is blank or if it contains information. If it is blank, set error data.
                    if ($Entry.AdminErrors -like " ")
                        {$Entry.AdminErrors = "Removal Error: $_"}

                        #If admin error is populated, append error to existing data.
                        else {$Entry.AdminErrors = $Entry.AdminErrors + (" Removal Error:" + $_)}
                }                
        }

        #If the operator was not originally an admin and there were errors when checked, set reverted to false and continue.
        else{$Entry.AdminReverted = $false}
    }

####################################################################################################################################################################################

#Save script data to file.

do {
    Write-Host "This portion of the script has been placed into a loop in case saving the file fails."
    Write-Host ""
    Write-Host "Save defaults to the file name PUID_Mismatch_Log.csv on the desktop. If it fails, it will modify the name as a backup."
    Write-Host "Once the script completes, changes made that have been stored in memory will be lost."
    Write-Host ""
    Write-Host "Please ensure you have the data you need before exiting."
    Write-Host " "
    Write-Host "1. Save processed changes to file."
    Write-Host "2. Complete cleanup and Exit."
    Write-Host ""

    $SaveSelection = Read-Host "Selection"

    switch($SaveSelection) {
        '1' #Attempt to save file with default settings.
        {
            try {
                $LoggingIndex | Export-Csv -Path "~\Desktop\Inheritance_Reset_Log.csv" -NoClobber
                Write-Host -ForegroundColor Green "The file has successfully been saved to the following location:"
                Write-Host -ForegroundColor Green "> ~\Desktop\Inheritance_Reset_Log.csv <"
                Read-host -Prompt "Enter any key to continue" #Makes the script wait till the user is ready to continue.
            }
                catch {
                    Write-Host -ForegroundColor Yellow "Saving the file failed. Now attempting to add modifier and try again."
                    Start-Sleep -Seconds 1

                    $LoggingIndex | Export-Csv -Path "~\Desktop\Inheritance_Reset_Log_New.csv" -NoClobber
                    Write-Host -ForegroundColor Green "The file has successfully been saved to the following location:"
                    Write-Host -ForegroundColor Green "> ~\Desktop\Inheritance_Reset_Log_New.csv <"
                    Read-host -Prompt "Enter any key to continue" #Makes the script wait till the user is ready to continue.
                }
        }
    }
}

    until($SaveSelection -eq '2')

####################################################################################################################################################################################
#Script cleanup.

#Release majority memory usage.
$LoggingIndex = $null

#Reset error view/length to operator original setting.
$ErrorView = [System.Management.Automation.ActionPreference]::$OriginalErrorView
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::$OriginalErrorAction

####################################################################################################################################################################################

Write-Host -ForegroundColor Green "Script now complete! Have a wonderful day! :)"
