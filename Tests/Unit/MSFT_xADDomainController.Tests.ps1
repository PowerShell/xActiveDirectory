[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', 'PSAvoidUsingPlainTextForPassword')]
param()

#region HEADER
$script:dscModuleName = 'xActiveDirectory'
$script:dscResourceName = 'MSFT_xADDomainController'

# Unit Test Template Version: 1.2.4
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
(-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git.exe @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

# TODO: Insert the correct <ModuleName> and <ResourceName> for your resource
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
        $correctInstallationMediaPath = 'TestDrive:\IFM'
        $mockNtdsSettingsObjectDn = 'CN=NTDS Settings,CN=ServerName,CN=Servers,CN=PresentSite,CN=Sites,CN=Configuration,DC=present,DC=com'
        $allowedAccount = 'allowedAccount'
        $deniedAccount = 'deniedAccount'

        $testDefaultParams = @{
            DomainAdministratorCredential = $testAdminCredential
            SafemodeAdministratorPassword = $testAdminCredential
            Verbose                       = $true
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
                $InstallationMediaPath,

                [Parameter()]
                $NoGlobalCatalog,

                [Parameter()]
                [System.String[]]
                $AllowPasswordReplicationAccountName,

                [Parameter()]
                [System.String[]]
                $DenyPasswordReplicationAccountName
            )

            throw [exception] 'Not Implemented'
        }
        #endregion Pester Test Initialization

        #region Function Get-TargetResource
        Describe 'xActiveDirectory\Get-TargetResource' -Tag 'Get' {
            Context 'When the domain name is not available' {
                BeforeAll {
                    Mock -CommandName Get-ADDomain -MockWith {
                        throw New-Object -TypeName 'Microsoft.ActiveDirectory.Management.ADServerDownException'
                    }
                }

                It 'Should throw the correct error' {
                    { Get-TargetResource @testDefaultParams -DomainName $correctDomainName } | Should -Throw ($script:localizedData.MissingDomain -f $correctDomainName)
                }
            }

            Context 'Normal Operations' {

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-DomainControllerObject {
                    $domainControllerObject = New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController
                    $domainControllerObject.Site = $correctSiteName
                    $domainControllerObject.Domain = $correctDomainName
                    $domainControllerObject.IsGlobalCatalog = $true
                    return $domainControllerObject
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

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Allowed.IsPresent } -MockWith {
                    return [PSCustomObject]@{
                        SamAccountName = $allowedAccount
                    }
                }

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Denied.IsPresent } -MockWith {
                    return [PSCustomObject]@{
                        SamAccountName = $deniedAccount
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
                    $result.AllowPasswordReplicationAccountName | Should -Be $allowedAccount
                    $result.DenyPasswordReplicationAccountName | Should -Be $deniedAccount
                }
            }

            Context 'Domain Controller Service not installed on host' {

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-DomainControllerObject -MockWith {
                    return $null
                }

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
        Describe 'xActiveDirectory\Test-TargetResource' -Tag 'Test' {
            BeforeAll {
                $testDefaultParams = @{
                    DomainAdministratorCredential = $testAdminCredential
                    SafemodeAdministratorPassword = $testAdminCredential
                    Verbose                       = $true
                }

                $stubDomainController = New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController
                $stubDomainController.Domain = $correctDomainName

                Mock -CommandName Get-DomainControllerObject -MockWith { return $stubDomainController }

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Allowed.IsPresent } -MockWith {
                    return [PSCustomObject]@{
                        SamAccountName = $allowedAccount
                    }
                }

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Denied.IsPresent } -MockWith {
                    return [PSCustomObject]@{
                        SamAccountName = $deniedAccount
                    }
                }

            }
            It 'Returns "False" when "SiteName" does not match' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController
                $stubDomainController.Site = $incorrectSiteName
                $stubDomainController.Domain = $correctDomainName


                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-DomainControllerObject -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $true }
                Mock -CommandName Get-ItemProperty -MockWith { return @{ } }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should -Be $false
            }


            It 'Returns "True" when "SiteName" matches' {

                $stubDomainController = New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController
                $stubDomainController.Site = $correctSiteName
                $stubDomainController.Domain = $correctDomainName

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-DomainControllerObject -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $true }
                Mock -CommandName Get-ItemProperty -MockWith { return @{ } }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should -Be $true
            }

            It 'Throws if "SiteName" is wrong' {

                $stubDomainController = New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController
                $stubDomainController.Site = $correctSiteName
                $stubDomainController.Domain = $correctDomainName


                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-DomainControllerObject -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $false }

                {
                    Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $incorrectSiteName
                } | Should -Throw ($script:localizedData.FailedToFindSite -f $incorrectSiteName, $correctDomainName)
            }

            It 'Returns "False" when "IsGlobalCatalog" does not match' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController
                $stubDomainController.Site = $correctSiteName
                $stubDomainController.Domain = $correctDomainName
                $stubDomainController.IsGlobalCatalog = $false

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-DomainControllerObject -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $true }
                Mock -CommandName Get-ItemProperty -MockWith { return @{ } }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName -IsGlobalCatalog $true

                $result | Should -Be $false
            }

            It 'Returns "True" when "IsGlobalCatalog" matches' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController
                $stubDomainController.Site = $correctSiteName
                $stubDomainController.Domain = $correctDomainName
                $stubDomainController.IsGlobalCatalog = $true

                Mock -CommandName Get-ADDomain -MockWith { return $true }
                Mock -CommandName Get-DomainControllerObject -MockWith { return $stubDomainController }
                Mock -CommandName Test-ADReplicationSite -MockWith { return $true }
                Mock -CommandName Get-ItemProperty -MockWith { return @{ } }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName -IsGlobalCatalog $true

                $result | Should -Be $true
            }

            It 'Returns "True" when AllowPasswordReplicationAccountName matches' {

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Allowed.IsPresent } -MockWith {
                    return @(
                    [PSCustomObject]@{
                        SamAccountName = 'allowedAccount1'
                    }
                    [PSCustomObject]@{
                        SamAccountName = 'allowedAccount2'
                    }
                    )
                }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -AllowPasswordReplicationAccountName 'allowedAccount1', 'allowedAccount2'

                $result | Should -Be $true
            }

            It 'Returns "False" when AllowPasswordReplicationAccountName contains more accounts than expected' {

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Allowed.IsPresent } -MockWith {
                    return @(
                    [PSCustomObject]@{
                        SamAccountName = 'allowedAccount1'
                    }
                    [PSCustomObject]@{
                        SamAccountName = 'allowedAccount2'
                    }
                    [PSCustomObject]@{
                        SamAccountName = 'allowedAccount3'
                    }
                    )
                }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -AllowPasswordReplicationAccountName 'allowedAccount1', 'allowedAccount2'

                $result | Should -Be $false
            }

            It 'Returns "False" when AllowPasswordReplicationAccountName contains less accounts than expected' {

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Allowed.IsPresent } -MockWith {
                    return @(
                    [PSCustomObject]@{
                        SamAccountName = 'allowedAccount1'
                    }
                    )
                }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -AllowPasswordReplicationAccountName 'allowedAccount1', 'allowedAccount2'

                $result | Should -Be $false

            }

            It 'Returns "False" when AllowPasswordReplicationAccountName contains different accounts than expected' {

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Allowed.IsPresent } -MockWith {
                    return @(
                    [PSCustomObject]@{
                        SamAccountName = 'allowedAccount3'
                    }
                    [PSCustomObject]@{
                        SamAccountName = 'allowedAccount4'
                    }
                    )
                }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -AllowPasswordReplicationAccountName 'allowedAccount1', 'allowedAccount2'

                $result | Should -Be $false

            }

            It 'Returns "True" when DenyPasswordReplicationAccountName matches' {

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Denied.IsPresent } -MockWith {
                    return @(
                    [PSCustomObject]@{
                        SamAccountName = 'deniedAccount1'
                    }
                    [PSCustomObject]@{
                        SamAccountName = 'deniedAccount2'
                    }
                    )
                }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -DenyPasswordReplicationAccountName 'deniedAccount1', 'deniedAccount2'

                $result | Should -Be $true
            }

            It 'Returns "False" when DenyPasswordReplicationAccountName contains more accounts than expected' {

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Denied.IsPresent } -MockWith {
                    return @(
                    [PSCustomObject]@{
                        SamAccountName = 'deniedAccount1'
                    }
                    [PSCustomObject]@{
                        SamAccountName = 'deniedAccount2'
                    }
                    [PSCustomObject]@{
                        SamAccountName = 'deniedAccount3'
                    }
                    )
                }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -DenyPasswordReplicationAccountName 'deniedAccount1', 'deniedAccount2'

                $result | Should -Be $false
            }

            It 'Returns "False" when DenyPasswordReplicationAccountName contains less accounts than expected' {

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Denied.IsPresent } -MockWith {
                    return @(
                    [PSCustomObject]@{
                        SamAccountName = 'deniedAccount1'
                    }
                    )
                }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -DenyPasswordReplicationAccountName 'deniedAccount1', 'deniedAccount2'

                $result | Should -Be $false

            }

            It 'Returns "False" when DenyPasswordReplicationAccountName contains different accounts than expected' {

                Mock -CommandName Get-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $Denied.IsPresent } -MockWith {
                    return @(
                    [PSCustomObject]@{
                        SamAccountName = 'deniedAccount3'
                    }
                    [PSCustomObject]@{
                        SamAccountName = 'deniedAccount4'
                    }
                    )
                }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -DenyPasswordReplicationAccountName 'deniedAccount1', 'deniedAccount2'

                $result | Should -Be $false

            }

        }
        #endregion

        #region Function Set-TargetResource
        Describe 'xActiveDirectory\Set-TargetResource' -Tag 'Set' {
            Context 'When the system is not in the desired state' {
                BeforeAll {
                    Mock -CommandName Install-ADDSDomainController
                    Mock -CommandName Remove-ADDomainControllerPasswordReplicationPolicy
                    Mock -CommandName Add-ADDomainControllerPasswordReplicationPolicy
                    Mock -CommandName Get-ADDomain -MockWith {
                        return $true
                    }

                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            Ensure = $false
                        }
                    }
                }

                Context 'When adding a domain controller to a specific site' {
                    It 'It should call the correct mocks' {
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName } | Should -Not -Throw

                        Assert-MockCalled -CommandName Install-ADDSDomainController -ParameterFilter {
                            $SiteName -eq $correctSiteName
                        } -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When adding a domain controller to a specific database path' {
                    It 'It should call the correct mocks' {
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -DatabasePath $correctDatabasePath } | Should -Not -Throw

                        Assert-MockCalled -CommandName Install-ADDSDomainController -ParameterFilter {
                            $DatabasePath -eq $correctDatabasePath
                        } -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When adding a domain controller to a specific SysVol path' {
                    It 'It should call the correct mocks' {
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SysVolPath $correctSysvolPath } | Should -Not -Throw

                        Assert-MockCalled -CommandName Install-ADDSDomainController -ParameterFilter {
                            $SysVolPath -eq $correctSysvolPath
                        } -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When adding a domain controller to a specific log path' {
                    It 'It should call the correct mocks' {
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -LogPath $correctLogPath } | Should -Not -Throw

                        Assert-MockCalled -CommandName Install-ADDSDomainController -ParameterFilter {
                            $LogPath -eq $correctLogPath
                        } -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When adding a domain controller that should not be a Global Catalog' {
                    It 'It should call the correct mocks' {
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -IsGlobalCatalog $false } | Should -Not -Throw

                        Assert-MockCalled -CommandName Install-ADDSDomainController -ParameterFilter {
                            $NoGlobalCatalog -eq $true
                        } -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When adding a domain controller using IFM' {
                    BeforeAll {
                        New-Item -Path $correctInstallationMediaPath -ItemType 'Directory' -Force
                    }

                    It 'It should call the correct mocks' {
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -InstallationMediaPath $correctInstallationMediaPath } | Should -Not -Throw

                        Assert-MockCalled -CommandName Install-ADDSDomainController -ParameterFilter {
                            $InstallationMediaPath -eq $correctInstallationMediaPath
                        } -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When adding a domain controller with AllowPasswordReplicationAccountName' {

                    It 'It should call the correct mocks' {
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -AllowPasswordReplicationAccountName $allowedAccount } | Should -Not -Throw

                        Assert-MockCalled -CommandName Install-ADDSDomainController -ParameterFilter {
                            $AllowPasswordReplicationAccountName -eq $allowedAccount
                        } -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When adding a domain controller with DenyPasswordReplicationAccountName' {

                    It 'It should call the correct mocks' {
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -DenyPasswordReplicationAccountName $deniedAccount } | Should -Not -Throw

                        Assert-MockCalled -CommandName Install-ADDSDomainController -ParameterFilter {
                            $DenyPasswordReplicationAccountName -eq $deniedAccount
                        } -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When a domain controller is in the wrong site' {
                    BeforeAll {
                        Mock -CommandName Move-ADDirectoryServer
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Ensure   = $true
                                SiteName = 'IncorrectSite'
                            }
                        }
                        #Without this line the local tests are crashing powershell.exe (both 5 and 6). See line 606
                        Mock -CommandName Get-DomainControllerObject -MockWith {
                            return (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController)
                        }
                    }

                    It 'Should call the correct mocks to move the domain controller to the correct site' {
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName } | Should -Not -Throw

                        # FYI: This test will fail when run locally, but should succeed on the build server
                        Assert-MockCalled -CommandName Move-ADDirectoryServer -ParameterFilter {
                            $Site.ToString() -eq $correctSiteName
                        } -Exactly -Times 1 -Scope It
                    }

                    Context 'When the domain controller is in the wrong site, but SiteName is not specified' {
                        It 'Should not move the domain controller' {
                            { Set-TargetResource @testDefaultParams -DomainName $correctDomainName } | Should -Not -Throw

                            Assert-MockCalled -CommandName Move-ADDirectoryServer  -Exactly -Times 0 -Scope It
                        }
                    }
                }

                Context 'When specifying the IsGlobalCatalog parameter' {
                    BeforeAll {
                        Mock -CommandName Set-ADObject
                        Mock -CommandName Get-DomainControllerObject {
                            return @{
                                NTDSSettingsObjectDN = $mockNtdsSettingsObjectDn
                            }
                        }
                    }

                    Context 'When the domain controller should be a Global Catalog' {
                        BeforeAll {
                            Mock -CommandName Get-TargetResource -MockWith {
                                return $stubTargetResource = @{
                                    Ensure          = $true
                                    SiteName        = 'PresentSite'
                                    IsGlobalCatalog = $false
                                }
                            }
                        }

                        It 'Should call the correct mocks' {
                            { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -IsGlobalCatalog $true } | Should -Not -Throw

                            Assert-MockCalled -CommandName Set-ADObject -ParameterFilter {
                                $Replace['options'] -eq 1
                            } -Exactly -Times 1 -Scope It
                        }
                    }

                    Context 'When the domain controller should not be a Global Catalog' {
                        BeforeAll {
                            Mock -CommandName Get-TargetResource -MockWith {
                                return $stubTargetResource = @{
                                    Ensure          = $true
                                    SiteName        = 'PresentSite'
                                    IsGlobalCatalog = $true
                                }
                            }
                        }

                        It 'Should call the correct mocks' {
                            { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -IsGlobalCatalog $false } | Should -Not -Throw

                            Assert-MockCalled -CommandName Set-ADObject -ParameterFilter {
                                $Replace['options'] -eq 0
                            } -Exactly -Times 1 -Scope It
                        }
                    }

                    Context 'When the domain controller should change state of Global Catalog, but fail to return a domain controller object' {
                        BeforeAll {
                            Mock -CommandName Get-TargetResource -MockWith {
                                return $stubTargetResource = @{
                                    Ensure          = $true
                                    SiteName        = 'PresentSite'
                                    IsGlobalCatalog = $true
                                }
                            }

                            Mock -CommandName Get-DomainControllerObject
                        }

                        It 'Should call the correct mocks' {
                            { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -IsGlobalCatalog $false } | Should -Throw $script:localizedData.ExpectedDomainController

                            Assert-MockCalled -CommandName Set-ADObject -Exactly -Times 0 -Scope It
                        }
                    }
                }

                Context 'When AllowPasswordReplicationAccountName is not compliant' {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            Ensure                              = $true
                            AllowPasswordReplicationAccountName = 'allowedAccount2'
                        }
                    }

                    Mock -CommandName Get-DomainControllerObject -MockWith {
                        return (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController)
                    }

                    It "Should call the correct mock to set AllowPasswordReplicationAccountName Attribute" {
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -AllowPasswordReplicationAccountName $allowedAccount } | Should -Not -Throw

                        Assert-MockCalled -CommandName Remove-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $AllowedList.SamAccountName -eq 'allowedAccount2' } -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Add-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $AllowedList.SamAccountName -eq $allowedAccount } -Exactly -Times 1 -Scope It
                    }
                }
                Context 'When DenyPasswordReplicationAccountName is not compliant' {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            Ensure                             = $true
                            DenyPasswordReplicationAccountName = 'deniedAccount2'
                        }
                    }

                    Mock -CommandName Get-DomainControllerObject -MockWith {
                        return (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController)
                    }

                    It "Should call the correct mock to set DenyPasswordReplicationAccountName Attribute" {
                        { Set-TargetResource @testDefaultParams  -DomainName $correctDomainName -DenyPasswordReplicationAccountName $deniedAccount } | Should -Not -Throw

                        Assert-MockCalled -CommandName Remove-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $DeniedList.SamAccountName -eq 'deniedAccount2' } -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Add-ADDomainControllerPasswordReplicationPolicy -ParameterFilter { $DeniedList.SamAccountName -eq $deniedAccount } -Exactly -Times 1 -Scope It
                    }
                }
            }

            Context 'When the system is in the desired state' {
                BeforeAll {
                    Mock -CommandName Remove-ADDomainControllerPasswordReplicationPolicy
                    Mock -CommandName Add-ADDomainControllerPasswordReplicationPolicy
                }

                Context 'When a domain controller is in the correct site' {
                    BeforeAll {
                        Mock -CommandName Move-ADDirectoryServer
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Ensure   = $true
                                SiteName = 'PresentSite'
                            }
                        }
                        Mock -CommandName Get-DomainControllerObject {
                            return (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController)
                        }
                    }

                    It 'Should not move the domain controller' {
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName } | Should -Not -Throw

                        Assert-MockCalled -CommandName Move-ADDirectoryServer -Exactly -Times 0 -Scope It
                    }
                }

                Context 'When specifying the IsGlobalCatalog parameter' {
                    BeforeAll {
                        Mock -CommandName Set-ADObject
                        Mock -CommandName Get-DomainControllerObject {
                            return @{
                                NTDSSettingsObjectDN = $mockNtdsSettingsObjectDn
                            }
                        }
                    }

                    Context 'When the domain controller should be a Global Catalog' {
                        BeforeAll {
                            Mock -CommandName Get-TargetResource -MockWith {
                                return $stubTargetResource = @{
                                    Ensure          = $true
                                    SiteName        = 'PresentSite'
                                    IsGlobalCatalog = $false
                                }
                            }
                        }

                        It 'Should call the correct mocks' {
                            { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -IsGlobalCatalog $true } | Should -Not -Throw

                            Assert-MockCalled -CommandName Set-ADObject -ParameterFilter {
                                $Replace['options'] -eq 1
                            } -Exactly -Times 1 -Scope It
                        }
                    }

                    Context 'When the domain controller already is a Global Catalog' {
                        BeforeAll {
                            Mock -CommandName Get-TargetResource -MockWith {
                                return $stubTargetResource = @{
                                    Ensure          = $true
                                    SiteName        = 'PresentSite'
                                    IsGlobalCatalog = $true
                                }
                            }
                        }

                        It 'Should not call the mock Set-ADObject' {
                            { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -IsGlobalCatalog $true } | Should -Not -Throw

                            Assert-MockCalled -CommandName Set-ADObject -Exactly -Times 0 -Scope It
                        }
                    }

                    Context 'When the domain controller already are not a Global Catalog' {
                        BeforeAll {
                            Mock -CommandName Get-TargetResource -MockWith {
                                return $stubTargetResource = @{
                                    Ensure          = $true
                                    SiteName        = 'PresentSite'
                                    IsGlobalCatalog = $false
                                }
                            }
                        }

                        It 'Should not call the mock Set-ADObject' {
                            { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -IsGlobalCatalog $false } | Should -Not -Throw

                            Assert-MockCalled -CommandName Set-ADObject -Exactly -Times 0 -Scope It
                        }
                    }
                }

                Context 'When RODC Sync Accounts are compliant' {
                    BeforeAll {
                        Mock -CommandName Get-DomainControllerObject -MockWith {
                            return (New-Object -TypeName Microsoft.ActiveDirectory.Management.ADDomainController)
                        }
                    }

                    It 'AllowPasswordReplicationAccountName is correct' {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Ensure                              = $true
                                AllowPasswordReplicationAccountName = $allowedAccount
                            }
                        }
                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -AllowPasswordReplicationAccountName $allowedAccount } | Should -Not -Throw

                        Assert-MockCalled -CommandName Remove-ADDomainControllerPasswordReplicationPolicy -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Add-ADDomainControllerPasswordReplicationPolicy -Exactly -Times 0 -Scope It
                    }

                    It 'DenyPasswordReplicationAccountName is correct' {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Ensure                             = $true
                                DenyPasswordReplicationAccountName = $deniedAccount
                            }
                        }

                        { Set-TargetResource @testDefaultParams -DomainName $correctDomainName -DenyPasswordReplicationAccountName $deniedAccount } | Should -Not -Throw

                        Assert-MockCalled -CommandName Remove-ADDomainControllerPasswordReplicationPolicy -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Add-ADDomainControllerPasswordReplicationPolicy -Exactly -Times 0 -Scope It
                    }
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
