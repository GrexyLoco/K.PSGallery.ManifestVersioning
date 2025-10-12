#
# K.PSGallery.ManifestVersioning.psm1
# 
# PowerShell module for updating module manifest (.psd1) versions
# Uses PowerShell native functions for file operations and Git CLI for version control
#

# Import private functions
Get-ChildItem -Path "$PSScriptRoot\src\Private\*.ps1" | ForEach-Object {
    . $_.FullName
}

# Import public functions
Get-ChildItem -Path "$PSScriptRoot\src\Public\*.ps1" | ForEach-Object {
    . $_.FullName
}

# Export only public functions (defined in .psd1 manifest)
# Note: FunctionsToExport in .psd1 controls what gets exported