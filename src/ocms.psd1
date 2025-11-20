@{
    RootModule        = 'ocms.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    Author            = 'Draven'
    CompanyName       = 'Obsidian Core'
    Description       = 'Obsidian Core Microsoft Scripts — Modular administrative tools for Microsoft Cloud environments.'

    PowerShellVersion = '5.1'

    FunctionsToExport = '*'
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags        = @('Microsoft365','PowerShell','SPO','Admin','GCC','GCCH','DoD')
            ProjectUri  = 'https://github.com/DravenWB/ocms'
            LicenseUri  = 'https://opensource.org/licenses/MIT'
        }
    }
}
