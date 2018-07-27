[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$Script:DSCModuleName      = 'xActiveDirectory'
$Script:DSCResourceName    = 'MSFT_xADDomainController'

#region HEADER
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Script:DSCModuleName `
    -DSCResourceName $Script:DSCResourceName `
    -TestType Unit
#endregion

# Begin Testing
try
{
    #region Pester Test Initialization
    $correctDomainName   = 'present.com'
    $testAdminCredential = [System.Management.Automation.PSCredential]::Empty
    $correctDatabasePath = 'C:\Windows\NTDS'
    $correctLogPath      = 'C:\Windows\NTDS'
    $correctSysvolPath   = 'C:\Windows\SYSVOL'
    $correctSiteName     = 'PresentSite'
    $incorrectSiteName   = 'IncorrectSite'

    $testDefaultParams = @{
        DomainAdministratorCredential = $testAdminCredential
        SafemodeAdministratorPassword = $testAdminCredential
    }

    $commonMockParams = @{
        ModuleName = $Script:DSCResourceName
    }

    $commonAssertParams = @{
        ModuleName = $Script:DSCResourceName
        Scope = 'It'
        Exactly = $true
    }

    #Fake function because it is only available on Windows Server
    function Install-ADDSDomainController {
        param(
            $DomainName, $SafeModeAdministratorPassword, $Credential, $NoRebootOnCompletion, $Force, $DatabasePath,
            $LogPath, $SysvolPath, $SiteName
        )

        throw [exception] 'Not Implemented'
    }
    #endregion Pester Test Initialization

    #region Function Get-TargetResource
    Describe -Tag 'xADDomainController' "$($Script:DSCResourceName)\Get-TargetResource" {

        Mock -CommandName Get-ADDomain -MockWith { return $true } @commonMockParams
        Mock -CommandName Get-ADDomainController {
            return $stubDomainController = @{
                Site = 'PresentSite'
                Domain = 'present.com'
            }
        } @commonMockParams
        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters' } -MockWith {
            return @{
                'Database log files path' = 'C:\Windows\NTDS'
                'DSA Working Directory'   = 'C:\Windows\NTDS'
            }
        } @commonMockParams
        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' } -MockWith {
            return @{
                'SysVol' = 'C:\Windows\SYSVOL\sysvol'
            }
        } @commonMockParams

        It 'Returns current "DatabasePath"' {
            $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName
            $result.DatabasePath | Should Be $correctDatabasePath
        }

        It 'Returns current "LogPath"' {
            $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName
            $result.LogPath | Should Be $correctLogPath
        }

        It 'Returns current "SysvolPath"' {
            $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName
            $result.SysvolPath | Should Be $correctSysvolPath
        }

        It 'Returns current "SiteName"' {
            $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName
            $result.SiteName | Should Be $correctSiteName
        }
    }
    #endregion

    #region Function Test-TargetResource
    Describe -Tag 'xADDomainController' "$($Script:DSCResourceName)\Test-TargetResource" {
        InModuleScope $Script:DSCResourceName {
            $correctSiteName = 'PresentSite'
            $incorrectSiteName = 'IncorrectSite'
            $correctDomainName = 'present.com'
            $testAdminCredential = [System.Management.Automation.PSCredential]::Empty

            $testDefaultParams = @{
                DomainAdministratorCredential = $testAdminCredential
                SafemodeAdministratorPassword = $testAdminCredential
            }

            It 'Returns "False" when "SiteName" does not match' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site = $incorrectSiteName
                    Domain = $correctDomainName
                }

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-ADDomainController -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $true }
                Mock -CommandName Get-ItemProperty -MockWith { return @{} }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should Be $false
            }

            It 'Returns "True" when "SiteName" matches' {

                $stubDomainController = @{
                    Site = $correctSiteName
                    Domain = $correctDomainName
                }

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-ADDomainController -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $true }
                Mock -CommandName Get-ItemProperty -MockWith { return @{} }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should Be $true
            }

            It 'Throws if "SiteName" is wrong' {

                $stubDomainController = @{
                    Site = $correctSiteName
                    Domain = $correctDomainName
                }

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-ADDomainController -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $false }
                { Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $incorrectSiteName } |
                    Should Throw "Site '$($incorrectSiteName)' could not be found."
            }
        }
    }
    #endregion

    #region Function Set-TargetResource
    Describe -Tag 'xADDomainController' "$($Script:DSCResourceName)\Set-TargetResource" {
        It 'Calls "Install-ADDSDomainController" with "Site", if specified' {
            Mock -CommandName Get-ADDomain -MockWith {
                return $true
            } @commonMockParams

            Mock -CommandName Get-TargetResource -MockWith {
                return $stubTargetResource = @{
                    Ensure = $false
                }
            } @commonMockParams
            Mock -CommandName Install-ADDSDomainController -ParameterFilter { $SiteName -eq $correctSiteName } @commonMockParams

            Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

            Assert-MockCalled -CommandName Install-ADDSDomainController -Times 1 -ParameterFilter { $SiteName -eq $correctSiteName } @commonAssertParams
        }

        It 'Calls "Move-ADDirectoryServer" when "SiteName" does not match' {
            Mock -CommandName Get-TargetResource -MockWith {
                return $stubTargetResource = @{
                    Ensure = $true
                    SiteName = 'IncorrectSite'
                }
            } @commonMockParams

            Mock -CommandName Move-ADDirectoryServer -ParameterFilter { $Site.ToString() -eq $correctSiteName } @commonMockParams
            Mock -CommandName Move-ADDirectoryServer @commonMockParams

            Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

            Assert-MockCalled -CommandName Move-ADDirectoryServer -Times 1 -ParameterFilter { $Site.ToString() -eq $correctSiteName } @commonAssertParams
        }

        It 'Does not call "Move-ADDirectoryServer" when "SiteName" matches' {
            Mock -CommandName Get-TargetResource -MockWith {
                return $stubTargetResource = @{
                    Ensure = $true
                    SiteName = 'PresentSite'
                }
            } @commonMockParams

            Mock -CommandName Move-ADDirectoryServer @commonMockParams

            Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

            Assert-MockCalled -CommandName Move-ADDirectoryServer -Times 0 @commonAssertParams
        }

        It 'Does not call "Move-ADDirectoryServer" when "SiteName" is not specified' {
            Mock -CommandName Get-TargetResource -MockWith {
                return $stubTargetResource = @{
                    Ensure = $true
                    SiteName = 'PresentSite'
                }
            } @commonMockParams

            Mock -CommandName Move-ADDirectoryServer @commonMockParams

            Set-TargetResource @testDefaultParams -DomainName $correctDomainName

            Assert-MockCalled -CommandName Move-ADDirectoryServer -Times 0 @commonAssertParams
        }
    }
    #endregion
}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $TestEnvironment

    #endregion
}

