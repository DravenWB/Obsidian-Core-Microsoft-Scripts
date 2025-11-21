# Official checker for if something should be run or not. Press enter to continue.

[CmdletBinding(SupportsShouldProcess)]
param()

if ($PSCmdlet.ShouldProcess("Reset inheritance on $LibraryName")) {
    # Do the thing
}

Write-Error #For non-terminating errors
throw #For terminating errors