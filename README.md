# K.PSGallery.ManifestVersioning

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/K.PSGallery.ManifestVersioning?logo=powershell&logoColor=white)](https://www.powershellgallery.com/packages/K.PSGallery.ManifestVersioning)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/K.PSGallery.ManifestVersioning?logo=powershell&logoColor=white)](https://www.powershellgallery.com/packages/K.PSGallery.ManifestVersioning)
[![GitHub Release](https://img.shields.io/github/v/release/GrexyLoco/K.PSGallery.ManifestVersioning?logo=github)](https://github.com/GrexyLoco/K.PSGallery.ManifestVersioning/releases)
[![License](https://img.shields.io/github/license/GrexyLoco/K.PSGallery.ManifestVersioning)](https://github.com/GrexyLoco/K.PSGallery.ManifestVersioning/blob/master/LICENSE)
[![CI/CD](https://img.shields.io/github/actions/workflow/status/GrexyLoco/K.PSGallery.ManifestVersioning/check_and_dispatch.yml?branch=master&label=CI%2FCD&logo=github)](https://github.com/GrexyLoco/K.PSGallery.ManifestVersioning/actions)

PowerShell module for safely updating module manifest (.psd1) versions with Git integration and comprehensive validation.

## 🎯 Features

✅ **Safe Manifest Updates**: Regex-based version replacement that preserves formatting  
✅ **Comprehensive Validation**: Syntax checking with `Test-ModuleManifest`  
✅ **Semantic Versioning**: Supports MAJOR.MINOR.PATCH format  
✅ **Downgrade Detection**: Warns when updating to lower version  
✅ **Git Integration**: Automatic commit and push with [skip ci] support  
✅ **Flexible Configuration**: Custom commit messages with {version} placeholder  
✅ **Detailed Error Messages**: German troubleshooting guidance with context  
✅ **Colored Console Output**: Visual feedback with emojis (🔄 ✅ ⚠️ ❌ 🎉)  
✅ **PowerShell 5.1+**: Compatible with Windows PowerShell and PowerShell Core  
✅ **Cross-Platform**: Works on Windows, Linux, and macOS  
✅ **No Dependencies**: Pure PowerShell implementation  
✅ **Tested**: 20 comprehensive tests with 100% pass rate

## 📦 Installation

### From PowerShell Gallery
```powershell
Install-Module -Name K.PSGallery.ManifestVersioning -Scope CurrentUser
```

### From GitHub (Latest Development)
```powershell
# Clone repository
git clone https://github.com/GrexyLoco/K.PSGallery.ManifestVersioning.git
cd K.PSGallery.ManifestVersioning

# Import module
Import-Module .\K.PSGallery.ManifestVersioning.psd1
```

### Verify Installation
```powershell
Get-Module K.PSGallery.ManifestVersioning -ListAvailable
Get-Command -Module K.PSGallery.ManifestVersioning
```

## 🚀 Quick Start

```powershell
# Import module
Import-Module K.PSGallery.ManifestVersioning

# Basic usage - update and commit
Update-ModuleManifestVersion -ManifestPath './MyModule.psd1' -NewVersion '1.2.3'
```

## 📖 Usage Examples

### Basic Usage
```powershell
# Simple version update with Git commit
$result = Update-ModuleManifestVersion `
    -ManifestPath './MyModule.psd1' `
    -NewVersion '1.2.3'

if ($result.Success) {
    Write-Host "✅ Updated from $($result.OldVersion) to $($result.NewVersion)"
}
```

### Custom Commit Message
```powershell
# Use {version} placeholder in commit message
Update-ModuleManifestVersion `
    -ManifestPath './MyModule.psd1' `
    -NewVersion '2.0.0' `
    -CommitMessage 'chore: bump to v{version} [skip ci]'
```

### No Git Integration
```powershell
# Update file only, skip Git operations
Update-ModuleManifestVersion `
    -ManifestPath './MyModule.psd1' `
    -NewVersion '1.2.3' `
    -CommitChanges $false
```

### Without [skip ci]
```powershell
# Trigger CI/CD after version update
Update-ModuleManifestVersion `
    -ManifestPath './MyModule.psd1' `
    -NewVersion '1.2.4' `
    -SkipCI $false
```

### Error Handling
```powershell
$result = Update-ModuleManifestVersion `
    -ManifestPath './MyModule.psd1' `
    -NewVersion '1.2.3'

if (-not $result.Success) {
    Write-Error "Update failed: $($result.ErrorMessage)"
    exit 1
}
```

## � API Reference

### Update-ModuleManifestVersion

Updates the ModuleVersion in a PowerShell module manifest (.psd1) file.

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `ManifestPath` | `[string]` | ✅ Yes | - | Path to the .psd1 manifest file |
| `NewVersion` | `[string]` | ✅ Yes | - | Semantic version (e.g., "1.2.3" or "1.0.0-alpha") |
| `CommitChanges` | `[bool]` | ❌ No | `$true` | Commit and push changes to Git |
| `SkipCI` | `[bool]` | ❌ No | `$true` | Add `[skip ci]` to commit message |
| `CommitMessage` | `[string]` | ❌ No | `"chore: update manifest to {version}"` | Custom commit message template (use `{version}` placeholder) |

#### Return Object

Returns a `PSCustomObject` with the following properties:

| Property | Type | Description |
|----------|------|-------------|
| `Success` | `[bool]` | Whether the operation succeeded |
| `OldVersion` | `[string]` | Previous module version (null if failed) |
| `NewVersion` | `[string]` | New module version (null if failed) |
| `ManifestPath` | `[string]` | Path to the updated manifest |
| `ErrorMessage` | `[string]` | Error details (null if successful) |

#### Version Format

Accepts semantic versions matching pattern: `MAJOR.MINOR.PATCH[-PRERELEASE]`

**Valid examples:**
- `1.0.0` (release version)
- `1.2.3` (patch update)
- `2.0.0-alpha` (pre-release)
- `1.0.0-beta.1` (pre-release with identifier)

**Invalid examples:**
- `1.0` (missing PATCH)
- `v1.0.0` (prefix not allowed)
- `1.0.0.0` (four components)

## 🔧 GitHub Actions Integration

### Basic Workflow Integration

```yaml
name: Update Module Version

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'New version (e.g., 1.2.3)'
        required: true

jobs:
  update-version:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          persist-credentials: true

      - name: Update Manifest Version
        shell: pwsh
        run: |
          Install-Module K.PSGallery.ManifestVersioning -Force -Scope CurrentUser
          Import-Module K.PSGallery.ManifestVersioning
          
          $result = Update-ModuleManifestVersion `
            -ManifestPath './MyModule.psd1' `
            -NewVersion '${{ inputs.version }}' `
            -CommitChanges $true `
            -SkipCI $true
          
          if (-not $result.Success) {
            Write-Error "Version update failed: $($result.ErrorMessage)"
            exit 1
          }
          
          Write-Host "✅ Updated from $($result.OldVersion) to $($result.NewVersion)"
```

### Advanced: Semantic Version Bumping

```yaml
- name: Get Next Version
  id: version
  uses: GrexyLoco/K.Actions.NextVersion@latest
  with:
    bump-type: 'patch'  # major, minor, or patch

- name: Update Manifest
  shell: pwsh
  run: |
    Install-Module K.PSGallery.ManifestVersioning -Force -Scope CurrentUser
    Update-ModuleManifestVersion `
      -ManifestPath './MyModule.psd1' `
      -NewVersion '${{ steps.version.outputs.newVersion }}'
```

### Use in Reusable Action

See [K.Actions.UpdatePSD1Version](https://github.com/GrexyLoco/K.Actions.UpdatePSD1Version) for a GitHub Action wrapper around this module.

## 🛡️ Error Handling

The module provides detailed, colored error messages with actionable troubleshooting steps.

### Common Error Scenarios

| Error | Cause | Solution |
|-------|-------|----------|
| **Manifest file not found** | Invalid path or file doesn't exist | Verify path with `Test-Path` |
| **Invalid manifest syntax** | Corrupted .psd1 or syntax errors | Run `Test-ModuleManifest` manually |
| **ModuleVersion not found** | Missing or malformed ModuleVersion field | Ensure format: `ModuleVersion = '1.0.0'` |
| **Git operation failed** | No Git repo or network issues | Check `git status` and remote connectivity |
| **Version downgrade detected** | New version < current version | Intended? Warnings shown but continues |

### Error Output Format

When an error occurs, the function returns a structured result:

```powershell
@{
    Success      = $false
    OldVersion   = '1.0.0'  # or $null if read failed
    NewVersion   = $null
    ManifestPath = 'C:\path\to\MyModule.psd1'
    ErrorMessage = 'Detailed error description'
}
```

### Example: Critical Manifest Update Failure

```
❌ MANIFEST UPDATE FAILED!

⚠️  CRITICAL: Das Manifest konnte nicht aktualisiert werden.
    Dies führt zu einem Konflikt zwischen Git-Tags und Manifest-Version.

📋 Mögliche Ursachen:
    • ModuleVersion-Format im Manifest ist ungültig
    • Regex-Pattern konnte Version nicht finden
    • Datei ist schreibgeschützt

🔧 Manuelle Lösung erforderlich:
    1. Prüfe MyModule.psd1 auf korrekte ModuleVersion-Syntax
    2. Aktualisiere ModuleVersion manuell auf '1.2.3'
    3. Commit mit Message: 'chore: update manifest to 1.2.3 [skip ci]'
```

### Downgrade Warning Example

```
⚠️  WARNING: Version downgrade detected!
    Current: 1.2.3
    New:     1.0.0
    
    This is usually unintended. Continuing anyway...
```

## 📋 Requirements

- **PowerShell**: 5.1 or later (Windows PowerShell or PowerShell Core)
- **Git**: Required only if using `-CommitChanges $true` (default)
- **Platforms**: Windows, Linux, macOS
- **Dependencies**: None (uses built-in cmdlets only)

## 🧪 Testing

This module has comprehensive test coverage with **20 Pester tests** (100% pass rate).

### Run Tests Locally

```powershell
# Install Pester if not already installed
Install-Module Pester -MinimumVersion 5.0 -Force

# Run all tests
Invoke-Pester .\Tests\K.PSGallery.ManifestVersioning.Tests.ps1

# Run with detailed output
Invoke-Pester .\Tests\K.PSGallery.ManifestVersioning.Tests.ps1 -Output Detailed
```

### Test Coverage

- ✅ Module loading and function export (3 tests)
- ✅ Basic version updates: patch, minor, major (6 tests)
- ✅ Invalid inputs: downgrade, bad format, missing file (4 tests)
- ✅ Edge cases: large versions, formatting preservation (3 tests)
- ✅ Private function accessibility (3 tests)
- ✅ Real-world scenarios: 0.x→1.0.0, large versions (1 test)

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/my-feature`
3. **Make** your changes with clear commit messages
4. **Add tests** for new functionality (maintain 100% pass rate)
5. **Test** locally: `Invoke-Pester .\Tests\`
6. **Submit** a pull request with a clear description

### Code Style

- Use PowerShell best practices (PSScriptAnalyzer compliant)
- Follow existing naming conventions
- Add comment-based help for new functions
- Use colored console output for user feedback

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

Part of the **K.PSGallery ecosystem**:

- **[K.Actions.UpdatePSD1Version](https://github.com/GrexyLoco/K.Actions.UpdatePSD1Version)** - GitHub Action wrapper for this module
- **[K.Actions.NextVersion](https://github.com/GrexyLoco/K.Actions.NextVersion)** - Semantic version calculation and analysis
- **[K.Actions.CreateVersionTag](https://github.com/GrexyLoco/K.Actions.CreateVersionTag)** - GitHub Action for Git tagging
- **[K.PSGallery.GitTagging](https://github.com/GrexyLoco/K.PSGallery.GitTagging)** - PowerShell module for Git tag creation with conflict detection
- **[K.PSGallery](https://github.com/GrexyLoco/K.PSGallery)** - Automated PSGallery publishing dispatcher

## 🛠️ Development Setup

### Repository Variables

Configure these in your GitHub repository:

| Variable | Description | Example |
|----------|-------------|---------|
| `UBUNTU_VERSION` | Ubuntu runner version | `ubuntu-latest` or `ubuntu-22.04` |

### Repository Secrets

| Secret | Description | Scope |
|--------|-------------|-------|
| `GITHUB_TOKEN` | Automatically provided by GitHub Actions | Read/write repo access |
| `REPO_DISPATCH_TOKEN` | Personal Access Token for cross-repo dispatch | `repo` scope |

### Workflow Configuration

The module uses `.github/workflows/check_and_dispatch.yml` for CI/CD:

- **Quality Gate**: Pester tests via `K.Actions.PSModuleValidation@v1`
- **Release**: GitHub release creation with smart tags
- **Dispatch**: Triggers PSGallery publish in K.PSGallery dispatcher repo

**Required permissions**:
```yaml
permissions:
  contents: write
  pull-requests: write
```

---

**Developed with ❤️ by [GrexyLoco](https://github.com/GrexyLoco)** | Part of the K.PSGallery ecosystem 🚀
