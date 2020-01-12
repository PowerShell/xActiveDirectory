$script:dscModuleName = 'ActiveDirectoryDsc'
$script:dscResourceName = 'MSFT_ADReplicationSite'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

# Begin Testing

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        # Load stub cmdlets and classes.
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\ActiveDirectory_2019.psm1') -Force

        $presentSiteName    = 'DemoSite'
        $absentSiteName     = 'MissingSite'
        $genericDescription = "Demonstration Site Description"

        $presentSiteMock = [PSCustomObject] @{
            Name              = $presentSiteName
            DistinguishedName = "CN=$presentSiteName,CN=Sites,CN=Configuration,DC=contoso,DC=com"
            Description       = $genericDescription
        }

        $defaultFirstSiteNameSiteMock = [PSCustomObject] @{
            Name              = 'Default-First-Site-Name'
            DistinguishedName = "CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=contoso,DC=com"
        }

        $absentSiteDefaultRenameMock = @{
            Ensure                     = 'Absent'
            Name                       = $presentSiteTestPresent
            Description                = $null
            RenameDefaultFirstSiteName = $true
        }

        $presentSiteTestPresent = @{
            Ensure      = 'Present'
            Name        = $presentSiteName
            Description = $genericDescription
        }

        $presentSiteTestPresentEmptyDescription = @{
            Ensure      = 'Present'
            Name        = $presentSiteName
            Description = $null
        }

        $presentSiteTestNoDescription = @{
            Ensure      = 'Present'
            Name        = $presentSiteName
        }

        $presentSiteTestAbsent = @{
            Ensure = 'Absent'
            Name   = $presentSiteName
            Description = $genericDescription
        }

        $presentSiteTestMismatchDescription = @{
            Ensure = 'Present'
            Name   = $presentSiteName
            Description = 'Some random test description'
        }

        $absentSiteTestPresent = @{
            Ensure = 'Present'
            Name   = $absentSiteName
            Description = $genericDescription
        }
        $absentSiteTestAbsent = @{
            Ensure = 'Absent'
            Name   = $absentSiteName
            Description = $genericDescription
        }

        $presentSiteTestPresentRename = @{
            Ensure                     = 'Present'
            Name                       = $presentSiteName
            Description                = $genericDescription
            RenameDefaultFirstSiteName = $true
        }

        #region Function Get-TargetResource
        Describe 'When getting the Target Resource Information' {
            It 'Should return a "System.Collections.Hashtable" object type with specified attributes' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite -MockWith { $presentSiteMock }

                # Act
                $targetResource = Get-TargetResource -Name $presentSiteName

                # Assert
                $targetResource -is [System.Collections.Hashtable] | Should -BeTrue
                $targetResource.Description | Should -BeOfType String
                $targetResource.Name | Should -Not -BeNullOrEmpty
                $targetResource.Ensure | Should -Not -BeNullOrEmpty
            }

            It 'Should return present if the site exists' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite -MockWith { $presentSiteMock }

                # Act
                $targetResource = Get-TargetResource -Name $presentSiteName

                # Assert
                $targetResource.Ensure | Should -Be 'Present'
                $targetResource.Name   | Should -Be $presentSiteName
                $targetResource.Description | Should -Be $genericDescription
            }

            It 'Should return absent if the site does not exist' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite

                # Act
                $targetResource = Get-TargetResource -Name $absentSiteName

                # Assert
                $targetResource.Ensure | Should -Be 'Absent'
                $targetResource.Name   | Should -Be $absentSiteName
                $targetResource.Description | Should -BeNullOrEmpty
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'When testing the Target Resource configuration' {
            It 'Should return a "System.Boolean" object type' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite -MockWith { $presentSiteMock }

                # Act
                $targetResourceState = Test-TargetResource @presentSiteTestPresent

                # Assert
                $targetResourceState -is [System.Boolean] | Should -BeTrue
            }

            It 'Should return true if the site should exist and does exist' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite -MockWith { $presentSiteMock }

                # Act
                $targetResourceState = Test-TargetResource @presentSiteTestPresent

                # Assert
                $targetResourceState | Should -BeTrue
            }

            It 'Should return false if the site should exist but does not exist' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite

                # Act
                $targetResourceState = Test-TargetResource @absentSiteTestPresent

                # Assert
                $targetResourceState | Should -BeFalse
            }

            It 'Should return false if the site should not exist but does exist' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite -MockWith { $presentSiteMock }

                # Act
                $targetResourceState = Test-TargetResource @presentSiteTestAbsent

                # Assert
                $targetResourceState | Should -BeFalse
            }

            It 'Should return true if the site should not exist and does not exist' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite

                # Act
                $targetResourceState = Test-TargetResource @absentSiteTestAbsent

                # Assert
                $targetResourceState | Should -BeTrue
            }

            It 'Should return false if the site exists but the description is mismatched' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite { $presentSiteTestPresent }

                # Act
                $targetResourceState = Test-TargetResource @presentSiteTestMismatchDescription

                # Assert
                $targetResourceState | Should -BeFalse
            }

            It 'Should return true if the site exists with description set, but no description is defined' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite { $presentSiteTestPresentEmptyDescription }

                # Act
                $targetResourceState = Test-TargetResource @presentSiteTestNoDescription

                # Assert
                $targetResourceState | Should -BeTrue
            }

            It 'Should return true if the site exists with no description set, and no description defined' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite { $presentSiteTestPresent }

                # Act
                $targetResourceState = Test-TargetResource @presentSiteTestNoDescription

                # Assert
                $targetResourceState | Should -BeTrue
            }
        }

        #endregion

        #region Function Set-TargetResource
        Describe 'ADReplicationSite\Set-TargetResource' {
            It 'Should add a new site' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite
                Mock -CommandName 'New-ADReplicationSite' -Verifiable
                Mock -CommandName 'Set-ADReplicationSite' -Verifiable

                # Act
                Set-TargetResource @presentSiteTestPresent

                # Assert
                Assert-MockCalled -CommandName 'New-ADReplicationSite' -Times 1 -Scope It
            }

            It 'Should rename the Default-First-Site-Name if it exists' {

                # Arrange
                Mock -CommandName Get-TargetResource -MockWith { $absentSiteDefaultRenameMock }
                Mock -CommandName Get-ADReplicationSite -MockWith { $defaultFirstSiteNameSiteMock }
                Mock -CommandName 'Rename-ADObject' -Verifiable
                Mock -CommandName 'New-ADReplicationSite' -Verifiable
                Mock -CommandName Set-ADReplicationSite -Verifiable

                # Act
                Set-TargetResource @presentSiteTestPresentRename

                # Assert
                Assert-MockCalled -CommandName 'Rename-ADObject' -Times 1 -Scope It
                Assert-MockCalled -CommandName 'New-ADReplicationSite' -Times 0 -Scope It
            }

            It 'Should add a new site if the Default-First-Site-Name does not exist' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite
                Mock -CommandName 'Rename-ADObject' -Verifiable
                Mock -CommandName 'New-ADReplicationSite' -Verifiable

                # Act
                Set-TargetResource @presentSiteTestPresentRename

                # Assert
                Assert-MockCalled -CommandName 'Rename-ADObject' -Times 0 -Scope It
                Assert-MockCalled -CommandName 'New-ADReplicationSite' -Times 1 -Scope It
            }

            It 'Should update a site if the description does not match' {
                Mock -CommandName Get-ADReplicationSite -MockWith { $presentSiteTestPresent }
                Mock -CommandName Set-ADReplicationSite -Verifiable

                Set-TargetResource @presentSiteTestMismatchDescription

                Assert-MockCalled -CommandName Set-ADReplicationSite -Times 1 -Scope It
                Assert-MockCalled -CommandName Get-ADReplicationSite -Times 1 -Scope It -Exactly
            }

            It 'Should remove an existing site' {

                # Arrange
                Mock -CommandName Get-ADReplicationSite -MockWith { $presentSiteMock }
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
