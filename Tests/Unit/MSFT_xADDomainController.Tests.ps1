[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$Global:DSCModuleName      = 'xActiveDirectory'
$Global:DSCResourceName    = 'MSFT_xADDomainController'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
Write-Host $moduleRoot -ForegroundColor Green
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
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
    InModuleScope $Global:DSCResourceName {
        #region Pester Test Initialization
        $correctSiteName = 'PresentSite'
        $incorrectSiteName = 'IncorrectSite'
        $existingSiteName = 'ExistingSite'
        $correctDomainName = 'present.com'
        $incorrectDomainName = 'incorrect.com'
        $testAdminCredential = [System.Management.Automation.PSCredential]::Empty

        $testDefaultParams = @{
            DomainAdministratorCredential = $testAdminCredential
            SafemodeAdministratorPassword = $testAdminCredential
        }

        #endregion Pester Test Initialization

        #region Function Get-TargetResource
        Describe -Tag 'xADDomainController' "$($Global:DSCResourceName)\Get-TargetResource" {
            It 'Returns current "SiteName"' {

                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site = $correctSiteName
                    Domain = $correctDomainName
                }

                Mock Get-ADDomain { return $stubDomain }
                Mock Get-ADDomainController { return $stubDomainController }

                $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result.SiteName | Should Be $correctSiteName
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe -Tag 'xADDomainController' "$($Global:DSCResourceName)\Test-TargetResource" {
            It 'Returns "False" when "SiteName" does not match' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site = $incorrectSiteName
                    Domain = $correctDomainName
                }

                Mock Get-ADDomain { return $stubDomain }
                Mock Get-ADDomainController { return $stubDomainController }
                Mock Test-ADReplicationSite { return $true }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should Be $false
            }

            It 'Returns "True" when "SiteName" matches' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site = $correctSiteName
                    Domain = $correctDomainName
                }

                Mock Get-ADDomain { return $stubDomain }
                Mock Get-ADDomainController { return $stubDomainController }
                Mock Test-ADReplicationSite { return $true }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should Be $true
            }

            It 'Throws if "SiteName" is wrong' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site = $correctSiteName
                    Domain = $correctDomainName
                }

                Mock Get-ADDomain { return $stubDomain }
                Mock Get-ADDomainController { return $stubDomainController }
                Mock Test-ADReplicationSite { return $false }
                { Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName } | Should Throw
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe -Tag 'xADDomainController' "$($Global:DSCResourceName)\Set-TargetResource" {
            It 'Calls "Install-ADDSDomainController" with "Site", if specified' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }
                $stubTargetResource = @{
                    Ensure = $false
                }

                function Install-ADDSDomainController {
                    param(
                        $DomainName, $SafeModeAdministratorPassword, $Credential, $NoRebootOnCompletion, $Force, $DatabasePath,
                        $LogPath, $SysvolPath, $SiteName
                    )
                }

                Mock Get-ADDomain { return $stubDomain }
                Mock Get-TargetResource { return $stubTargetResource }
                Mock Install-ADDSDomainController -MockWith {} -ParameterFilter { $SiteName -eq $correctSiteName }

                Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                Assert-MockCalled Install-ADDSDomainController -Times 1 -Exactly -ParameterFilter { $SiteName -eq $correctSiteName } -Scope It
            }

            It 'Calls "Move-ADDirectoryServer" when "SiteName" does not match' {
                $stubTargetResource = @{
                    Ensure = $true
                    SiteName = $incorrectSiteName
                }

                function Move-ADDirectoryServer {
                    param (
                        $Identity, $Site, $AuthType, $Confirm, $Credential, $Server
                    )
                }

                Mock Get-TargetResource { return $stubTargetResource }
                Mock Move-ADDirectoryServer -MockWith {} -ParameterFilter { $Site -eq $correctSiteName }

                Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                Assert-MockCalled Move-ADDirectoryServer -Times 1 -Exactly -ParameterFilter { $Site -eq $correctSiteName } -Scope It
            }

            It 'Does not call "Move-ADDirectoryServer" when "SiteName" matches' {
                $stubTargetResource = @{
                    Ensure = $true
                    SiteName = $correctSiteName
                }

                function Move-ADDirectoryServer {
                    param (
                        $Identity, $Site, $AuthType, $Confirm, $Credential, $Server
                    )
                }

                Mock Get-TargetResource { return $stubTargetResource }
                Mock Move-ADDirectoryServer -MockWith {} -ParameterFilter { $Site -eq $correctSiteName }

                Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                Assert-MockCalled Move-ADDirectoryServer -Times 0 -Exactly -ParameterFilter { $Site -eq $correctSiteName } -Scope It
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
