function Test-ManifestVersion {
    <#
    .SYNOPSIS
    Validates if a PowerShell module manifest has a valid ModuleVersion field.

    .DESCRIPTION
    Tests whether a .psd1 manifest file exists and contains a properly formatted ModuleVersion field.

    .PARAMETER ManifestPath
    Path to the .psd1 manifest file to validate.

    .PARAMETER NewVersion
    Optional. The new version to validate format for.

    .RETURNS
    PSCustomObject with validation results.

    .EXAMPLE
    Test-ManifestVersion -ManifestPath './MyModule.psd1'
    
    .EXAMPLE
    Test-ManifestVersion -ManifestPath './MyModule.psd1' -NewVersion '1.2.3'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath,

        [Parameter(Mandatory = $false)]
        [string]$NewVersion
    )

    Write-Verbose "Validating manifest: $ManifestPath"

    $errors = @()

    # Check if file exists
    if (-not (Test-Path -Path $ManifestPath)) {
        $errors += "Manifest file not found: $ManifestPath"
    }

    # Validate new version format if provided
    if ($NewVersion) {
        Write-Verbose "Validating version format: $NewVersion"
        
        # Semantic versioning pattern: MAJOR.MINOR.PATCH with optional pre-release suffix
        # Examples: 1.0.0, 1.2.3, 1.0.0-alpha, 1.0.0-rc.1
        $versionPattern = '^\d+\.\d+\.\d+(-[a-zA-Z0-9\.\-]+)?$'
        
        if ($NewVersion -notmatch $versionPattern) {
            $errors += "Invalid version format: '$NewVersion'. Expected format: MAJOR.MINOR.PATCH (e.g., 1.2.3) with optional pre-release suffix (e.g., 1.0.0-alpha)"
        }
    }

    # Try to validate manifest syntax using Test-ModuleManifest
    if (Test-Path -Path $ManifestPath) {
        try {
            $null = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
            Write-Verbose "Manifest syntax is valid"
        }
        catch {
            $errors += "Invalid manifest syntax: $_"
        }
    }

    # Return validation result
    if ($errors.Count -eq 0) {
        Write-Verbose "Validation successful"
        return [PSCustomObject]@{
            IsValid = $true
            ErrorMessage = $null
            Errors = @()
        }
    }
    else {
        Write-Verbose "Validation failed with $($errors.Count) error(s)"
        return [PSCustomObject]@{
            IsValid = $false
            ErrorMessage = ($errors -join "; ")
            Errors = $errors
        }
    }
}