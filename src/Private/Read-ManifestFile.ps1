function Read-ManifestFile {
    <#
    .SYNOPSIS
    Reads a PowerShell module manifest file and extracts the current ModuleVersion.

    .DESCRIPTION
    Reads the content of a .psd1 manifest file and uses regex to extract the current ModuleVersion value.

    .PARAMETER ManifestPath
    Path to the .psd1 manifest file to read.

    .RETURNS
    PSCustomObject with the current version and file content.

    .EXAMPLE
    Read-ManifestFile -ManifestPath './MyModule.psd1'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath
    )

    Write-Verbose "Reading manifest file: $ManifestPath"

    # Check if file exists
    if (-not (Test-Path -Path $ManifestPath)) {
        Write-Error "Manifest file not found: $ManifestPath"
        return [PSCustomObject]@{
            Success = $false
            CurrentVersion = $null
            Content = $null
            ErrorMessage = "Manifest file not found: $ManifestPath"
        }
    }

    try {
        # Read the entire file content
        $content = Get-Content -Path $ManifestPath -Raw -ErrorAction Stop
        
        Write-Verbose "File content read successfully (${content.Length} characters)"

        # Extract ModuleVersion using regex
        # Matches patterns like: ModuleVersion = '1.0.0' or ModuleVersion='1.0.0' or ModuleVersion = "1.0.0"
        if ($content -match "ModuleVersion\s*=\s*['\`"]([^'\`"]+)['\`"]") {
            $currentVersion = $matches[1]
            Write-Verbose "Extracted ModuleVersion: $currentVersion"

            return [PSCustomObject]@{
                Success = $true
                CurrentVersion = $currentVersion
                Content = $content
                ErrorMessage = $null
            }
        }
        else {
            Write-Error "ModuleVersion field not found in manifest: $ManifestPath"
            return [PSCustomObject]@{
                Success = $false
                CurrentVersion = $null
                Content = $content
                ErrorMessage = "ModuleVersion field not found in manifest"
            }
        }
    }
    catch {
        Write-Error "Failed to read manifest file: $_"
        return [PSCustomObject]@{
            Success = $false
            CurrentVersion = $null
            Content = $null
            ErrorMessage = "Failed to read manifest file: $_"
        }
    }
}