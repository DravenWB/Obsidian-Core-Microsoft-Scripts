function Test-OcmsSpoConnection {
    [CmdletBinding()]
    param()

    try {
        Get-SPOTenant -ErrorAction Stop | Out-Null
        $connected = $true
    }
        catch {$connected = $false}

    if ($connected) { return }
        else {throw "You are not connected to the SharePoint Online Service. Please run Connect-OcmsSPO to continue."}
}

function Test-OcmsPnPConnection {
    [CmdletBinding()]
    param()

    try {
        $connection = Get-PnPConnection -ErrorAction Stop

        if ($null -ne $connection -and $connection.ConnectionType -ne 'None') {return $true}
            else {return $false}
    }
    catch {return $false}
}