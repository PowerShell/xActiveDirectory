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
            It 'Returns current Site Name' {

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

            It 'Returns "False" when Site Name does not match' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site = $incorrectSiteName
                    Domain = $correctDomainName
                }

                Mock Get-ADDomain { return $stubDomain }
                Mock Get-ADDomainController { return $stubDomainController }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should Be $false
            }

            It 'Returns "True" when Site Name matches' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site = $correctSiteName
                    Domain = $correctDomainName
                }

                Mock Get-ADDomain { return $stubDomain }
                Mock Get-ADDomainController { return $stubDomainController }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should Be $true
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe -Tag 'xADDomainController' "$($Global:DSCResourceName)\Set-TargetResource" {
            It 'Calls "Install-ADDSDomainController" when Site Name was specified' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }
                $stubDomainController = @{
                    HostName = 'ExistingDC'
                }
                $stubSite = @{
                    Name = $existingSiteName
                }

                function Install-ADDSDomainController {
                    param(
                        $DomainName, $SafeModeAdministratorPassword, $Credential, $NoRebootOnCompletion, $Force, $DatabasePath,
                        $LogPath, $SysvolPath, $SiteName
                    )
                }

                Mock Get-ADDomain { return $stubDomain }
                Mock Get-ADDomainController { return $null }
                Mock Get-ADDomainController { return $stubDomainController } -ParameterFilter { $Discover -eq $true }
                Mock Get-ADReplicationSite { return $stubSite }
                Mock Install-ADDSDomainController -MockWith {} -ParameterFilter { $SiteName -eq $correctSiteName }

                Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                Assert-MockCalled Install-ADDSDomainController -Times 1 -Exactly -ParameterFilter { $SiteName -eq $correctSiteName } -Scope It
            }

            It 'Calls "Move-ADDirectoryServer" when Site Name does not match' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site = $incorrectSiteName
                    Domain = $correctDomainName
                }

                function Move-ADDirectoryServer {
                    param (
                        $Identity, $Site, $AuthType, $Confirm, $Credential, $Server
                    )
                }

                Mock Get-ADDomain { return $stubDomain }
                Mock Get-ADDomainController { return $stubDomainController }
                Mock Move-ADDirectoryServer -MockWith {} -ParameterFilter { $Site -eq $correctSiteName }

                Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                Assert-MockCalled Move-ADDirectoryServer -Times 1 -Exactly -ParameterFilter { $Site -eq $correctSiteName } -Scope It
            }

            It 'Does not call "Move-ADDirectoryServer" when site matches' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site = $correctSiteName
                    Domain = $correctDomainName
                    Name = 'DC'
                }

                function Move-ADDirectoryServer {
                    param (
                        $Identity, $Site, $AuthType, $Confirm, $Credential, $Server
                    )
                }

                Mock Get-ADDomain { return $stubDomain }
                Mock Get-ADDomainController { return $stubDomainController }
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
