$script:dscModuleName = 'ActiveDirectoryDsc'
$script:dscResourceName = 'MSFT_ADDomain'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

# Begin Testing

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        Set-StrictMode -Version 1.0

        # Load stub cmdlets and classes.
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\ActiveDirectory_2019.psm1') -Force
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\ADDSDeployment_2019.psm1') -Force

        $mockDomainName = 'contoso.com'
        $mockForestName = 'contoso.com'
        $mockDnsRootProperty = 'contoso.com'
        $mockNetBiosName = 'CONTOSO'
        $mockDnsRoot = $mockDomainName
        $mockParentDomainName = ''
        $mockDomainFQDN = $mockDomainName
        $mockNTDSPath = 'C:\Windows\NTDS'
        $mockSysVolPath = 'C:\Windows\SysVol'
        $mockDomainSysVolPath = Join-Path -Path $mockSysVolPath -ChildPath $mockDomainName
        $maxRetries = 15
        $forestMode = [Microsoft.DirectoryServices.Deployment.Types.ForestMode]::WinThreshold
        $mgmtForestMode = [Microsoft.ActiveDirectory.Management.ADForestMode]::Windows2016Forest
        $domainMode = [Microsoft.DirectoryServices.Deployment.Types.DomainMode]::WinThreshold
        $mgmtDomainMode = [Microsoft.ActiveDirectory.Management.ADDomainMode]::Windows2016Domain
        $NTDSParametersRegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters'
        $NetlogonParametersRegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'

        $mockAdministratorCredential = [System.Management.Automation.PSCredential]::new('DummyUser',
            (ConvertTo-SecureString -String 'DummyPassword' -AsPlainText -Force))
        $mockSafemodePassword = (ConvertTo-SecureString -String 'DummyPassword' -AsPlainText -Force)
        $mockSafemodeCredential = [System.Management.Automation.PSCredential]::new('Safemode', $mockSafemodePassword)

        $mockADDomainAbsent = @{
            DomainName                    = $mockDomainName
            Credential                    = $mockAdministratorCredential
            SafeModeAdministratorPassword = $mockSafemodeCredential
            ParentDomainName              = $mockParentDomainName
            DomainNetBiosName             = $null
            DnsDelegationCredential       = $null
            DatabasePath                  = $null
            LogPath                       = $null
            SysvolPath                    = $null
            ForestMode                    = $null
            DomainMode                    = $null
            DomainExist                   = $false
            Forest                        = $null
            DnsRoot                       = $null
        }

        $mockADDomainPresent = @{
            DomainName                    = $mockDomainName
            Credential                    = $mockAdministratorCredential
            SafeModeAdministratorPassword = $mockSafemodeCredential
            ParentDomainName              = $mockParentDomainName
            DomainNetBiosName             = $mockNetBiosName
            DnsDelegationCredential       = $null
            DatabasePath                  = $mockNTDSPath
            LogPath                       = $mockNTDSPath
            SysvolPath                    = $mockSysVolPath
            ForestMode                    = $ForestMode
            DomainMode                    = $DomainMode
            DomainExist                   = $true
            Forest                        = $mockForestName
            DnsRoot                       = $mockDnsRootProperty
        }

        Describe 'ADDomain\Get-TargetResource' {
            BeforeAll {
                $mockGetTargetResourceParameters = @{
                    DomainName                    = $mockDomainName
                    Credential                    = $mockAdministratorCredential
                    SafeModeAdministratorPassword = $mockSafemodeCredential
                }

                Mock -CommandName Assert-Module
                Mock -CommandName Test-Path `
                    -ParameterFilter { $Path -eq $mockDomainSysVolPath } `
                    -MockWith { $true }
                Mock -CommandName Get-AdDomain `
                    -MockWith { $mockGetADDomainResult }
                Mock -CommandName Get-AdForest `
                    -MockWith { $mockGetADForestResult }
                Mock -CommandName Get-ItemProperty `
                    -ParameterFilter { $Path -eq $NTDSParametersRegPath } `
                    -MockWith { $mockGetItemPropertyNTDSResult }
                Mock -CommandName Get-ItemProperty `
                    -ParameterFilter { $Path -eq $NetlogonParametersRegPath } `
                    -MockWith { $mockGetItemPropertyNetlogonResult }
            }

            Context 'When the domain has not yet been installed' {
                BeforeAll {
                    Mock -CommandName Get-ItemPropertyValue `
                        -ParameterFilter {
                        $Path -eq $NetlogonParametersRegPath -and $Name -eq 'SysVol' } `
                        -MockWith { throw [System.Management.Automation.ProviderInvocationException] }

                    $result = Get-TargetResource @mockGetTargetResourceParameters
                }

                foreach ($property in $mockADDomainAbsent.Keys)
                {
                    It "Should return the correct $property property" {
                        $result.$property | Should -Be $mockADDomainAbsent.$property
                    }
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Assert-Module `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ItemPropertyValue `
                        -ParameterFilter { $Path -eq $NetlogonParametersRegPath `
                            -and $Name -eq 'SysVol' } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Test-Path `
                        -Exactly -Times 0
                    Assert-MockCalled -CommandName Get-ADDomain `
                        -Exactly -Times 0
                    Assert-MockCalled -CommandName Get-ADForest `
                        -Exactly -Times 0
                    Assert-MockCalled -CommandName Get-ItemProperty `
                        -Exactly -Times 0
                }
            }

            Context 'When the domain has been installed' {
                BeforeAll {
                    $mockGetADDomainResult = @{
                        Forest       = $mockForestName
                        DomainMode   = $mgmtDomainMode
                        ParentDomain = $mockParentDomainName
                        NetBIOSName  = $mockNetBiosName
                        DnsRoot      = $mockDnsRoot
                    }

                    $mockGetADForestResult = @{
                        Name       = $mockForestName
                        ForestMode = $mgmtForestMode
                    }

                    $mockGetItemPropertyNTDSResult = @{
                        'DSA Working Directory'   = $mockNTDSPath
                        'Database log files path' = $mockNTDSPath
                    }

                    $mockGetItemPropertyNetlogonResult = @{
                        SysVol = $mockSysVolPath + '\sysvol'
                    }

                    Mock -CommandName Get-ItemPropertyValue `
                        -ParameterFilter { $Path -eq $NetlogonParametersRegPath `
                            -and $Name -eq 'SysVol' } `
                        -MockWith { $mockSysVolPath }

                    $result = Get-TargetResource @mockGetTargetResourceParameters
                }

                foreach ($property in $mockADDomainPresent.Keys)
                {
                    It "Should return the correct $property property" {
                        $result.$property | Should -Be $mockADDomainPresent.$property
                    }
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Assert-Module `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ItemPropertyValue `
                        -ParameterFilter { $Path -eq $NetlogonParametersRegPath -and $Name -eq 'SysVol' } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Test-Path `
                        -ParameterFilter { $Path -eq $mockDomainSysVolPath } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ADDomain `
                        -ParameterFilter { $Identity -eq $mockDomainFQDN } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ADForest `
                        -ParameterFilter { $Identity -eq $mockForestName } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ItemProperty `
                        -ParameterFilter { $Path -eq $NetlogonParametersRegPath } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ItemProperty `
                        -ParameterFilter { $Path -eq $NTDSParametersRegPath } `
                        -Exactly -Times 1
                }

                Context 'When the correct domain SysVol path does not exist' {
                    BeforeAll {
                        Mock -CommandName Test-Path `
                            -ParameterFilter { $Path -eq $mockDomainSysVolPath } `
                            -MockWith { $false }
                    }

                    It 'Should throw the correct exception' {
                        { Get-TargetResource @mockGetTargetResourceParameters } |
                            Should -Throw ($script:localizedData.SysVolPathDoesNotExistError -f $mockDomainSysVolPath)
                    }
                }

                Context 'When Get-ADDomain throws an unexpected error' {
                    BeforeAll {
                        Mock -CommandName Get-AdDomain `
                            -MockWith { Throw 'Unknown Error' }
                    }

                    It 'Should throw the correct exception' {
                        { Get-TargetResource @mockGetTargetResourceParameters } |
                            Should -Throw ($script:localizedData.GetAdDomainUnexpectedError -f $mockDomainFQDN)
                    }
                }

                Context 'When Get-ADDomain throws an ADServerDownException until timeout' {
                    BeforeAll {
                        Mock -CommandName Get-AdDomain `
                            -MockWith { throw New-Object -TypeName 'Microsoft.ActiveDirectory.Management.ADServerDownException' }
                        Mock -CommandName Start-Sleep
                    }

                    It 'Should throw the correct exception' {
                        { Get-TargetResource @mockGetTargetResourceParameters } |
                            Should -Throw ($script:localizedData.MaxDomainRetriesReachedError -f $mockDomainFQDN)
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-ADDomain `
                            -ParameterFilter { $Identity -eq $mockDomainFQDN } `
                            -Exactly -Times $maxRetries
                        Assert-MockCalled -CommandName Start-Sleep `
                            -Exactly -Times $maxRetries
                    }
                }

                Context 'When Get-ADForest throws an unexpected error' {
                    BeforeAll {
                        Mock -CommandName Get-AdForest `
                            -MockWith { Throw 'Unknown Error' }
                    }

                    It 'Should throw the correct exception' {
                        { Get-TargetResource @mockGetTargetResourceParameters } |
                            Should -Throw ($script:localizedData.GetAdForestUnexpectedError -f $mockForestName)
                    }
                }
            }
        }

        Describe 'ADDomain\Test-TargetResource' {
            $mockTestTargetResourceParameters = @{
                DomainName                    = $mockDomainName
                Credential                    = $mockAdministratorCredential
                SafeModeAdministratorPassword = $mockSafemodeCredential
            }

            It 'Returns "True" when the resource is in the desired state' {
                Mock -CommandName Get-TargetResource -MockWith { return $mockADDomainPresent }

                Test-TargetResource @mockTestTargetResourceParameters | Should -BeTrue
            }

            It 'Returns "False" when the resource is not in the desired state' {
                Mock -CommandName Get-TargetResource -MockWith { return $mockADDomainAbsent }

                Test-TargetResource @mockTestTargetResourceParameters | Should -BeFalse
            }
        }

        Describe 'ADDomain\Set-TargetResource' {
            $mockDomainName = 'present.com'
            $mockParentDomainName = 'parent.com'
            $mockDomainNetBIOSNameName = 'PRESENT'
            $mockDomainForestMode = 'WinThreshold'
            $mockPath = 'TestPath'

            $mockDelegationCredential = [System.Management.Automation.PSCredential]::new('Delegation',
                (ConvertTo-SecureString -String 'DummyPassword' -AsPlainText -Force))

            $setTargetResourceForestParams = @{
                DomainName                    = $mockDomainName
                Credential                    = $mockAdministratorCredential
                SafeModeAdministratorPassword = $mockSafemodeCredential
            }

            $setTargetResourceDomainParams = @{
                DomainName                    = $mockDomainName
                ParentDomainName              = $mockParentDomainName
                Credential                    = $mockAdministratorCredential
                SafeModeAdministratorPassword = $mockSafemodeCredential
            }

            Mock -CommandName Get-TargetResource -MockWith { return $mockADDomainAbsent }

            Context 'When Installing a Forest Root Domain' {
                BeforeAll {
                    Mock -CommandName Install-ADDSForest
                }

                It 'Calls "Install-ADDSForest" with "DomainName"' {
                    Set-TargetResource @setTargetResourceForestParams

                    Assert-MockCalled -CommandName Install-ADDSForest `
                        -ParameterFilter { $DomainName -eq $mockDomainName }
                }

                It 'Calls "Install-ADDSForest" with "SafeModeAdministratorPassword"' {
                    Set-TargetResource @setTargetResourceForestParams

                    Assert-MockCalled -CommandName Install-ADDSForest `
                        -ParameterFilter { $SafeModeAdministratorPassword -eq $mockSafemodePassword }
                }

                It 'Calls "Install-ADDSForest" with "DnsDelegationCredential", if specified' {
                    Set-TargetResource @setTargetResourceForestParams `
                        -DnsDelegationCredential $mockDelegationCredential

                    Assert-MockCalled -CommandName Install-ADDSForest `
                        -ParameterFilter { $DnsDelegationCredential -eq $mockDelegationCredential }
                }

                It 'Calls "Install-ADDSForest" with "CreateDnsDelegation", if specified' {
                    Set-TargetResource @setTargetResourceForestParams `
                        -DnsDelegationCredential $mockDelegationCredential

                    Assert-MockCalled -CommandName Install-ADDSForest `
                        -ParameterFilter { $CreateDnsDelegation -eq $true }
                }

                It 'Calls "Install-ADDSForest" with "DatabasePath", if specified' {
                    Set-TargetResource @setTargetResourceForestParams -DatabasePath $mockPath

                    Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter { $DatabasePath -eq $mockPath }
                }

                It 'Calls "Install-ADDSForest" with "LogPath", if specified' {
                    Set-TargetResource @setTargetResourceForestParams -LogPath $mockPath

                    Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter { $LogPath -eq $mockPath }
                }

                It 'Calls "Install-ADDSForest" with "SysvolPath", if specified' {
                    Set-TargetResource @setTargetResourceForestParams -SysvolPath $mockPath

                    Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter { $SysvolPath -eq $mockPath }
                }

                It 'Calls "Install-ADDSForest" with "DomainNetbiosName", if specified' {
                    Set-TargetResource @setTargetResourceForestParams -DomainNetBIOSName $mockDomainNetBIOSNameName

                    Assert-MockCalled -CommandName Install-ADDSForest `
                        -ParameterFilter { $DomainNetbiosName -eq $mockDomainNetBIOSNameName }
                }

                It 'Calls "Install-ADDSForest" with "ForestMode", if specified' {
                    Set-TargetResource @setTargetResourceForestParams -ForestMode $mockDomainForestMode

                    Assert-MockCalled -CommandName Install-ADDSForest `
                        -ParameterFilter { $ForestMode -eq $mockDomainForestMode }
                }

                It 'Calls "Install-ADDSForest" with "DomainMode", if specified' {
                    Set-TargetResource @setTargetResourceForestParams -DomainMode $mockDomainForestMode

                    Assert-MockCalled -CommandName Install-ADDSForest `
                        -ParameterFilter { $DomainMode -eq $mockDomainForestMode }
                }
            }

            Context 'When Installing a Child Domain' {
                BeforeAll {
                    Mock -CommandName Install-ADDSDomain
                }

                It 'Calls "Install-ADDSDomain" with "NewDomainName"' {
                    Set-TargetResource @setTargetResourceDomainParams

                    Assert-MockCalled -CommandName Install-ADDSDomain `
                        -ParameterFilter { $NewDomainName -eq $mockDomainName }
                }

                It 'Calls "Install-ADDSDomain" with "ParentDomainName"' {
                    Set-TargetResource @setTargetResourceDomainParams

                    Assert-MockCalled -CommandName Install-ADDSDomain `
                        -ParameterFilter { $ParentDomainName -eq $mockParentDomainName }
                }

                It 'Calls "Install-ADDSDomain" with "DomainType"' {
                    Set-TargetResource @setTargetResourceDomainParams

                    Assert-MockCalled -CommandName Install-ADDSDomain `
                        -ParameterFilter { $DomainType -eq 'ChildDomain' }
                }

                It 'Calls "Install-ADDSDomain" with "SafeModeAdministratorPassword"' {
                    Set-TargetResource @setTargetResourceDomainParams

                    Assert-MockCalled -CommandName Install-ADDSDomain `
                        -ParameterFilter { $SafeModeAdministratorPassword -eq $mockSafemodePassword }
                }

                It 'Calls "Install-ADDSDomain" with "Credential"' {
                    Set-TargetResource @setTargetResourceDomainParams

                    Assert-MockCalled -CommandName Install-ADDSDomain `
                        -ParameterFilter { $ParentDomainName -eq $mockParentDomainName }
                }

                It 'Calls "Install-ADDSDomain" with "ParentDomainName"' {
                    Set-TargetResource @setTargetResourceDomainParams

                    Assert-MockCalled -CommandName Install-ADDSDomain `
                        -ParameterFilter { $ParentDomainName -eq $mockParentDomainName }
                }

                It 'Calls "Install-ADDSDomain" with "DnsDelegationCredential", if specified' {
                    Set-TargetResource @setTargetResourceDomainParams `
                        -DnsDelegationCredential $mockDelegationCredential

                    Assert-MockCalled -CommandName Install-ADDSDomain `
                        -ParameterFilter { $DnsDelegationCredential -eq $mockDelegationCredential }
                }

                It 'Calls "Install-ADDSDomain" with "CreateDnsDelegation", if specified' {
                    Set-TargetResource @setTargetResourceDomainParams `
                        -DnsDelegationCredential $mockDelegationCredential

                    Assert-MockCalled -CommandName Install-ADDSDomain `
                        -ParameterFilter { $CreateDnsDelegation -eq $true }
                }

                It 'Calls "Install-ADDSDomain" with "DatabasePath", if specified' {
                    Set-TargetResource @setTargetResourceDomainParams -DatabasePath $mockPath

                    Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter { $DatabasePath -eq $mockPath }
                }

                It 'Calls "Install-ADDSDomain" with "LogPath", if specified' {
                    Set-TargetResource @setTargetResourceDomainParams -LogPath $mockPath

                    Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter { $LogPath -eq $mockPath }
                }

                It 'Calls "Install-ADDSDomain" with "SysvolPath", if specified' {
                    Set-TargetResource @setTargetResourceDomainParams -SysvolPath $mockPath

                    Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter { $SysvolPath -eq $mockPath }
                }

                It 'Calls "Install-ADDSDomain" with "NewDomainNetbiosName", if specified' {
                    Set-TargetResource @setTargetResourceDomainParams -DomainNetBIOSName $mockDomainNetBIOSNameName

                    Assert-MockCalled -CommandName Install-ADDSDomain `
                        -ParameterFilter { $NewDomainNetbiosName -eq $mockDomainNetBIOSNameName }
                }

                It 'Calls "Install-ADDSDomain" with "DomainMode", if specified' {
                    Set-TargetResource @setTargetResourceDomainParams -DomainMode $mockDomainForestMode

                    Assert-MockCalled -CommandName Install-ADDSDomain `
                        -ParameterFilter { $DomainMode -eq $mockDomainForestMode }
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
