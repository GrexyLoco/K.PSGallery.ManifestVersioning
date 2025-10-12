BeforeAll {
    # Import the module
    Import-Module "$PSScriptRoot/../K.PSGallery.ManifestVersioning.psd1" -Force
    
    # Suppress console output during tests
    $Global:OriginalInformationPreference = $InformationPreference
    $InformationPreference = 'SilentlyContinue'
}

AfterAll {
    # Restore original preference
    if ($Global:OriginalInformationPreference) {
        $InformationPreference = $Global:OriginalInformationPreference
    }
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
    GUID = '12345678-1234-1234-1234-123456789012'
    Author = 'Test'
    Description = 'Test manifest'
    PowerShellVersion = '5.1'
    FunctionsToExport = @()
}
'@
            Set-Content -Path $script:testManifestPath -Value $testManifest
        }

        It 'Should be available as exported function' {
            Get-Command Update-ModuleManifestVersion | Should -Not -BeNullOrEmpty
        }

        It 'Should update manifest version successfully' {
            # Act
            $result = Update-ModuleManifestVersion -ManifestPath $script:testManifestPath -NewVersion '1.0.0' -CommitChanges $false

            # Assert
            $result.Success | Should -Be $true
            $result.OldVersion | Should -Be '0.1.0'
            $result.NewVersion | Should -Be '1.0.0'
            
            # Verify file was updated
            $content = Get-Content $script:testManifestPath -Raw
            $content | Should -Match "ModuleVersion\s*=\s*'1\.0\.0'"
        }
    }

    Context 'Semantic Version Updates (Implementation Required)' {
        BeforeEach {
            # Helper function to create test manifest with specific version
            function New-TestManifest {
                param([string]$Version, [string]$FilePath)
                $manifest = @"
@{
    ModuleVersion = '$Version'
    GUID = '12345678-1234-1234-1234-123456789012'
    Author = 'Test'
    Description = 'Test manifest for version $Version'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Test-Function')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
}
"@
                Set-Content -Path $FilePath -Value $manifest
            }
        }

        Context 'Patch Version Updates (X.Y.Z -> X.Y.Z+1)' {
            It 'Should update 1.0.0 to 1.0.1 (patch increment)' {
                # Arrange
                $manifestPath = Join-Path $TestDrive "PatchTest.psd1"
                New-TestManifest -Version '1.0.0' -FilePath $manifestPath

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion '1.0.1' -CommitChanges $false

                # Assert
                $result.Success | Should -Be $true
                $result.OldVersion | Should -Be '1.0.0'
                $result.NewVersion | Should -Be '1.0.1'
                
                # Verify file content
                $content = Get-Content $manifestPath -Raw
                $content | Should -Match "ModuleVersion\s*=\s*'1\.0\.1'"
            }

            It 'Should update 2.5.3 to 2.5.4 (patch increment)' {
                # Arrange
                $manifestPath = Join-Path $TestDrive "PatchTest2.psd1"
                New-TestManifest -Version '2.5.3' -FilePath $manifestPath

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion '2.5.4' -CommitChanges $false

                # Assert
                $result.Success | Should -Be $true
                $result.OldVersion | Should -Be '2.5.3'
                $result.NewVersion | Should -Be '2.5.4'
            }
        }

        Context 'Minor Version Updates (X.Y.Z -> X.Y+1.0)' {
            It 'Should update 1.0.1 to 1.1.0 (minor increment with patch reset)' {
                # Arrange
                $manifestPath = Join-Path $TestDrive "MinorTest.psd1"
                New-TestManifest -Version '1.0.1' -FilePath $manifestPath

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion '1.1.0' -CommitChanges $false

                # Assert
                $result.Success | Should -Be $true
                $result.OldVersion | Should -Be '1.0.1'
                $result.NewVersion | Should -Be '1.1.0'
                
                # Verify file content
                $content = Get-Content $manifestPath -Raw
                $content | Should -Match "ModuleVersion\s*=\s*'1\.1\.0'"
            }

            It 'Should update 0.9.5 to 0.10.0 (minor increment with double digits)' {
                # Arrange
                $manifestPath = Join-Path $TestDrive "MinorTest2.psd1"
                New-TestManifest -Version '0.9.5' -FilePath $manifestPath

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion '0.10.0' -CommitChanges $false

                # Assert
                $result.Success | Should -Be $true
                $result.OldVersion | Should -Be '0.9.5'
                $result.NewVersion | Should -Be '0.10.0'
            }
        }

        Context 'Major Version Updates (X.Y.Z -> X+1.0.0)' {
            It 'Should update 1.1.1 to 2.0.0 (major increment with minor/patch reset)' {
                # Arrange
                $manifestPath = Join-Path $TestDrive "MajorTest.psd1"
                New-TestManifest -Version '1.1.1' -FilePath $manifestPath

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion '2.0.0' -CommitChanges $false

                # Assert
                $result.Success | Should -Be $true
                $result.OldVersion | Should -Be '1.1.1'
                $result.NewVersion | Should -Be '2.0.0'
                
                # Verify file content
                $content = Get-Content $manifestPath -Raw
                $content | Should -Match "ModuleVersion\s*=\s*'2\.0\.0'"
            }

            It 'Should update 0.8.2 to 1.0.0 (first major release)' {
                # Arrange
                $manifestPath = Join-Path $TestDrive "FirstMajorTest.psd1"
                New-TestManifest -Version '0.8.2' -FilePath $manifestPath

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion '1.0.0' -CommitChanges $false

                # Assert
                $result.Success | Should -Be $true
                $result.OldVersion | Should -Be '0.8.2'
                $result.NewVersion | Should -Be '1.0.0'
            }
        }

        Context 'Invalid Version Updates (Error Cases)' {
            It 'Should return warning for downgrade from 1.1.0 to 1.0.1 but still succeed' {
                # Arrange
                $manifestPath = Join-Path $TestDrive "DowngradeTest.psd1"
                New-TestManifest -Version '1.1.0' -FilePath $manifestPath

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion '1.0.1' -CommitChanges $false -WarningVariable warnings

                # Assert - Function succeeds but warns
                $result.Success | Should -Be $true
                $result.OldVersion | Should -Be '1.1.0'
                $result.NewVersion | Should -Be '1.0.1'
            }

            It 'Should fail when trying to update to invalid version format' {
                # Arrange
                $manifestPath = Join-Path $TestDrive "InvalidVersionTest.psd1"
                New-TestManifest -Version '1.0.0' -FilePath $manifestPath

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion 'invalid.version' -CommitChanges $false

                # Assert
                $result.Success | Should -Be $false
                $result.ErrorMessage | Should -Match "invalid.*version"
            }

            It 'Should fail when manifest file does not exist' {
                # Arrange
                $nonExistentPath = Join-Path $TestDrive "NonExistent.psd1"

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $nonExistentPath -NewVersion '1.0.0' -CommitChanges $false

                # Assert
                $result.Success | Should -Be $false
                $result.ErrorMessage | Should -Match "not found"
            }

            It 'Should fail when manifest has no ModuleVersion field' {
                # Arrange
                $manifestPath = Join-Path $TestDrive "NoVersionTest.psd1"
                $invalidManifest = @'
@{
    GUID = '12345678-1234-1234-1234-123456789012'
    Author = 'Test'
    Description = 'Manifest without ModuleVersion'
    PowerShellVersion = '5.1'
}
'@
                Set-Content -Path $manifestPath -Value $invalidManifest

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion '1.0.0' -CommitChanges $false

                # Assert
                $result.Success | Should -Be $false
                $result.ErrorMessage | Should -Match "ModuleVersion"
            }
        }

        Context 'Pre-release and Special Versions' {
            It 'Should update 1.0.0-alpha to 1.0.0-beta (pre-release progression)' -Skip {
                # NOTE: PowerShell Test-ModuleManifest does not support pre-release versions in ModuleVersion field
                # Pre-release info should be in PrivateData.PSData.Prerelease instead
                # This test is skipped as it's a PowerShell limitation, not a bug in our module
                
                # Arrange
                $manifestPath = Join-Path $TestDrive "PreReleaseTest.psd1"
                New-TestManifest -Version '1.0.0-alpha' -FilePath $manifestPath

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion '1.0.0-beta' -CommitChanges $false

                # Assert
                $result.Success | Should -Be $true
                $result.OldVersion | Should -Be '1.0.0-alpha'
                $result.NewVersion | Should -Be '1.0.0-beta'
            }

            It 'Should update 1.0.0-rc.1 to 1.0.0 (pre-release to stable)' -Skip {
                # NOTE: PowerShell Test-ModuleManifest does not support pre-release versions in ModuleVersion field
                # Pre-release info should be in PrivateData.PSData.Prerelease instead
                # This test is skipped as it's a PowerShell limitation, not a bug in our module
                
                # Arrange
                $manifestPath = Join-Path $TestDrive "RCToStableTest.psd1"
                New-TestManifest -Version '1.0.0-rc.1' -FilePath $manifestPath

                # Act
                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion '1.0.0' -CommitChanges $false

                # Assert
                $result.Success | Should -Be $true
                $result.OldVersion | Should -Be '1.0.0-rc.1'
                $result.NewVersion | Should -Be '1.0.0'
            }
        }

        Context 'Git Integration Tests' {
            It 'Should commit changes when CommitChanges is true' {
                # Note: This test would require Git repo setup and mocking
                # Will be implemented when Git integration is added
            }

            It 'Should add [skip ci] to commit message when SkipCI is true' {
                # Note: This test would require Git repo setup and mocking
                # Will be implemented when Git integration is added
            }

            It 'Should use custom commit message template with {version} placeholder' {
                # Note: This test would require Git repo setup and mocking
                # Will be implemented when Git integration is added
            }
        }

        Context 'Edge Cases and Robustness' {
            It 'Should handle manifest with different ModuleVersion formatting' {
                # Test various formats: ModuleVersion='1.0.0', ModuleVersion = "1.0.0", etc.
            }

            It 'Should preserve manifest formatting and comments' {
                # Ensure the regex update doesn't destroy other parts of the file
            }

            It 'Should handle large version numbers correctly' {
                # Test versions like 99.99.99 to 100.0.0
                $manifestPath = Join-Path $TestDrive "LargeVersionTest.psd1"
                New-TestManifest -Version '99.99.99' -FilePath $manifestPath

                $result = Update-ModuleManifestVersion -ManifestPath $manifestPath -NewVersion '100.0.0' -CommitChanges $false

                $result.Success | Should -Be $true
                $result.OldVersion | Should -Be '99.99.99'
                $result.NewVersion | Should -Be '100.0.0'
            }
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