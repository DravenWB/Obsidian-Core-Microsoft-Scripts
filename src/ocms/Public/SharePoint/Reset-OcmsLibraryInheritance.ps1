###################################################################################################################
# Purpose: This script is intended to reset the inheritance state of all items within a document library or a list.
#
# Development date: January 27, 2024
#
# Note: This version of the script resets the inheritance status of ALL items and is not yet modified to only
# affect items that have unique permissions.
#
# NOTICE: This script has been carefully written and thoroughly tested. However, it remains an experimental solution.
# By running this script, you accept the risks and responsibilities associated with running said code. Microsoft
# is not liable for any damages or resulting issues.
###################################################################################################################

function Reset-OcmsLibraryInheritance {

    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description.

    .PARAMETER Param1
    Parameter description

    .PARAMETER Param2
    Parameter2 description

    .EXAMPLE
    Example command usage.

    .NOTES
    Author: DravenWB (GitHub)
    Module:
    Last Updated:
    #>

    [CmdletBinding()]
    param (
        [ValidateCount(1)]
        [Parameter(Mandatory)]
        [string]$LibraryName,

        [ValidateCount(1)]
        [ValidateSet($true, $false)]
        [Parameter()]
        [boolean]$ThrowOnFail
    )

    Test-OcmsPSVersion -Version 7
    Test-OcmsPnPInstall
    Test-OcmsConnection -Service "PnP"

    ####################################################################################################################################################################################

    Write-Host ""
    Write-Host "Please enter the URL of the site you are targetting:"
    Write-Host "Example: https://contoso.sharepoint.com/sites/SITENAME/"
    Write-Host "NOTE: If the name contains spaces, ensure you place a quotation mark at the beginning and end to ensure accurate input."

    $SiteURL = Read-Host "Site URL"

    #Removes quotations if present.
    if ($SiteURL.StartsWith('"') -or $SiteURL.EndsWith('"'))
        {$SiteURL = ($SiteURL.Trim('"'))}

    #Ensure the URL is ended with a /
    if (-not $SiteURL.EndsWith('/'))
        {$SiteURL += '/'}

    Write-Host "Please enter the name of the list or library:"
    Write-Host "Example: Documents"
    Write-Host "Example: Shared Documents"
    Write-Host "NOTE: If the name contains spaces, ensure you place a quotation mark at the beginning and end to ensure accurate input."

    $ListName = Read-Host "List/Library Name"

    #If the string starts or ends with quotations, remove them.
    if ($ListName.StartsWith('"') -or $ListName.EndsWith('"'))
        {$ListName = ($ListName.Trim('"'))}

    ####################################################################################################################################################################################>
    Test-OcmsConnection -Service "PnP"

    #Get the context.
    $Context = Get-PnPContext

    ####################################################################################################################################################################################
    #Run initial query to pull number of files and folders identified for reset.
    $QueryItems = Get-PnPListItem -List $ListName | Measure-Object | Select-Object -ExpandProperty Count

    class InheritanceChange
    {
        [int]    $Index 
        [string] $Date
        [string] $Time 
        [string] $FileName
        [string] $Location
        [bool]   $Inheritance_Reset
        [string] $Errors
    }

    $LoggingIndex = @() #Define data index to store changes for later output to log CSV file.
    [Int]$ProcessingCounter = 1 #Initialize counter for overall operational progress.
    [Int]$LoggingCounter = 0 #Initialize a counter specifically for outputting log files at the operator specified number of entries configured per file.
    $ProcessingDate = Get-Date -Format "MM/dd/yyyy" #Pre-assigned to get date once instead of potentially hundreds/thousands of times over.

    ####################################################################################################################################################################################
    #Process changes.

    $ProcessingIndex = Get-PnPListItem -List $ListName -PageSize 500 | Where-Object {$_.FileSystemObjectType -eq "File" -or $_.FileSystemObjectType -eq "Folder"}

    foreach ($ProcessingItem in $ProcessingIndex) 
        {
            try
                {
                    $PercentComplete = ($ProcessingCounter/$QueryItems) * 100
                    Write-Progress -Activity "Resetting library inheritance..." -Status "$ProcessingCounter out of $QueryItems completed." -PercentComplete $PercentComplete

                    #Load the item and confirm up to date information.
                    $Context.Load($ProcessingItem) 
                    $Context.ExecuteQuery()
                
                    #Process the inheritance reset.
                    $ProcessingItem.ResetRoleInheritance(); #Prime item inheritance reset.
                    $Context.ExecuteQuery() #Execute item inheritance reset.

                    #Write to screen that item inheritance was reset successfully. 
                    Write-Host -ForegroundColor Green $ProcessingItem.FieldValues.FileLeafRef " role inheritance reset."

                    $ResetCheck = $true #Sets variable for output if successful.
                }

                    catch #Error handling.
                    {
                        Write-Host -ForegroundColor Red "Error recorded for the resetting the role inheritance of $CurrentItemName" ":" $_
                        $XError = "$_"

                        $ResetCheck = $false #Sets variable for output if reset fails.
                    }

            #If the operator set parameters for logging, record data and output to CSV in batches.
            if ($null -ne $LoggingFileName)
                {
                    #Write data to instantiated class object for temporary storage and file output.
                    $DataTable = New-Object -TypeName InheritanceChange -Property $([Ordered]@{
            
                    Index = $ProcessingCounter + 1
                    Date = $ProcessingDate
                    Time = Get-Date -Format "HH:mm"
                    FileName = $ProcessingItem.FieldValues.FileLeafRef
                    Location = $ProcessingItem.FieldValues.FileDirRef
                    Inheritance_Reset = $ResetCheck
                    Errors = $XError
                    })

                    #Send the data table to the index.
                    $LoggingIndex += $DataTable

                    #If the index has processed the selected amount of items, output to file and clear for next file.
                    if ($LoggingCounter -ge $LoggingCount)
                        {
                            Write-Host -ForegroundColor Green "Outputting current data to file..."

                            #Try to save the current data to file under the selected location.
                            try
                                {
                                    $Time = Get-Date -Format "HH mm"
                                    $Path = $LoggingPath += $LoggingFileName += ".csv"
                                    $LoggingIndex | Export-Csv -Path $Path -NoClobber

                                    $LoggingCounter = 0
                                    $LoggingIndex = $null
                                }
                                        
                                #If saving fails, most commonly due to file name errors, rename the file and output again using the time to avoid duplicates a second time.
                                catch
                                    {
                                        $Time = Get-Date -Format "HH mm"
                                        $Path = $LoggingPath += $LoggingFileName += $Time += "_Mod.csv"

                                        $LoggingIndex | Export-Csv -Path $Path -NoClobber

                                        $LoggingCounter = 0
                                        $LoggingIndex = $null
                                    }
                        }

                        #Clear variables for next use to ensure no duplicate values from previous items are used.
                        $DataTable = $null
                        $CurrentItemName = $null
                        $ResetCheck = $null
                        $XError = $null
                }

            #Increment counter for progress bar, indexing and operational processing.
            $ProcessingCounter++
        }

    #Output remaining data to file.
    if ($null -ne $LoggingFileName)
        {
            #If the index has processed the selected amount of items, output to file and clear for next file.
                    Write-Host -ForegroundColor Green "Outputting remaining data to file..."

                    #Try to save the current data to file under the selected location.
                    try
                        {
                            $Time = Get-Date -Format "HH mm"
                            $Path = $LoggingPath += $LoggingFileName += $Time += ".csv"
                            $LoggingIndex | Export-Csv -Path $Path -NoClobber
                        }
                                        
                        #If saving fails, most commonly due to file name errors, rename the file and output again using the time to avoid duplicates a second time.
                        catch
                            {
                                $Time = Get-Date -Format "HH mm"
                                $Path = $LoggingPath += $LoggingFileName += $Time += "_Mod.csv"

                                $LoggingIndex | Export-Csv -Path $Path -NoClobber

                                $LoggingIndex = $null
                            }
        }

    ####################################################################################################################################################################################
    #Cleanup memory.
    $LoggingIndex = $null
    $ProcessingIndex = $null

}