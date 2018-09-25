$script:DSCModuleName = 'xActiveDirectory' 
$script:DSCResourceName = 'MSFT_xADForestProperties'

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit

try
{
    InModuleScope $script:DSCResourceName {

        $forestName = 'contoso.com'
        $testCredential = [System.Management.Automation.PSCredential]::Empty

        $replaceParameters = @{
            ForestName                 = $forestName
            ServicePrincipalNameSuffix = 'test.net'
            UserPrincipalNameSuffix    = 'cloudapp.net', 'fabrikam.com'
            Credential                 = $testCredential
        }

        $includeExcludeParameters = @{
            ForestName                          = $forestName
            ServicePrincipalNameSuffixToExclude = 'test.com'
            ServicePrincipalNameSuffixToInclude = 'test.net'
            UserPrincipalNameSuffixToExclude    = 'pester.net'
            UserPrincipalNameSuffixToInclude    = 'cloudapp.net', 'fabrikam.com'
            Credential                          = $testCredential
        }

        $excludeParameters = $includeExcludeParameters.clone()
        $excludeParameters['ServicePrincipalNameSuffixToInclude'] = $null
        $excludeParameters['UserPrincipalNameSuffixToInclude'] = $null

        $invalidParameters = $includeExcludeParameters.clone()
        $invalidParameters['UserPrincipalNameSuffix'] = 'test.com'

        $mockADForestDesiredState = @{
            Name        = $forestName
            SPNSuffixes = @('test.net')
            UPNSuffixes = @('cloudapp.net', 'fabrikam.com')
        }

        $mockADForestNonDesiredState = @{
            Name        = $forestName
            SPNSuffixes = @('test3.value')
            UPNSuffixes = @('test1.value', 'test2.value')
        }

        Mock Assert-Module
        Mock Import-Module

        Describe 'MSFT_xADForestProperties\Get-TargetResource' {
            Mock Get-ADForest -MockWith { $mockADForestDesiredState }
            
            Context 'When used with include/exclude parameters' {

                It 'Should return expected properties' {
                    $targetResource = Get-TargetResource @includeExcludeParameters

                    $targetResource.ServicePrincipalNameSuffix          | Should -Be $mockADForestDesiredState.SPNSuffixes
                    $targetResource.ServicePrincipalNameSuffixToInclude | Should -Be $includeExcludeParameters.ServicePrincipalNameSuffixToInclude
                    $targetResource.ServicePrincipalNameSuffixToExclude | Should -Be $includeExcludeParameters.ServicePrincipalNameSuffixToExclude
                    $targetResource.UserPrincipalNameSuffix             | Should -Be $mockADForestDesiredState.UPNSuffixes
                    $targetResource.UserPrincipalNameSuffixToInclude    | Should -Be $includeExcludeParameters.UserPrincipalNameSuffixToInclude
                    $targetResource.UserPrincipalNameSuffixToExclude    | Should -Be $includeExcludeParameters.UserPrincipalNameSuffixToExclude
                    $targetResource.Credential                          | Should -BeNullOrEmpty
                    $targetResource.ForestName                          | Should -Be $mockADForestDesiredState.Name
                }
            }

            Context 'When used with replace parameters' {

                It 'Should return expected properties' {
                    $targetResource = Get-TargetResource @replaceParameters

                    $targetResource.ServicePrincipalNameSuffix          | Should -Be $mockADForestDesiredState.SPNSuffixes
                    $targetResource.ServicePrincipalNameSuffixToInclude | Should -BeNullOrEmpty
                    $targetResource.ServicePrincipalNameSuffixToExclude | Should -BeNullOrEmpty
                    $targetResource.UserPrincipalNameSuffix             | Should -Be $mockADForestDesiredState.UPNSuffixes
                    $targetResource.UserPrincipalNameSuffixToInclude    | Should -BeNullOrEmpty
                    $targetResource.UserPrincipalNameSuffixToExclude    | Should -BeNullOrEmpty
                    $targetResource.Credential                          | Should -BeNullOrEmpty
                    $targetResource.ForestName                          | Should -Be $mockADForestDesiredState.Name
                }
            }
        }
        
        Describe 'MSFT_xADForestProperties\Test-TargetResource' {
            Context 'When target resource in desired state' {
                Mock Get-ADForest -MockWith { $mockADForestDesiredState }

                It 'Should return $true when using include/exclude parameters' {
                    Test-TargetResource @includeExcludeParameters | Should -Be $true
                }

                It 'Should return $true when using replace parameters' {
                    Test-TargetResource @replaceParameters | Should -Be $true
                }
            }

            Context 'When using Include and Exclude parameters and target not in desired state' {
                Mock Get-ADForest -MockWith { $mockADForestNonDesiredState }

                It 'Should return $false when using include/exclude parameters' {
                    Test-TargetResource @includeExcludeParameters | Should -Be $false
                }

                It 'Should return $false when using replace parameters' {
                    Test-TargetResource @replaceParameters | Should -Be $false
                }
            }

            Context 'When using invalid parameter combination' {
                Mock -CommandName Get-ADForest

                It 'Should throw when invalid parameter set is used' {
                    { Test-TargetResource @invalidParameters } | Should -Throw
                }
            }
        }
        
        Describe 'MSFT_xADForestProperties\Set-TargetResource' {
            Context 'When using replace parameters' {
                Mock Set-ADForest -ParameterFilter {
                    $SpnSuffixes.replace -eq ($replaceParameters.ServicePrincipalNameSuffix -join ',') -and 
                    $UpnSuffixes.replace -eq ($replaceParameters.UserPrincipalNameSuffix -join ',')
                }

                It 'Should call Set-ADForest with the replace action' {
                    Set-TargetResource @replaceParameters 

                    Assert-MockCalled Set-ADForest -Scope It -Times 1 -Exactly
                }
            }

            Context 'When using include/exclude parameters' {
                Mock Set-ADForest -ParameterFilter {
                    $SPNSuffixes.add -eq ($includeExcludeParameters.ServicePrincipalNameSuffixToInclude -join ',') -and
                    $SPNSuffixes.remove -eq ($includeExcludeParameters.ServicePrincipalNameSuffixToExclude -join ',') -and
                    $UPNSuffixes.add -eq ($includeExcludeParameters.UserPrincipalNameSuffixToInclude -join ',') -and
                    $UPNSuffixes.remove -eq ($includeExcludeParameters.UserPrincipalNameSuffixToExclude -join ',')
                }

                It 'Should call Set-ADForest with the add and remove actions' {
                    Set-TargetResource @includeExcludeParameters 

                    Assert-MockCalled Set-ADForest -Scope It -Times 1 -Exactly 
                }
            }

            Context 'When using only exclude parameters' {
                Mock Set-ADForest -ParameterFilter {
                    $SPNSuffixes.remove -eq ($excludeParameters.ServicePrincipalNameSuffixToExclude -join ',') -and
                    $UPNSuffixes.remove -eq ($excludeParameters.UserPrincipalNameSuffixToExclude -join ',')
                }

                It 'Should call Set-ADForest with the remove action' {
                    Set-TargetResource @excludeParameters 

                    Assert-MockCalled Set-ADForest -Scope It -Times 1 -Exactly 
                }
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
