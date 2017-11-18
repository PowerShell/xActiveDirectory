$Global:DSCModuleName   = 'xActiveDirectory'
$Global:DSCResourceName = 'MSFT_xADServicePrincipalName'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
Write-Host $moduleRoot -ForegroundColor Green;
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit
#endregion


# Begin Testing
try
{

    #region Pester Tests

    InModuleScope $Global:DSCResourceName {

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            $testDefaultParams = @{
                ServicePrincipalName = 'HOST/demo'
                Account              = ''
            }

            Context 'No SPN set' {

                Mock Get-ADObject

                It 'should return absent' {

                    $result = Get-TargetResource @testDefaultParams

                    $result.Ensure               | Should Be 'Absent'
                    $result.ServicePrincipalName | Should Be 'HOST/demo'
                    $result.Account              | Should Be ''
                }
            }

            Context 'One SPN set' {

                Mock Get-ADObject { [PSCustomObject] @{ SamAccountName = 'User' } }

                It 'should return present with the correct account' {

                    $result = Get-TargetResource @testDefaultParams

                    $result.Ensure               | Should Be 'Present'
                    $result.ServicePrincipalName | Should Be 'HOST/demo'
                    $result.Account              | Should Be 'User'
                }
            }

            Context 'Multiple SPN set' {

                Mock Get-ADObject { [PSCustomObject] @{ SamAccountName = 'User' }, [PSCustomObject] @{ SamAccountName = 'Computer' } }

                It 'should return present with the multiple accounts' {

                    $result = Get-TargetResource @testDefaultParams

                    $result.Ensure               | Should Be 'Present'
                    $result.ServicePrincipalName | Should Be 'HOST/demo'
                    $result.Account              | Should Be 'User;Computer'
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            $testDefaultParams = @{
                ServicePrincipalName = 'HOST/demo'
                Account              = 'User'
            }

            Context 'No SPN set' {

                Mock Get-ADObject

                It 'should return false for present' {

                    $result = Test-TargetResource -Ensure 'Present' @testDefaultParams
                    $result | Should Be $false
                }

                It 'should return true for absent' {

                    $result = Test-TargetResource -Ensure 'Absent' @testDefaultParams
                    $result | Should Be $true
                }
            }

            Context 'Correct SPN set' {

                Mock Get-ADObject { [PSCustomObject] @{ SamAccountName = 'User' } }

                It 'should return true for present' {

                    $result = Test-TargetResource -Ensure 'Present' @testDefaultParams
                    $result | Should Be $true
                }

                It 'should return false for absent' {

                    $result = Test-TargetResource -Ensure 'Absent' @testDefaultParams
                    $result | Should Be $false
                }
            }

            Context 'Wrong SPN set' {

                Mock Get-ADObject { [PSCustomObject] @{ SamAccountName = 'Computer' } }

                It 'should return false for present' {

                    $result = Test-TargetResource -Ensure 'Present' @testDefaultParams
                    $result | Should Be $false
                }

                It 'should return false for absent' {

                    $result = Test-TargetResource -Ensure 'Absent' @testDefaultParams
                    $result | Should Be $false
                }
            }

            Context 'Multiple SPN set' {

                Mock Get-ADObject { [PSCustomObject] @{ SamAccountName = 'User' }, [PSCustomObject] @{ SamAccountName = 'Computer' } }

                It 'should return false for present' {

                    $result = Test-TargetResource -Ensure 'Present' @testDefaultParams
                    $result | Should Be $false
                }

                It 'should return false for absent' {

                    $result = Test-TargetResource -Ensure 'Absent' @testDefaultParams
                    $result | Should Be $false
                }
            }

        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            $testPresentParams = @{
                Ensure               = 'Present'
                ServicePrincipalName = 'HOST/demo'
                Account              = 'User'
            }

            $testAbsentParams = @{
                Ensure               = 'Absent'
                ServicePrincipalName = 'HOST/demo'
            }

            Context 'AD Object not existing' {

                Mock Get-ADObject

                It 'should throw an exception' {

                    { Set-TargetResource @testPresentParams } | Should Throw
                }
            }

            Context 'No SPN set' {

                Mock Get-ADObject -ParameterFilter { $Filter -eq ([ScriptBlock]::Create(' ServicePrincipalName -eq $ServicePrincipalName ')) } { }
                Mock Get-ADObject { [PSCustomObject] @{ SamAccountName = 'User' } }
                Mock Set-ADObject

                It 'should call the Set-ADObject' {

                    $result = Set-TargetResource @testPresentParams

                    Assert-MockCalled Set-ADObject -Scope Context -Times 1 -Exactly
                }
            }

            Context 'Wrong SPN set' {

                Mock Get-ADObject -ParameterFilter { $Filter -eq ([ScriptBlock]::Create(' ServicePrincipalName -eq $ServicePrincipalName ')) } { [PSCustomObject] @{ SamAccountName = 'Computer' } }
                Mock Get-ADObject { [PSCustomObject] @{ SamAccountName = 'User' } }
                Mock Set-ADObject

                It 'should call the Set-ADObject twice' {

                    $result = Set-TargetResource @testPresentParams

                    Assert-MockCalled Set-ADObject -Scope Context -Times 2 -Exactly
                }
            }

            Context 'Remove all SPNs' {

                Mock Get-ADObject -ParameterFilter { $Filter -eq ([ScriptBlock]::Create(' ServicePrincipalName -eq $ServicePrincipalName ')) } { [PSCustomObject] @{ SamAccountName = 'User' } }
                Mock Get-ADObject { [PSCustomObject] @{ SamAccountName = 'User' } }
                Mock Set-ADObject

                It 'should call the Set-ADObject' {

                    $result = Set-TargetResource @testAbsentParams

                    Assert-MockCalled Set-ADObject -Scope Context -Times 1 -Exactly
                }
            }
        }
        #endregion
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
