# K.PSGallery.ManifestVersioning

PowerShell module for updating module manifest (.psd1) versions with Git integration - Part of K.PSGallery ecosystem

## 🎯 Features

- ✅ **Safe Manifest Updates**: Regex-based version updates with validation
- ✅ **Git Integration**: Automatic commit and push with customizable messages
- ✅ **Error Handling**: Detailed error messages with troubleshooting guidance
- ✅ **Flexible Configuration**: Skip CI, custom commit messages, validation options
- ✅ **PowerShell 5.1+**: Compatible with Windows PowerShell and PowerShell Core

## 📦 Installation

### From PowerShell Gallery (Recommended)
```powershell
Install-Module -Name K.PSGallery.ManifestVersioning -Force
```

### From GitHub (Development)
```powershell
git clone https://github.com/GrexyLoco/K.PSGallery.ManifestVersioning.git
Import-Module .\K.PSGallery.ManifestVersioning\K.PSGallery.ManifestVersioning.psd1
```

## 🚀 Usage

### Basic Usage
```powershell
Import-Module K.PSGallery.ManifestVersioning

# Update manifest version
Update-ModuleManifestVersion -ManifestPath './MyModule.psd1' -NewVersion '1.2.3'
```

### Advanced Usage
```powershell
# Update with custom commit message and skip CI
Update-ModuleManifestVersion `
    -ManifestPath './MyModule.psd1' `
    -NewVersion '1.2.3' `
    -CommitChanges $true `
    -SkipCI $true `
    -CommitMessage 'chore: bump version to {version} [skip ci]'
```

### No Git Integration
```powershell
# Update file only, no Git operations
Update-ModuleManifestVersion `
    -ManifestPath './MyModule.psd1' `
    -NewVersion '1.2.3' `
    -CommitChanges $false
```

## 📚 Functions

### `Update-ModuleManifestVersion`

Updates the ModuleVersion field in a PowerShell module manifest (.psd1) file.

**Parameters:**
- `ManifestPath` (string, mandatory): Path to the .psd1 manifest file
- `NewVersion` (string, mandatory): New semantic version (e.g., "1.2.3")
- `CommitChanges` (bool, optional, default: $true): Commit and push changes to Git
- `SkipCI` (bool, optional, default: $true): Add [skip ci] to commit message
- `CommitMessage` (string, optional): Custom commit message template (use {version} placeholder)

**Returns:** PSCustomObject with:
- `Success` (bool): Whether the operation succeeded
- `OldVersion` (string): Previous version in manifest
- `NewVersion` (string): New version in manifest
- `ManifestPath` (string): Path to the manifest file
- `ErrorMessage` (string): Error message if operation failed

## 🔧 Integration with GitHub Actions

This module is designed to work seamlessly with GitHub Actions:

```yaml
- name: Update Manifest Version
  shell: pwsh
  run: |
    Install-Module K.PSGallery.ManifestVersioning -Force
    Import-Module K.PSGallery.ManifestVersioning
    Update-ModuleManifestVersion -ManifestPath './MyModule.psd1' -NewVersion '${{ steps.version.outputs.newVersion }}'
```

## 🛡️ Error Handling

The module provides detailed error messages for common scenarios:

- **Manifest file not found**
- **Invalid manifest syntax**
- **ModuleVersion field not found**
- **Git operation failures**
- **File permission issues**

Example error output:
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

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- **[K.Actions.UpdatePSD1Version](https://github.com/GrexyLoco/K.Actions.UpdatePSD1Version)**: GitHub Action wrapper for this module
- **[K.Actions.NextVersion](https://github.com/GrexyLoco/K.Actions.NextVersion)**: Semantic version calculation
- **[K.PSGallery.GitTagging](https://github.com/GrexyLoco/K.PSGallery.GitTagging)**: Git tag creation with conflict detection

---

**Part of the K.PSGallery ecosystem** 🚀
