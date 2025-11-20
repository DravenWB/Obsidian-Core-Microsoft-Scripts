# Dot-source private functions
Get-ChildItem -Path "$PSScriptRoot/Private" -Filter *.ps1 -Recurse | ForEach-Object {
    . $_.FullName
}

# Dot-source public functions
Get-ChildItem -Path "$PSScriptRoot/Public" -Filter *.ps1 -Recurse | ForEach-Object {
    . $_.FullName
}

# Export public functions only
$public = Get-ChildItem -Path "$PSScriptRoot/Public" -Filter *.ps1 |
          Select-Object -ExpandProperty BaseName

Export-ModuleMember -Function $public
