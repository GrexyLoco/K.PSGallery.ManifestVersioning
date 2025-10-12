function Write-ManifestFile {
    <#
    .SYNOPSIS
    Updates the ModuleVersion in a PowerShell module manifest file.

    .DESCRIPTION
    Uses regex to replace the ModuleVersion field in a .psd1 manifest file with a new version.

    .PARAMETER ManifestPath
    Path to the .psd1 manifest file to update.

    .PARAMETER NewVersion
    The new semantic version to set.

    .PARAMETER Content
    The current content of the manifest file.

    .RETURNS
    PSCustomObject with update results.

    .EXAMPLE
    Write-ManifestFile -ManifestPath './MyModule.psd1' -NewVersion '1.2.3' -Content $content
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath,

        [Parameter(Mandatory = $true)]
        [string]$NewVersion,

        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    Write-Verbose "Updating ModuleVersion to: $NewVersion"

    try {
        # Update ModuleVersion using regex
        # Matches patterns like: ModuleVersion = '1.0.0' or ModuleVersion='1.0.0' or ModuleVersion = "1.0.0"
        # Preserves the quote style (single or double)
        $updatedContent = $Content -replace "ModuleVersion\s*=\s*['\`"]([^'\`"]+)['\`"]", "ModuleVersion = '$NewVersion'"
        
        # Verify the replacement worked by checking if the new version is present
        if ($updatedContent -match "ModuleVersion\s*=\s*['\`"]$([regex]::Escape($NewVersion))['\`"]") {
            Write-Verbose "Regex replacement successful"
            
            # Write the updated content back to the file
            Set-Content -Path $ManifestPath -Value $updatedContent -NoNewline -ErrorAction Stop
            
            Write-Verbose "Manifest file updated successfully"

            return [PSCustomObject]@{
                Success = $true
                UpdatedContent = $updatedContent
                ErrorMessage = $null
            }
        }
        else {
            Write-Error "Regex replacement validation failed - ModuleVersion not updated correctly"
            return [PSCustomObject]@{
                Success = $false
                UpdatedContent = $Content
                ErrorMessage = "Regex replacement validation failed - ModuleVersion format may be invalid or not found"
            }
        }
    }
    catch {
        Write-Error "Failed to write manifest file: $_"
        return [PSCustomObject]@{
            Success = $false
            UpdatedContent = $Content
            ErrorMessage = "Failed to write manifest file: $_"
        }
    }
}