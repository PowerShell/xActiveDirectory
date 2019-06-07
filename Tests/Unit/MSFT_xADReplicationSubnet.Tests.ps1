$script:dscModuleName = 'xActiveDirectory'
$script:dscResourceName = 'MSFT_xADReplicationSubnet'

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
        #region Function Get-TargetResource
        Describe 'xADReplicationSubnet\Get-TargetResource' {
            $testDefaultParameters = @{
                Name = '10.0.0.0/8'
                Site = 'Default-First-Site-Name'
            }

            Context 'Subnet does not exist' {

                Mock -CommandName Get-ADReplicationSubnet

                It 'Should return absent' {

                    $result = Get-TargetResource @testDefaultParameters

                    $result.Ensure   | Should -Be 'Absent'
                    $result.Name     | Should -Be $testDefaultParameters.Name
                    $result.Site     | Should -Be ''
                    $result.Location | Should -Be ''
                }
            }

            Context 'Subnet does exist' {

                Mock -CommandName Get-ADReplicationSubnet -MockWith {
                    [PSCustomObject] @{
                        DistinguishedName = 'CN=10.0.0.0/8,CN=Subnets,CN=Sites,CN=Configuration,DC=arcade,DC=local'
                        Name              = '10.0.0.0/8'
                        Location          = 'Seattle'
                        Site              = 'CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=contoso,DC=com'
                    }
                }
                Mock -CommandName Get-ADObject -MockWith {
                    [PSCustomObject] @{ Name = 'Default-First-Site-Name' }
                }

                It 'Should return present with the correct subnet' {

                    $result = Get-TargetResource @testDefaultParameters

                    $result.Ensure   | Should -Be 'Present'
                    $result.Name     | Should -Be $testDefaultParameters.Name
                    $result.Site     | Should -Be 'Default-First-Site-Name'
                    $result.Location | Should -Be 'Seattle'
                }
            }

            Context 'Subnet does exist, but site is empty' {

                Mock -CommandName Get-ADReplicationSubnet -MockWith {
                    [PSCustomObject] @{
                        DistinguishedName = 'CN=10.0.0.0/8,CN=Subnets,CN=Sites,CN=Configuration,DC=arcade,DC=local'
                        Name              = '10.0.0.0/8'
                        Location          = 'Seattle'
                        Site              = $null
                    }
                }

                It 'Should return present with the correct subnet' {

                    $result = Get-TargetResource @testDefaultParameters

                    $result.Ensure   | Should -Be 'Present'
                    $result.Name     | Should -Be $testDefaultParameters.Name
                    $result.Site     | Should -Be ''
                    $result.Location | Should -Be 'Seattle'
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'xADReplicationSubnet\Test-TargetResource' {

            $testDefaultParameters = @{
                Name     = '10.0.0.0/8'
                Site     = 'Default-First-Site-Name'
                Location = 'Seattle'
            }

            Context 'Subnet does not exist' {

                Mock -CommandName Get-ADReplicationSubnet

                It 'Should return false for present' {

                    $result = Test-TargetResource -Ensure 'Present' @testDefaultParameters
                    $result | Should -Be $false
                }

                It 'Should return true for absent' {

                    $result = Test-TargetResource -Ensure 'Absent' @testDefaultParameters
                    $result | Should -Be $true
                }
            }

            Context 'Subnet does exist' {

                Mock -CommandName Get-ADReplicationSubnet -MockWith {
                    [PSCustomObject] @{
                        DistinguishedName = 'CN=10.0.0.0/8,CN=Subnets,CN=Sites,CN=Configuration,DC=arcade,DC=local'
                        Name              = '10.0.0.0/8'
                        Location          = 'Seattle'
                        Site              = 'CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=contoso,DC=com'
                    }
                }
                Mock -CommandName Get-ADObject -MockWith {
                    [PSCustomObject] @{ Name = 'Default-First-Site-Name' }
                }

                It 'Should return true for present' {

                    $result = Test-TargetResource -Ensure 'Present' @testDefaultParameters
                    $result | Should -Be $true
                }

                It 'Should return false for absent' {

                    $result = Test-TargetResource -Ensure 'Absent' @testDefaultParameters
                    $result | Should -Be $false
                }

                It 'Should return false for wrong site' {

                    $result = Test-TargetResource -Ensure 'Present' -Name $testDefaultParameters.Name -Site 'WrongSite' -Location $testDefaultParameters.Location
                    $result | Should -Be $false
                }

                It 'Should return false for wrong location' {

                    $result = Test-TargetResource -Ensure 'Present' -Name $testDefaultParameters.Name -Site $testDefaultParameters.Site -Location 'WringLocation'
                    $result | Should -Be $false
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe 'xADReplicationSubnet\Set-TargetResource' {
            $testPresentParameters = @{
                Ensure   = 'Present'
                Name     = '10.0.0.0/8'
                Site     = 'Default-First-Site-Name'
                Location = 'Seattle'
            }
            $testAbsentParameters = @{
                Ensure   = 'Absent'
                Name     = '10.0.0.0/8'
                Site     = 'Default-First-Site-Name'
            }

            Context 'Subnet does not exist' {

                Mock -CommandName Get-ADReplicationSubnet
                Mock -CommandName Get-ADObject -MockWith {
                    [PSCustomObject] @{ Name = 'Default-First-Site-Name' }
                }

                Mock -CommandName New-ADReplicationSubnet -MockWith {
                    [PSCustomObject] @{
                        DistinguishedName = 'CN=10.0.0.0/8,CN=Subnets,CN=Sites,CN=Configuration,DC=arcade,DC=local'
                        Name              = '10.0.0.0/8'
                        Location          = 'Seattle'
                        Site              = 'CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=contoso,DC=com'
                    }
                }

                It 'Should create the subnet' {

                    # Act
                    Set-TargetResource @testPresentParameters

                    # Assert
                    Assert-MockCalled -CommandName New-ADReplicationSubnet -Scope It -Times 1 -Exactly
                }
            }

            Context 'Subnet does exist' {

                Mock -CommandName Get-ADReplicationSubnet -MockWith {
                    [PSCustomObject] @{
                        DistinguishedName = 'CN=10.0.0.0/8,CN=Subnets,CN=Sites,CN=Configuration,DC=arcade,DC=local'
                        Name              = '10.0.0.0/8'
                        Location          = 'Seattle'
                        Site              = 'CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=contoso,DC=com'
                    }
                }
                Mock -CommandName Get-ADObject -MockWith {
                    [PSCustomObject] @{ Name = 'Default-First-Site-Name' }
                }

                Mock -CommandName Set-ADReplicationSubnet -ParameterFilter { $Site -ne $null } -MockWith {
                    [PSCustomObject] @{
                        DistinguishedName = 'CN=10.0.0.0/8,CN=Subnets,CN=Sites,CN=Configuration,DC=arcade,DC=local'
                        Name              = '10.0.0.0/8'
                        Location          = 'Seattle'
                        Site              = 'CN=OtherSite,CN=Sites,CN=Configuration,DC=contoso,DC=com'
                    }
                }
                Mock -CommandName Set-ADReplicationSubnet -ParameterFilter { $Location -eq 'OtherLocation' } -MockWith {
                    [PSCustomObject] @{
                        DistinguishedName = 'CN=10.0.0.0/8,CN=Subnets,CN=Sites,CN=Configuration,DC=arcade,DC=local'
                        Name              = '10.0.0.0/8'
                        Location          = 'OtherLocation'
                        Site              = 'CN=OtherSite,CN=Sites,CN=Configuration,DC=contoso,DC=com'
                    }
                }
                Mock -CommandName Remove-ADReplicationSubnet

                It 'Should update the subnet site' {

                    # Act
                    Set-TargetResource -Ensure $testPresentParameters.Ensure -Name $testPresentParameters.Name -Site 'OtherSite' -Location $testPresentParameters.Location

                    # Assert
                    Assert-MockCalled -CommandName Set-ADReplicationSubnet -ParameterFilter { $Site -ne $null } -Scope It -Times 1 -Exactly
                }

                It 'Should update the subnet location' {

                    # Act
                    Set-TargetResource -Ensure $testPresentParameters.Ensure -Name $testPresentParameters.Name -Site $testPresentParameters.Site -Location 'OtherLocation'

                    # Assert
                    Assert-MockCalled -CommandName Set-ADReplicationSubnet -ParameterFilter { $Location -eq 'OtherLocation' } -Scope It -Times 1 -Exactly
                }

                It 'Should remove the subnet' {

                    # Act
                    Set-TargetResource @testAbsentParameters

                    # Assert
                    Assert-MockCalled -CommandName Remove-ADReplicationSubnet -Scope It -Times 1 -Exactly
                }
            }
        }
        #endregion
    }
}
finally
{
    Invoke-TestCleanup
}
