$script:dscModuleName = 'xActiveDirectory'
$script:dscResourceName = 'MSFT_xADReplicationSite'

#region HEADER

# Unit Test Template Version: 1.2.4
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType Unit

#endregion HEADER

function Invoke-TestSetup
{
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

# Begin Testing
try
{
    Invoke-TestSetup

    InModuleScope $script:dscResourceName {
        #region Pester Test Initialization
        $presentSiteName = 'DemoSite'
        $absentSiteName  = 'MissingSite'

        $presentSiteMock = [PSCustomObject] @{
            Name              = $presentSiteName
            DistinguishedName = "CN=$presentSiteName,CN=Sites,CN=Configuration,DC=contoso,DC=com"
        }

        $defaultFirstSiteNameSiteMock = [PSCustomObject] @{
            Name              = 'Default-First-Site-Name'
            DistinguishedName = "CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=contoso,DC=com"
        }

        $presentSiteTestPresent = @{
            Ensure = 'Present'
            Name   = $presentSiteName
        }
        $presentSiteTestAbsent = @{
            Ensure = 'Absent'
            Name   = $presentSiteName
        }

        $absentSiteTestPresent = @{
            Ensure = 'Present'
            Name   = $absentSiteName
        }
        $absentSiteTestAbsent = @{
            Ensure = 'Absent'
            Name   = $absentSiteName
        }

        $presentSiteTestPresentRename = @{
            Ensure                     = 'Present'
            Name                       = $presentSiteName
            RenameDefaultFirstSiteName = $true
        }
        # #endregion

        #region Function Get-TargetResource
        Describe 'xADReplicationSite\Get-TargetResource' {
            It 'Should return a "System.Collections.Hashtable" object type' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite' -MockWith { $presentSiteMock }

                # Act
                $targetResource = Get-TargetResource -Name $presentSiteName

                # Assert
                $targetResource -is [System.Collections.Hashtable] | Should -Be $true
            }

            It 'Should return present if the site exists' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite' -MockWith { $presentSiteMock }

                # Act
                $targetResource = Get-TargetResource -Name $presentSiteName

                # Assert
                $targetResource.Ensure | Should -Be 'Present'
                $targetResource.Name   | Should -Be $presentSiteName
            }

            It 'Should return absent if the site does not exist' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite'

                # Act
                $targetResource = Get-TargetResource -Name $absentSiteName

                # Assert
                $targetResource.Ensure | Should -Be 'Absent'
                $targetResource.Name   | Should -Be $absentSiteName
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'xADReplicationSite\Test-TargetResource' {
            It 'Should return a "System.Boolean" object type' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite' -MockWith { $presentSiteMock }

                # Act
                $targetResourceState = Test-TargetResource @presentSiteTestPresent

                # Assert
                $targetResourceState -is [System.Boolean] | Should -Be $true
            }

            It 'Should return true if the site should exists and does exists' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite' -MockWith { $presentSiteMock }

                # Act
                $targetResourceState = Test-TargetResource @presentSiteTestPresent

                # Assert
                $targetResourceState | Should -Be $true
            }

            It 'Should return false if the site should exists but does not exists' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite'

                # Act
                $targetResourceState = Test-TargetResource @absentSiteTestPresent

                # Assert
                $targetResourceState | Should -Be $false
            }

            It 'Should return false if the site should not exists but does exists' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite' -MockWith { $presentSiteMock }

                # Act
                $targetResourceState = Test-TargetResource @presentSiteTestAbsent

                # Assert
                $targetResourceState | Should -Be $false
            }

            It 'Should return true if the site should not exists and does not exists' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite'

                # Act
                $targetResourceState = Test-TargetResource @absentSiteTestAbsent

                # Assert
                $targetResourceState | Should -Be $true
            }
        }

        #endregion

        #region Function Set-TargetResource
        Describe 'xADReplicationSite\Set-TargetResource' {
            It 'Should add a new site' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite'
                Mock -CommandName 'New-ADReplicationSite' -Verifiable

                # Act
                Set-TargetResource @presentSiteTestPresent

                # Assert
                Assert-MockCalled -CommandName 'New-ADReplicationSite' -Times 1 -Scope It
            }

            It 'Should rename the Default-First-Site-Name if it exists' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite' -MockWith { $defaultFirstSiteNameSiteMock }
                Mock -CommandName 'Rename-ADObject' -Verifiable
                Mock -CommandName 'New-ADReplicationSite' -Verifiable

                # Act
                Set-TargetResource @presentSiteTestPresentRename

                # Assert
                Assert-MockCalled -CommandName 'Rename-ADObject' -Times 1 -Scope It
                Assert-MockCalled -CommandName 'New-ADReplicationSite' -Times 0 -Scope It
            }

            It 'Should add a new site if the Default-First-Site-Name does not exist' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite'
                Mock -CommandName 'Rename-ADObject' -Verifiable
                Mock -CommandName 'New-ADReplicationSite' -Verifiable

                # Act
                Set-TargetResource @presentSiteTestPresentRename

                # Assert
                Assert-MockCalled -CommandName 'Rename-ADObject' -Times 0 -Scope It
                Assert-MockCalled -CommandName 'New-ADReplicationSite' -Times 1 -Scope It
            }

            It 'Should remove an existing site' {

                # Arrange
                Mock -CommandName 'Get-ADReplicationSite' -MockWith { $presentSiteMock }
                Mock -CommandName 'Remove-ADReplicationSite' -Verifiable

                # Act
                Set-TargetResource @presentSiteTestAbsent

                # Assert
                Assert-MockCalled -CommandName 'Remove-ADReplicationSite' -Times 1 -Scope It
            }
        }
        #endregion
    }
    #endregion
}
finally
{
    Invoke-TestCleanup
}
