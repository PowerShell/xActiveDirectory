Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\ActiveDirectoryDsc.TestHelper.psm1')

if (-not (Test-RunForCITestCategory -Type 'Unit' -Category 'Tests'))
{
    return
}

$script:dscModuleName = 'ActiveDirectoryDsc'
$script:dscResourceName = 'MSFT_ADReplicationSiteLink'

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
        # Load stub cmdlets and classes.
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\ActiveDirectory_2019.psm1') -Force

        $mockGetADReplicationSiteLinkReturn = @{
            Name                          = 'HQSiteLink'
            Cost                          = 100
            Description                   = 'HQ Site'
            ReplicationFrequencyInMinutes = 180
            SitesIncluded                 = @('CN=SITE1,CN=Sites,CN=Configuration,DC=corp,DC=contoso,DC=com', 'CN=SITE2,CN=Sites,CN=Configuration,DC=corp,DC=contoso,DC=com')
        }

        $targetResourceParameters = @{
            Name = 'HQSiteLink'
            Cost = 100
            Description = 'HQ Site'
            ReplicationFrequencyInMinutes = 180
            SitesIncluded = @('site1', 'site2')
            SitesExcluded = @()
            Ensure = 'Present'
        }

        $targetResourceParametersSitesExcluded = $targetResourceParameters.Clone()
        $targetResourceParametersSitesExcluded['SitesIncluded'] = $null
        $targetResourceParametersSitesExcluded['SitesExcluded'] = @('site3','site4')

        $mockADReplicationSiteLinkSitesExcluded = $mockGetADReplicationSiteLinkReturn.Clone()
        $mockADReplicationSiteLinkSitesExcluded['SitesIncluded'] = $null

        Describe 'ADReplicationSiteLink\Get-TargetResource' {
            Context 'When sites are included' {
                Mock -CommandName Get-ADReplicationSiteLink -MockWith { $mockGetADReplicationSiteLinkReturn }

                It 'Ensure should be Present' {
                    Mock -CommandName Resolve-SiteLinkName -MockWith { 'site1' } -ParameterFilter { $SiteName -eq $mockGetADReplicationSiteLinkReturn.SitesIncluded[0] }
                    Mock -CommandName Resolve-SiteLinkName -MockWith { 'site2' } -ParameterFilter { $SiteName -eq $mockGetADReplicationSiteLinkReturn.SitesIncluded[1] }

                    $getResult = Get-TargetResource -Name HQSiteLink

                    $getResult.Name                          | Should -Be $targetResourceParameters.Name
                    $getResult.Cost                          | Should -Be $targetResourceParameters.Cost
                    $getResult.Description                   | Should -Be $targetResourceParameters.Description
                    $getResult.ReplicationFrequencyInMinutes | Should -Be $targetResourceParameters.ReplicationFrequencyInMinutes
                    $getResult.SitesIncluded                 | Should -Be $targetResourceParameters.SitesIncluded
                    $getResult.SitesExcluded                 | Should -Be $targetResourceParameters.SitesExcluded
                    $getResult.Ensure                        | Should -Be $targetResourceParameters.Ensure
                }
            }

            Context 'When AD Replication Sites do not exist' {
                Mock -CommandName Get-ADReplicationSiteLink -MockWith { throw (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException) }

                It 'Ensure Should be Absent' {
                    $getResult = Get-TargetResource -Name HQSiteLink

                    $getResult.Name                          | Should -Be $targetResourceParameters.Name
                    $getResult.Cost                          | Should -BeNullOrEmpty
                    $getResult.Description                   | Should -BeNullOrEmpty
                    $getResult.ReplicationFrequencyInMinutes | Should -BeNullOrEmpty
                    $getResult.SitesIncluded                 | Should -BeNullOrEmpty
                    $getResult.SitesExcluded                 | Should -BeNullOrEmpty
                    $getResult.Ensure                        | Should -Be 'Absent'
                }
            }

            Context 'When Get-ADReplicationSiteLink throws an unexpected error' {
                Mock -CommandName Get-ADReplicationSiteLink -MockWith { throw }

                It 'Should throw the correct error' {
                    { Get-TargetResource -Name HQSiteLink } | Should -Throw ($script:localizedData.GetSiteLinkUnexpectedError -f 'HQSiteLink')
                }
            }


            Context 'When Sites are excluded' {
                Mock -CommandName Get-ADReplicationSiteLink -MockWith { $mockADReplicationSiteLinkSitesExcluded }

                $getResult = Get-TargetResource -Name HQSiteLink -SitesExcluded @('site3','site4')

                It 'Returns SitesExcluded' {
                    $getResult.Name                          | Should -Be $targetResourceParametersSitesExcluded.Name
                    $getResult.Cost                          | Should -Be $targetResourceParametersSitesExcluded.Cost
                    $getResult.Description                   | Should -Be $targetResourceParametersSitesExcluded.Description
                    $getResult.ReplicationFrequencyInMinutes | Should -Be $targetResourceParametersSitesExcluded.ReplicationFrequencyInMinutes
                    $getResult.SitesIncluded                 | Should -Be $targetResourceParametersSitesExcluded.SitesIncluded
                    $getResult.SitesExcluded                 | Should -Be $targetResourceParametersSitesExcluded.SitesExcluded
                    $getResult.Ensure                        | Should -Be $targetResourceParametersSitesExcluded.Ensure
                }
            }
        }

        Describe 'ADReplicationSiteLink\Test-TargetResource' {
            Context 'When target resource in desired state' {
                Mock -CommandName Get-TargetResource -MockWith { $targetResourceParameters }

                It 'Should return $true when sites included' {
                    Test-TargetResource @targetResourceParameters | Should -BeTrue
                }

                It 'Should return $true when sites excluded' {
                    Test-TargetResource @targetResourceParametersSitesExcluded | Should -BeTrue
                }
            }

            Context 'When target resource is not in desired state' {
                BeforeEach {
                    $mockTargetResourceNotInDesiredState = $targetResourceParameters.clone()
                }

                It 'Should return $false with Cost is non compliant' {
                    $mockTargetResourceNotInDesiredState['Cost'] = 1

                    Mock -CommandName Get-TargetResource -MockWith { $mockTargetResourceNotInDesiredState }

                    Test-TargetResource @targetResourceParameters | Should -BeFalse
                }

                It 'Should return $false with Description is non compliant' {
                    $mockTargetResourceNotInDesiredState['Description'] = 'MyIncorrectDescription'

                    Mock -CommandName Get-TargetResource -MockWith { $mockTargetResourceNotInDesiredState }

                    Test-TargetResource @targetResourceParameters | Should -BeFalse
                }

                It 'Should return $false with Replication Frequency In Minutes is non compliant' {
                    $mockTargetResourceNotInDesiredState['ReplicationFrequencyInMinutes'] = 1

                    Mock -CommandName Get-TargetResource -MockWith { $mockTargetResourceNotInDesiredState }

                    Test-TargetResource @targetResourceParameters | Should -BeFalse
                }

                It 'Should return $false with Sites Included is non compliant' {
                    $mockTargetResourceNotInDesiredState['SitesIncluded'] = @('site11','site12')

                    Mock -CommandName Get-TargetResource -MockWith { $mockTargetResourceNotInDesiredState }

                    Test-TargetResource @targetResourceParameters | Should -BeFalse
                }

                It 'Should return $false with Ensure is non compliant' {
                    $mockTargetResourceNotInDesiredState['Ensure'] = 'Absent'

                    Mock -CommandName Get-TargetResource -MockWith { $mockTargetResourceNotInDesiredState }

                    Test-TargetResource @targetResourceParametersSitesExcluded | Should -BeFalse
                }

                It 'Should return $false with Sites Excluded is non compliant' {
                    $mockTargetResourceNotInDesiredState['SitesIncluded'] = @('site1','site2','site3','site4')
                    $mockTargetResourceNotInDesiredState['SitesExcluded'] = @('site3','site4')

                    Mock -CommandName Get-TargetResource -MockWith { $mockTargetResourceNotInDesiredState }

                    Test-TargetResource @targetResourceParametersSitesExcluded | Should -BeFalse
                }
            }
        }

        Describe 'ADReplicationSiteLink\Set-TargetResource' {
            Context 'Site Link is Absent but is desired Present' {
                Mock -CommandName Get-TargetResource -MockWith { @{ Ensure = 'Absent' } }
                Mock -CommandName New-ADReplicationSiteLink
                Mock -CommandName Set-ADReplicationSiteLink
                Mock -CommandName Remove-ADReplicationSiteLink

                It 'Should assert mock calls when Present' {
                    Set-TargetResource -Name 'TestSiteLink' -Ensure 'Present'

                    Assert-MockCalled -CommandName New-ADReplicationSiteLink -Scope It -Times 1 -Exactly
                    Assert-MockCalled -CommandName Set-ADReplicationSiteLink -Scope It -Times 0 -Exactly
                    Assert-MockCalled -CommandName Remove-ADReplicationSiteLink -Scope It -Times 0 -Exactly
                }
            }

            Context 'Site Link is Present but desired Absent' {
                Mock -CommandName Get-TargetResource -MockWith { @{ Ensure = 'Present' } }
                Mock -CommandName New-ADReplicationSiteLink
                Mock -CommandName Set-ADReplicationSiteLink
                Mock -CommandName Remove-ADReplicationSiteLink

                It 'Should assert mock calls when Absent' {
                    Set-TargetResource -Name 'TestSiteLink' -Ensure 'Absent'

                    Assert-MockCalled -CommandName New-ADReplicationSiteLink -Scope It -Times 0 -Exactly
                    Assert-MockCalled -CommandName Set-ADReplicationSiteLink -Scope It -Times 0 -Exactly
                    Assert-MockCalled -CommandName Remove-ADReplicationSiteLink -Scope It -Times 1 -Exactly
                }
            }

            Context 'Site Link is Present and Should be but not in a desired state' {
                $addSitesParameters = @{
                    Name                          = 'TestSite'
                    SitesIncluded                 = 'Site1'
                    Ensure                        = 'Present'
                    ReplicationFrequencyInMinutes = 15
                }

                $removeSitesParameters = @{
                    Name          = 'TestSite'
                    SitesExcluded = 'Site1'
                    Ensure        = 'Present'
                }

                Mock -CommandName Get-TargetResource -MockWith { @{ Ensure = 'Present' ; SitesIncluded = 'Site0'} }
                Mock -CommandName Set-ADReplicationSiteLink
                Mock -CommandName New-ADReplicationSiteLink
                Mock -CommandName Remove-ADReplicationSiteLink

                It "Should call Set-ADReplicationSiteLink with SitesIncluded-Add when SitesInluded is populated" {
                    Mock -CommandName Set-ADReplicationSiteLink -ParameterFilter {$SitesIncluded -and $SitesIncluded['Add'] -eq 'Site1'}
                    Set-TargetResource @addSitesParameters

                    Assert-MockCalled -CommandName New-ADReplicationSiteLink -Scope It -Times 0 -Exactly
                    Assert-MockCalled -CommandName Set-ADReplicationSiteLink -Scope It -Times 1 -Exactly
                    Assert-MockCalled -CommandName Remove-ADReplicationSiteLink -Scope It -Times 0 -Exactly -ParameterFilter {
                        $ReplicationFrequencyInMinutes -eq 15
                        $Name -eq 'TestSite'
                        $Ensure -eq 'Present'
                        $SitesIncluded -eq 'Site1'
                    }
                }

                It 'Should call Set-ADReplicationSiteLink with SitesIncluded-Remove when SitesExcluded is populated' {
                    Mock -CommandName Set-ADReplicationSiteLink -ParameterFilter {$SitesIncluded -and $SitesIncluded['Remove'] -eq 'Site1'}
                    Set-TargetResource @removeSitesParameters

                    Assert-MockCalled -CommandName New-ADReplicationSiteLink -Scope It -Times 0 -Exactly
                    Assert-MockCalled -CommandName Set-ADReplicationSiteLink -Scope It -Times 1 -Exactly
                    Assert-MockCalled -CommandName Remove-ADReplicationSiteLink -Scope It -Times 0 -Exactly
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
