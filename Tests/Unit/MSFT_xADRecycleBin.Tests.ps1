$script:dscModuleName = 'xActiveDirectory'
$script:dscResourceName = 'MSFT_xADRecycleBin'

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
        $forestFQDN = 'contoso.com'
        $forestFunctionality = 'Windows2016Forest'
        $configurationNamingContext = 'CN=Configuration,DC=contoso,DC=com'
        $testCredential = [System.Management.Automation.PSCredential]::Empty

        $mockRootDSE = @{
            configurationNamingContext = $configurationNamingContext
            forestFunctionality        = $forestFunctionality
        }

        $mockADObjectNoRecycleBin = New-MockObject -Type Microsoft.ActiveDirectory.Management.ADObject
        $mockADObjectNoRecycleBin.'msDS-EnabledFeature' = @('')

        $mockADObjectRecycleBin = New-MockObject -Type Microsoft.ActiveDirectory.Management.ADObject
        $mockADObjectRecycleBin.'msDS-EnabledFeature' = @(
            "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,$($configurationNamingContext)"
        )

        $targetResourceParameters = @{
            ForestFQDN                        = $ForestFQDN
            EnterpriseAdministratorCredential = $testCredential
        }

        $mockGetTargetResourceReturnValueRecycleBinEnabled = @{
            ForestFQDN        = $forestFQDN
            RecycleBinEnabled = $true
            ForestMode        = $forestFunctionality
        }

        $mockGetTargetResourceReturnValueRecycleBinNotEnabled = @{
            ForestFQDN        = $forestFQDN
            RecycleBinEnabled = $false
            ForestMode        = $forestFunctionality
        }

        $mockADForestLevel3 = @{
            ForestMode         = 3
            RootDomain         = $forestFQDN
            DomainNamingMaster = "dc01.$forestFQDN"
        }

        $mockADForestLevel4 = @{
            ForestMode         = 4
            RootDomain         = $forestFQDN
            DomainNamingMaster = "dc01.$forestFQDN"
        }

        Describe 'MSFT_xADRecycleBin\Get-TargetResource' {
            Mock -CommandName Get-ADRootDSE -MockWith { $mockRootDSE }

            Context 'When Recycle Bin feature is installed' {
                Mock -CommandName Get-ADObject -MockWith { $mockADObjectRecycleBin }

                It 'Should return expected properties' {
                    $targetResource = Get-TargetResource @targetResourceParameters

                    $targetResource.ForestFQDN | Should -Be $mockGetTargetResourceReturnValueRecycleBinEnabled.ForestFQDN
                    $targetResource.RecycleBinEnabled | Should -Be $mockGetTargetResourceReturnValueRecycleBinEnabled.RecycleBinEnabled
                    $targetResource.ForestMode | Should -Be $mockGetTargetResourceReturnValueRecycleBinEnabled.ForestMode
                }
            }

            Context 'When Recycle Bin feature not installed' {
                Mock -CommandName Get-ADObject -MockWith { $mockADObjectNoRecycleBin }

                It 'Should return expected properties' {
                    $targetResource = Get-TargetResource @targetResourceParameters

                    $targetResource.ForestFQDN | Should -Be $mockGetTargetResourceReturnValueRecycleBinNotEnabled.ForestFQDN
                    $targetResource.RecycleBinEnabled | Should -Be $mockGetTargetResourceReturnValueRecycleBinNotEnabled.RecycleBinEnabled
                    $targetResource.ForestMode | Should -Be $mockGetTargetResourceReturnValueRecycleBinNotEnabled.ForestMode
                }
            }

            Context 'When Get-AdObject throws an exception' {
                Mock -CommandName Write-Error

                It 'Should throw ADIdentityNotFoundException' {
                    Mock -CommandName Get-ADObject -MockWith { Throw (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException) }
                    { Get-TargetResource @targetResourceParameters } | Should -Throw Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException
                }

                It 'Should throw ADServerDownException' {
                    Mock -CommandName Get-ADObject -MockWith { Throw (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADServerDownException) }
                    { Get-TargetResource @targetResourceParameters } | Should -Throw Microsoft.ActiveDirectory.Management.ADServerDownException
                }

                It 'Should throw AuthenticationException' {
                    Mock -CommandName Get-ADObject -MockWith { Throw (New-Object -TypeName System.Security.Authentication.AuthenticationException) }
                    { Get-TargetResource @targetResourceParameters } | Should -Throw 'System error'
                }

                It 'Should throw UnhandledException' {
                    Mock -CommandName Get-ADObject -MockWith { Throw Unhandled.Exception }
                    { Get-TargetResource @targetResourceParameters } | Should -Throw Unhandled.Exception
                }
            }
        }

        Describe 'MSFT_xADRecycleBin\Test-TargetResource' {
            Mock -CommandName Get-ADRootDSE -MockWith { $mockRootDSE }

            Context 'When Recycle Bin feature is installed' {
                Mock -CommandName Get-ADObject -MockWith { $mockADObjectRecycleBin }

                It 'Should return true' {
                    Test-TargetResource @targetResourceParameters | Should -Be $true
                }
            }

            Context 'When Recycle Bin feature not installed' {
                Mock -CommandName Get-ADObject -MockWith { $mockADObjectNoRecycleBin }

                It 'Should return false' {
                    Test-TargetResource @targetResourceParameters | Should -Be $false
                }
            }

            Context 'When Get-AdObject throws an exception' {
                Mock -CommandName Write-Error

                It 'Should throw ADIdentityNotFoundException' {
                    Mock -CommandName Get-ADObject -MockWith { Throw (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException) }
                    { Test-TargetResource @targetResourceParameters } | Should -Throw Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException
                }

                It 'Should throw ADServerDownException' {
                    Mock -CommandName Get-ADObject -MockWith { Throw (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADServerDownException) }
                    { Test-TargetResource @targetResourceParameters } | Should -Throw Microsoft.ActiveDirectory.Management.ADServerDownException
                }

                It 'Should throw AuthenticationException' {
                    Mock -CommandName Get-ADObject -MockWith { Throw (New-Object -TypeName System.Security.Authentication.AuthenticationException) }
                    { Test-TargetResource @targetResourceParameters } | Should -Throw 'System error'
                }

                It 'Should throw UnhandledException' {
                    Mock -CommandName Get-ADObject -MockWith { Throw Unhandled.Exception }
                    { Test-TargetResource @targetResourceParameters } | Should -Throw Unhandled.Exception
                }
            }
        }

        Describe 'MSFT_xADRecycleBin\Set-TargetResource' {
            Mock -CommandName Enable-ADOptionalFeature

            Context 'When minimum forest level is too low' {
                Mock -CommandName Get-ADForest -MockWith { $mockADForestLevel3 }
                It 'Should Throw' {
                    { Set-TargetResource @targetResourceParameters } | Should -Throw
                }

                It 'Should not call Enable-ADOptionalFeature' {
                    Assert-MockCalled Enable-ADOptionalFeature -Scope It -Times 0 -Exactly
                }
            }

            Context 'When minimum forest level is met' {
                Mock -CommandName Get-ADForest -MockWith { $mockADForestLevel4 }
                It 'Should not Throw' {
                    { Set-TargetResource @targetResourceParameters } | Should -Not -Throw
                }

                It 'Should call Enable-ADOptionalFeature' {
                    Set-TargetResource @targetResourceParameters

                    Assert-MockCalled Enable-ADOptionalFeature -Scope It -Times 1 -Exactly
                }
            }

            Context 'When Get-AdForest throws an exception' {
                Mock -CommandName Write-Error

                It 'Should throw ADIdentityNotFoundException' {
                    Mock -CommandName Get-ADForest -MockWith { Throw (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException) }
                    { Set-TargetResource @targetResourceParameters } | Should -Throw Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException
                }

                It 'Should throw ADServerDownException' {
                    Mock -CommandName Get-ADForest -MockWith { Throw (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADServerDownException) }
                    { Set-TargetResource @targetResourceParameters } | Should -Throw Microsoft.ActiveDirectory.Management.ADServerDownException
                }

                It 'Should throw AuthenticationException' {
                    Mock -CommandName Get-ADForest -MockWith { Throw (New-Object -TypeName System.Security.Authentication.AuthenticationException) }
                    { Set-TargetResource @targetResourceParameters } | Should -Throw 'System error'
                }

                It 'Should throw UnhandledException' {
                    Mock -CommandName Get-ADForest -MockWith { Throw Unhandled.Exception }
                    { Set-TargetResource @targetResourceParameters } | Should -Throw Unhandled.Exception
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
