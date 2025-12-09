function New-OcmsTestListItems {
    <#
    .SYNOPSIS
    Test list item generator.

    .DESCRIPTION
    Generates list items for testing scenarios. Ex: Some issues can only be tested with a list of 100,000 items. This generates those items.

    .PARAMETER ListName
    The list to generate items on.
    Ex: MyList

    .PARAMETER Amount
    The amount of items to generate.
    Default: 100

    .PARAMETER ItemName
    What to name the item.
    Default: TestItem

    .PARAMETER Counter
    What number to start the counter at.
    Default: 1

    .PARAMETER 

    .EXAMPLE
    New-OcmsTestListItem -ListName MyList

    .EXAMPLE
    New-OcmsTestListItem -ListName MyList -Amount 500 -ItemName TestItem

    .EXAMPLE
    New-OcmsTestListItem -ListName MyList -Amount 500 -ItemName TestItem -Counter 362

    .NOTES
    Planned Updates:
        Implement logging
        
    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 06, 2025
    #>

    param(
        [Parameter(Mandatory)]
        [ValidateCount(1)]
        [string]$ListName,

        [Parameter()]
        [ValidateCount(1)]
        [int]$Amount = 100,

        [Parameter()]
        [ValidateCount(1)]
        [string]$ItemName = "TestItem",

        [Parameter()]
        [ValidateCount(1)]
        [int]$Counter = 1
    )

    # Review and testing is necessary before anyone should even attempt to use this.
    throw "This function is not ready for use at this time. Additional changes, review and testing required."

    #Bootstrap
    Test-OcmsPSVersion -Version 7
    Test-OcmsPnPInstall

    #Check for installed .net version and exit if version is found to be below version 4.8.
    #Version not printed to user as the internal version is not listed as 4.8 (ex.) and is instead listed as a number like "533320" which isn't the most readable.
    #Planned to be later integrated into the module checker.
    [string] $DotNetVersion = Get-ItemPropertyValue -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release
    if ($DotNetVersion -lt "533320") {
            Write-Host -ForegroundColor Red "Your .Net framework installed is currently out of date."
            Write-Host -ForegroundColor Red "To run this script, please update your .Net version to 4.8 or greater."
            Exit
        }
            else {continue}

    Write-Verbose "Generating items..."
    do {
        Add-PnPListItem -List $ListName -Values @{"Title" = "$ItemName $Counter"}
        $Counter++
    }
        while ($Counter -le $ItemCount)

    Write-Verbose "Generation of $Amount items complete."
}