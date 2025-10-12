BeforeAll {
    # Import the module
    Import-Module "$PSScriptRoot/../K.PSGallery.ManifestVersioning.psd1" -Force
}

Describe 'K.PSGallery.ManifestVersioning Module' {
    Context 'Module Loading' {
        It 'Should load module successfully' {
            Get-Module K.PSGallery.ManifestVersioning | Should -Not -BeNullOrEmpty
        }

        It 'Should export Update-ModuleManifestVersion function' {
            Get-Command -Module K.PSGallery.ManifestVersioning -Name Update-ModuleManifestVersion | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Update-ModuleManifestVersion' {
        BeforeEach {
            # Create temporary test manifest
            $script:testManifestPath = Join-Path $TestDrive "TestModule.psd1"
            $testManifest = @'
@{
    ModuleVersion = '0.1.0'
    GUID = 'test-guid-1234'
    Author = 'Test'
    Description = 'Test manifest'
    FunctionsToExport = @()
}
'@
            Set-Content -Path $script:testManifestPath -Value $testManifest
        }

        It 'Should be available as exported function' {
            Get-Command Update-ModuleManifestVersion | Should -Not -BeNullOrEmpty
        }

        # TODO: Add more tests after implementation
        It 'Should return warning for not implemented function' {
            { Update-ModuleManifestVersion -ManifestPath $script:testManifestPath -NewVersion '1.0.0' -CommitChanges $false } | Should -Not -Throw
        }
    }

    Context 'Private Functions' {
        It 'Test-ManifestVersion should be available via dot-sourcing' {
            InModuleScope K.PSGallery.ManifestVersioning {
                Get-Command Test-ManifestVersion | Should -Not -BeNullOrEmpty
            }
        }

        It 'Read-ManifestFile should be available via dot-sourcing' {
            InModuleScope K.PSGallery.ManifestVersioning {
                Get-Command Read-ManifestFile | Should -Not -BeNullOrEmpty
            }
        }

        It 'Write-ManifestFile should be available via dot-sourcing' {
            InModuleScope K.PSGallery.ManifestVersioning {
                Get-Command Write-ManifestFile | Should -Not -BeNullOrEmpty
            }
        }
    }
}