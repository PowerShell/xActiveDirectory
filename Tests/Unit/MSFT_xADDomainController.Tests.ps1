[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

#region HEADER
$dscModuleName = (Split-Path -Path (Split-Path -Path $PSScriptRoot)).Split('\')[-1]
$dscResourceName = (Split-Path -Path $PSCommandPath -Leaf).Split('.')[0]
$moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Download DSCResource.Tests if not found, import the tests helper, and init the test environment
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $dscModuleName `
    -DSCResourceName $dscResourceName `
    -TestType Unit
#endregion

# Begin Testing
try
{
    InModuleScope $dscResourceName {

        $dscModuleName = (Split-Path -Path (Split-Path -Path $PSScriptRoot)).Split('\')[-1]
        $dscResourceName = (Split-Path -Path $PSCommandPath -Leaf).Split('.')[0]

        #Load the AD Module Stub, so we can mock the cmdlets, then load the AD types
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\ActiveDirectoryStub.psm1') -Force

        # If one type does not exist, it's assumed the other ones does not exist either.
        if (-not ('Microsoft.ActiveDirectory.Management.ADAuthType' -as [Type]))
        {
            $adModuleStub = (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\Microsoft.ActiveDirectory.Management.cs')
            Add-Type -Path $adModuleStub
        }

        #region Pester Test Variable Initialization
        $correctDomainName = 'present.com'
        $testAdminCredential = [System.Management.Automation.PSCredential]::Empty
        $correctDatabasePath = 'C:\Windows\NTDS'
        $correctLogPath = 'C:\Windows\NTDS'
        $correctSysvolPath = 'C:\Windows\SYSVOL'
        $correctSiteName = 'PresentSite'
        $incorrectSiteName = 'IncorrectSite'
        $correctInstallationMediaPath = 'Testdrive:\IFM'
        $mockNtdsSettingsObjectDn = 'CN=NTDS Settings,CN=ServerName,CN=Servers,CN=PresentSite,CN=Sites,CN=Configuration,DC=present,DC=com'

        $testDefaultParams = @{
            DomainAdministratorCredential = $testAdminCredential
            SafemodeAdministratorPassword = $testAdminCredential
        }

        $commonAssertParams = @{
            ModuleName = $dscResourceName
            Scope      = 'It'
            Exactly    = $true
        }

        #Fake function because it is only available on Windows Server
        function Install-ADDSDomainController
        {
            [CmdletBinding()]
            param
            (
                [Parameter()]
                $DomainName,

                [Parameter()]
                [System.Management.Automation.PSCredential]
                $SafeModeAdministratorPassword,

                [Parameter()]
                [System.Management.Automation.PSCredential]
                $Credential,

                [Parameter()]
                $NoRebootOnCompletion,

                [Parameter()]
                $Force,

                [Parameter()]
                $DatabasePath,

                [Parameter()]
                $LogPath,

                [Parameter()]
                $SysvolPath,

                [Parameter()]
                $SiteName,

                [Parameter()]
                $InstallationMediaPath
            )

            throw [exception] 'Not Implemented'
        }
        #endregion Pester Test Initialization

        #region Function Get-TargetResource
        Describe -Tag $dscModuleName "$dscModuleName\$dscResourceName\Get-TargetResource" {

            Context 'Normal Operations' {

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-ADDomainController {
                    return @{
                        Site                 = $correctSiteName
                        Domain               = $correctDomainName
                        IsGlobalCatalog      = $true
                    }
                }
                Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters' } -MockWith {
                    return @{
                        'Database log files path' = 'C:\Windows\NTDS'
                        'DSA Working Directory'   = 'C:\Windows\NTDS'
                    }
                }
                Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' } -MockWith {
                    return @{
                        'SysVol' = 'C:\Windows\SYSVOL\sysvol'
                    }
                }

                New-Item -Path 'TestDrive:\' -ItemType Directory -Name IFM

                $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName

                It 'Returns current Domain Controller properties' {
                    $result.DomainName | Should -Be $correctDomainName
                    $result.DatabasePath | Should -Be $correctDatabasePath
                    $result.LogPath | Should -Be $correctLogPath
                    $result.SysvolPath | Should -Be $correctSysvolPath
                    $result.SiteName | Should -Be $correctSiteName
                    $result.Ensure | Should -Be $true
                    $result.IsGlobalCatalog | Should -Be $true
                }
            }

            Context 'Domain Controller Service not installed on host' {

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-ADDomainController { throw "Cannot find directory server with identity: '$env:COMPUTERNAME'." }

                $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName

                It 'Returns Ensure = False' {
                    $result.DomainName | Should -Be $correctDomainName
                    $result.DatabasePath | Should -BeNullOrEmpty
                    $result.LogPath | Should -BeNullOrEmpty
                    $result.SysvolPath | Should -BeNullOrEmpty
                    $result.SiteName | Should -BeNullOrEmpty
                    $result.Ensure | Should -Be $false
                    $result.IsGlobalCatalog | Should -Be $false
                    $result.NtdsSettingsObjectDn | Should -BeNullOrEmpty
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe -Tag $dscModuleName "$dscModuleName\$dscResourceName\Test-TargetResource" {

            $testDefaultParams = @{
                DomainAdministratorCredential = $testAdminCredential
                SafemodeAdministratorPassword = $testAdminCredential
            }

            It 'Returns "False" when "SiteName" does not match' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site            = $incorrectSiteName
                    Domain          = $correctDomainName
                }

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-ADDomainController -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $true }
                Mock -CommandName Get-ItemProperty -MockWith { return @{ } }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should -Be $false
            }

            It 'Returns "True" when "SiteName" matches' {

                $stubDomainController = @{
                    Site   = $correctSiteName
                    Domain = $correctDomainName
                }

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-ADDomainController -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $true }
                Mock -CommandName Get-ItemProperty -MockWith { return @{ } }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should -Be $true
            }

            It 'Throws if "SiteName" is wrong' {

                $stubDomainController = @{
                    Site   = $correctSiteName
                    Domain = $correctDomainName
                }

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-ADDomainController -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $false }
                { Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $incorrectSiteName } |
                Should Throw "Site '$($incorrectSiteName)' could not be found."
            }

            It 'Returns "False" when "IsGlobalCatalog" does not match' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site            = $correctSiteName
                    Domain          = $correctDomainName
                    IsGlobalCatalog = $false
                }

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-ADDomainController -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $true }
                Mock -CommandName Get-ItemProperty -MockWith { return @{ } }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName -IsGlobalCatalog $true

                $result | Should -Be $false

            }

            It 'Returns "True" when "IsGlobalCatalog" matches' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site            = $correctSiteName
                    Domain          = $correctDomainName
                    IsGlobalCatalog = $true
                }

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-ADDomainController -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $true }
                Mock -CommandName Get-ItemProperty -MockWith { return @{ } }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName -IsGlobalCatalog $true

                $result | Should -Be $true
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe -Tag $dscModuleName "$dscModuleName\$dscResourceName\Set-TargetResource" {

            It 'Calls "Install-ADDSDomainController" with "Site", if specified' {
                Mock -CommandName Get-ADDomain -MockWith {
                    return $true
                }

                Mock -CommandName Get-TargetResource -MockWith {
                    return $stubTargetResource = @{
                        Ensure = $false
                    }
                }
                Mock -CommandName Install-ADDSDomainController -ParameterFilter { $SiteName -eq $correctSiteName }

                Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName -Verbose

                Assert-MockCalled -CommandName Install-ADDSDomainController -Times 1 -ParameterFilter { $SiteName -eq $correctSiteName }
            }

            New-Item -Path 'TestDrive:\' -ItemType Directory -Name IFM

            It 'Calls "Install-ADDSDomainController" with InstallationMediaPath specified' {
                Mock -CommandName Get-ADDomain -MockWith {
                    return $true
                }

                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        Ensure = $false
                    }
                }
                Mock -CommandName Install-ADDSDomainController -ParameterFilter { $InstallationMediaPath -eq $correctInstallationMediaPath }

                Set-TargetResource @testDefaultParams -DomainName $correctDomainName -InstallationMediaPath $correctInstallationMediaPath -Verbose

                Assert-MockCalled -CommandName Install-ADDSDomainController -Times 1 `
                    -ParameterFilter { $InstallationMediaPath -eq $correctInstallationMediaPath }  @commonAssertParams
            }

            It 'Calls "Move-ADDirectoryServer" when "SiteName" does not match' {
                Mock -CommandName Get-TargetResource -MockWith {
                    return $stubTargetResource = @{
                        Ensure   = $true
                        SiteName = 'IncorrectSite'
                    }
                }

                Mock -CommandName Move-ADDirectoryServer -ParameterFilter { $Site.ToString() -eq $correctSiteName }
                Mock -CommandName Move-ADDirectoryServer

                Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName -Verbose

                # FYI: This test will fail when run locally, but should succeed on the build server
                Assert-MockCalled -CommandName Move-ADDirectoryServer -Times 1 -ParameterFilter { $Site.ToString() -eq $correctSiteName } @commonAssertParams
            }

            It 'Does not call "Move-ADDirectoryServer" when "SiteName" matches' {
                Mock -CommandName Get-TargetResource -MockWith {
                    return $stubTargetResource = @{
                        Ensure   = $true
                        SiteName = 'PresentSite'
                    }
                }

                Mock -CommandName Move-ADDirectoryServer

                Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName -Verbose

                Assert-MockCalled -CommandName Move-ADDirectoryServer -Times 0 @commonAssertParams
            }

            It 'Does not call "Move-ADDirectoryServer" when "SiteName" is not specified' {
                Mock -CommandName Get-TargetResource -MockWith {
                    return $stubTargetResource = @{
                        Ensure   = $true
                        SiteName = 'PresentSite'
                    }
                }

                Mock -CommandName Move-ADDirectoryServer

                Set-TargetResource @testDefaultParams -DomainName $correctDomainName -Verbose

                Assert-MockCalled -CommandName Move-ADDirectoryServer -Times 0 @commonAssertParams
            }

            Context 'When specifying the parameter IsGlobalCatalog' {
                BeforeAll {
                    Mock -CommandName Set-ADObject
                    Mock -CommandName Get-ADDomainController {
                        return @{
                            Site                 = $correctSiteName
                            Domain               = $correctDomainName
                            IsGlobalCatalog      = $true
                            NTDSSettingsObjectDN = $mockNtdsSettingsObjectDn
                        }
                    }
                }

                It 'Calls "Set-ADObject" when "IsGlobalCatalog" Should -Be "True" and does not match' {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return $stubTargetResource = @{
                            Ensure               = $true
                            SiteName             = 'PresentSite'
                            IsGlobalCatalog      = $false
                        }
                    }

                    Set-TargetResource @testDefaultParams -DomainName $correctDomainName -IsGlobalCatalog $true -Verbose

                    Assert-MockCalled Set-ADObject -Times 1 -ParameterFilter {
                        $Replace['options'] -eq 1
                    } @commonAssertParams
                }

                It 'Calls "Set-ADObject" when "IsGlobalCatalog" Should -Be "False" and does not match' {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return $stubTargetResource = @{
                            Ensure               = $true
                            SiteName             = 'PresentSite'
                            IsGlobalCatalog      = $true
                        }
                    }

                    Set-TargetResource @testDefaultParams -DomainName $correctDomainName -IsGlobalCatalog $false -Verbose

                    Assert-MockCalled Set-ADObject -Times 1 -ParameterFilter {
                        $Replace['options'] -eq 0
                    } @commonAssertParams
                }

                It 'Does not call "Set-ADObject" when "IsGlobalCatalog" matches' {
                    Mock Get-TargetResource {
                        return $TargetResource = @{
                            Ensure               = $true
                            SiteName             = 'PresentSite'
                            IsGlobalCatalog      = $true
                        }
                    }

                    Set-TargetResource @testDefaultParams -DomainName $correctDomainName -IsGlobalCatalog $true -Verbose

                    Assert-MockCalled Set-ADObject -Times 0 @commonAssertParams
                }

                It 'Does not call "Set-ADObject" when "IsGlobalCatalog" is not specified' {
                    Mock Get-TargetResource {
                        return $TargetResource = @{
                            Ensure               = $true
                            SiteName             = 'PresentSite'
                            IsGlobalCatalog      = $false
                        }
                    }

                    Set-TargetResource @testDefaultParams -DomainName $correctDomainName -Verbose

                    Assert-MockCalled Set-ADObject -Times 0 @commonAssertParams
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

