function Update-ModuleManifestVersion {
    <#
    .SYNOPSIS
    Updates the ModuleVersion in a PowerShell module manifest (.psd1) file.

    .DESCRIPTION
    Updates the ModuleVersion field in a PowerShell module manifest file using regex replacement.
    Optionally commits and pushes changes to Git with customizable commit message.

    .PARAMETER ManifestPath
    Path to the .psd1 manifest file to update.

    .PARAMETER NewVersion
    New semantic version (e.g., "1.2.3").

    .PARAMETER CommitChanges
    Whether to commit and push changes to Git. Default: $true.

    .PARAMETER SkipCI
    Whether to add [skip ci] to the commit message. Default: $true.

    .PARAMETER CommitMessage
    Custom commit message template. Use {version} placeholder for version substitution.
    Default: "chore: update manifest to {version}"

    .RETURNS
    PSCustomObject with operation results.

    .EXAMPLE
    Update-ModuleManifestVersion -ManifestPath './MyModule.psd1' -NewVersion '1.2.3'

    .EXAMPLE
    Update-ModuleManifestVersion -ManifestPath './MyModule.psd1' -NewVersion '1.2.3' -CommitChanges $false

    .EXAMPLE
    Update-ModuleManifestVersion -ManifestPath './MyModule.psd1' -NewVersion '1.2.3' -CommitMessage 'feat: bump to {version} [skip ci]'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath,

        [Parameter(Mandatory = $true)]
        [string]$NewVersion,

        [Parameter(Mandatory = $false)]
        [bool]$CommitChanges = $true,

        [Parameter(Mandatory = $false)]
        [bool]$SkipCI = $true,

        [Parameter(Mandatory = $false)]
        [string]$CommitMessage = "chore: update manifest to {version}"
    )

    Write-Host "🔄 Updating manifest version to $NewVersion..." -ForegroundColor Cyan

    # Step 1: Validate inputs
    Write-Verbose "Step 1: Validating inputs..."
    $validation = Test-ManifestVersion -ManifestPath $ManifestPath -NewVersion $NewVersion
    
    if (-not $validation.IsValid) {
        Write-Host "❌ MANIFEST UPDATE FAILED!" -ForegroundColor Red
        Write-Host ""
        Write-Host "⚠️  CRITICAL: Das Manifest konnte nicht aktualisiert werden." -ForegroundColor Yellow
        Write-Host "    Dies führt zu einem Konflikt zwischen Git-Tags und Manifest-Version."
        Write-Host ""
        Write-Host "📋 Mögliche Ursachen:" -ForegroundColor Cyan
        foreach ($error in $validation.Errors) {
            Write-Host "    • $error" -ForegroundColor Yellow
        }
        Write-Host ""
        Write-Host "🔧 Manuelle Lösung erforderlich:" -ForegroundColor Cyan
        Write-Host "    1. Prüfe $ManifestPath auf korrekte ModuleVersion-Syntax"
        Write-Host "    2. Aktualisiere ModuleVersion manuell auf '$NewVersion'"
        Write-Host "    3. Commit mit Message: 'chore: update manifest to $NewVersion [skip ci]'"
        Write-Host ""

        return [PSCustomObject]@{
            Success = $false
            OldVersion = $null
            NewVersion = $NewVersion
            ManifestPath = $ManifestPath
            ErrorMessage = $validation.ErrorMessage
        }
    }

    # Step 2: Read current manifest
    Write-Verbose "Step 2: Reading current manifest.."
    $readResult = Read-ManifestFile -ManifestPath $ManifestPath
    
    if (-not $readResult.Success) {
        Write-Host "❌ Failed to read manifest: $($readResult.ErrorMessage)" -ForegroundColor Red
        return [PSCustomObject]@{
            Success = $false
            OldVersion = $null
            NewVersion = $NewVersion
            ManifestPath = $ManifestPath
            ErrorMessage = $readResult.ErrorMessage
        }
    }

    $oldVersion = $readResult.CurrentVersion
    Write-Host "📋 Current version: $oldVersion" -ForegroundColor Gray

    # Step 3: Check for version downgrade (optional warning)
    if ($oldVersion) {
        try {
            $oldVersionObj = [version]($oldVersion -replace '-.*$', '')  # Strip pre-release suffix
            $newVersionObj = [version]($NewVersion -replace '-.*$', '')
            
            if ($newVersionObj -lt $oldVersionObj) {
                Write-Warning "⚠️  Version downgrade detected: $oldVersion → $NewVersion"
                Write-Warning "    This is unusual and may indicate a mistake."
            }
        }
        catch {
            # Version comparison failed (e.g., pre-release versions), continue anyway
            Write-Verbose "Could not compare versions (may include pre-release suffixes): $_"
        }
    }

    # Step 4: Update manifest file
    Write-Verbose "Step 3: Updating manifest file..."
    $writeResult = Write-ManifestFile -ManifestPath $ManifestPath -NewVersion $NewVersion -Content $readResult.Content
    
    if (-not $writeResult.Success) {
        Write-Host "❌ Failed to update manifest: $($writeResult.ErrorMessage)" -ForegroundColor Red
        return [PSCustomObject]@{
            Success = $false
            OldVersion = $oldVersion
            NewVersion = $NewVersion
            ManifestPath = $ManifestPath
            ErrorMessage = $writeResult.ErrorMessage
        }
    }

    Write-Host "✅ Manifest successfully updated to version $NewVersion" -ForegroundColor Green

    # Step 5: Git operations (if requested)
    if ($CommitChanges) {
        Write-Verbose "Step 4: Committing changes to Git..."
        Write-Host "📤 Committing and pushing changes..." -ForegroundColor Cyan

        try {
            # Prepare commit message
            $finalCommitMessage = $CommitMessage -replace '\{version\}', $NewVersion
            
            if ($SkipCI -and $finalCommitMessage -notmatch '\[skip ci\]') {
                $finalCommitMessage += " [skip ci]"
            }

            Write-Verbose "Commit message: $finalCommitMessage"

            # Git add
            $gitAddOutput = git add $ManifestPath 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Git add returned exit code $LASTEXITCODE"
                Write-Verbose "Git add output: $gitAddOutput"
            }

            # Git commit
            $gitCommitOutput = git commit -m $finalCommitMessage 2>&1
            if ($LASTEXITCODE -ne 0) {
                # Check if it's just "nothing to commit"
                if ($gitCommitOutput -match "nothing to commit") {
                    Write-Host "ℹ️  No changes to commit (manifest already at correct version)" -ForegroundColor Yellow
                }
                else {
                    throw "Git commit failed with exit code $LASTEXITCODE`: $gitCommitOutput"
                }
            }
            else {
                Write-Verbose "Git commit output: $gitCommitOutput"
            }

            # Git push
            $gitPushOutput = git push 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "Git push failed with exit code $LASTEXITCODE`: $gitPushOutput"
            }

            Write-Verbose "Git push output: $gitPushOutput"
            Write-Host "✅ Manifest changes committed and pushed" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Git operation failed: $_" -ForegroundColor Red
            Write-Host "⚠️  Manifest was updated locally but Git commit/push failed." -ForegroundColor Yellow
            Write-Host "    You may need to commit and push manually."
            
            return [PSCustomObject]@{
                Success = $false
                OldVersion = $oldVersion
                NewVersion = $NewVersion
                ManifestPath = $ManifestPath
                ErrorMessage = "Git operation failed: $_"
            }
        }
    }
    else {
        Write-Host "ℹ️  Skipping Git operations (CommitChanges=$CommitChanges)" -ForegroundColor Yellow
    }

    # Success!
    Write-Host "🎉 Manifest update completed successfully!" -ForegroundColor Green

    return [PSCustomObject]@{
        Success = $true
        OldVersion = $oldVersion
        NewVersion = $NewVersion
        ManifestPath = $ManifestPath
        ErrorMessage = $null
    }
}