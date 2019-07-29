$script:dscModuleName = 'ActiveDirectoryDsc'
$script:dscResourceName = 'MSFT_ADDomain'

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
    # If one type does not exist, it's assumed the other ones does not exist either.
    if (-not ('Microsoft.DirectoryServices.Deployment.Types.ForestMode' -as [Type]))
    {
        Add-Type -Path (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Unit\Stubs\Microsoft.DirectoryServices.Deployment.Types.cs')
    }

    # If one type does not exist, it's assumed the other ones does not exist either.
    if (-not ('Microsoft.ActiveDirectory.Management.ADForestMode' -as [Type]))
    {
        Add-Type -Path (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Unit\Stubs\Microsoft.ActiveDirectory.Management.cs')
    }
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
        $correctDomainName = 'present.com'
        $incorrectDomainName = 'incorrect.com'
        $missingDomainName = 'missing.com'
        $forestMode = [Microsoft.DirectoryServices.Deployment.Types.ForestMode]::Win2012R2
        $mgmtForestMode = [Microsoft.ActiveDirectory.Management.ADForestMode]::Windows2012R2Forest
        $domainMode = [Microsoft.DirectoryServices.Deployment.Types.DomainMode]::Win2012R2
        $mgmtDomainMode = [Microsoft.ActiveDirectory.Management.ADDomainMode]::Windows2012R2Domain

        $testAdminCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @(
            'DummyUser',
            (ConvertTo-SecureString -String 'DummyPassword' -AsPlainText -Force)
        )

        $invalidCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @(
            'Invalid',
            (ConvertTo-SecureString -String 'InvalidPassword' -AsPlainText -Force)
        )

        $testDefaultParams = @{
            Credential = $testAdminCredential
            SafeModeAdministratorPassword = $testAdminCredential
        }

        #region Function Get-TargetResource
        Describe 'ADDomain\Get-TargetResource' {
            Mock -CommandName Assert-Module -ParameterFilter { $ModuleName -eq 'ADDSDeployment' }

            It 'Calls "Assert-Module" to check "ADDSDeployment" module is installed' {
                Mock -CommandName Get-ADDomain -MockWith {
                    [PSObject] @{
                        Forest     = $correctDomainName
                        DomainMode = $mgmtDomainMode
                    }
                }

                Mock -CommandName Get-ADForest -MockWith {
                    [PSObject] @{
                        ForestMode = $mgmtForestMode
                    }
                }

                $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName

                Assert-MockCalled -CommandName Assert-Module -ParameterFilter { $ModuleName -eq 'ADDSDeployment' } -Scope It
            }

            It 'Returns "System.Collections.Hashtable" object type' {
                Mock -CommandName Get-ADDomain {
                    [PSObject] @{
                        Forest     = $correctDomainName
                        DomainMode = $mgmtDomainMode
                    }
                }

                Mock -CommandName Get-ADForest -MockWith {
                    [PSObject] @{
                        ForestMode = $mgmtForestMode
                    }
                }

                $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName

                $result -is [System.Collections.Hashtable] | Should -Be $true
            }

            It 'Calls "Get-ADDomain" without credentials if domain member' {
                Mock -CommandName Test-DomainMember -MockWith { $true; }
                Mock -CommandName Get-ADDomain -ParameterFilter { $Credential -eq $null } -MockWith {
                    [PSObject] @{
                        Forest = $correctDomainName
                        DomainMode = $mgmtDomainMode
                    }
                }

                $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName

                Assert-MockCalled -CommandName Get-ADDomain -ParameterFilter { $Credential -eq $null } -Scope It
            }

            It 'Calls "Get-ADForest" without credentials if domain member' {
                Mock -CommandName Test-DomainMember -MockWith { $true; }
                Mock -CommandName Get-ADDomain -ParameterFilter { $Credential -eq $null } -MockWith {
                    [PSObject] @{
                        Forest = $correctDomainName
                        DomainMode = $mgmtDomainMode
                    }
                }

                Mock -CommandName Get-ADForest -ParameterFilter { $Credential -eq $null } -MockWith {
                    [PSObject] @{
                        ForestMode = $mgmtForestMode
                    }
                }

                $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName

                Assert-MockCalled -CommandName Get-ADForest -ParameterFilter { $Credential -eq $null } -Scope It
            }

            It 'Throws "Invalid credentials" when domain is available but authentication fails' {
                Mock -CommandName Get-ADDomain -ParameterFilter { $Identity.ToString() -eq $incorrectDomainName } -MockWith {
                    throw New-Object System.Security.Authentication.AuthenticationException
                }

                # Match operator is case-sensitive!
                { Get-TargetResource @testDefaultParams -DomainName $incorrectDomainName } | Should -Throw ($script:localizedData.InvalidCredentialError -f $incorrectDomainName)
            }

            It 'Throws "Computer is already a domain member" when is already a domain member' {
                Mock -CommandName Get-ADDomain -ParameterFilter { $Identity.ToString() -eq $incorrectDomainName } -MockWith {
                    throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException
                }

                { Get-TargetResource @testDefaultParams -DomainName $incorrectDomainName } | Should -Throw ($script:localizedData.ExistingDomainMemberError -f $incorrectDomainName)
            }

            It 'Does not throw when domain cannot be located' {
                Mock -CommandName Get-ADDomain -ParameterFilter { $Identity.ToString() -eq $missingDomainName } -MockWith {
                    throw New-Object Microsoft.ActiveDirectory.Management.ADServerDownException
                }

                { Get-TargetResource @testDefaultParams -DomainName $missingDomainName } | Should -Not -Throw
            }

            It 'Returns the correct domain mode' {
                Mock -CommandName Get-ADDomain -MockWith {
                    [PSObject] @{
                        Forest     = $correctDomainName
                        DomainMode = $mgmtDomainMode
                    }
                }

                Mock -CommandName Get-ADForest -MockWith {
                    [PSObject] @{
                        ForestMode = $mgmtForestMode
                    }
                }

                (Get-TargetResource @testDefaultParams -DomainName $correctDomainName).DomainMode | Should -Be $domainMode
            }

            It 'Returns the correct forest mode' {
                Mock -CommandName Get-ADDomain -MockWith {
                    [PSObject] @{
                        Forest     = $correctDomainName
                        DomainMode = $mgmtDomainMode
                    }
                }

                Mock -CommandName Get-ADForest -MockWith {
                    [PSObject] @{
                        ForestMode = $mgmtForestMode
                    }
                }

                (Get-TargetResource @testDefaultParams -DomainName $correctDomainName).ForestMode | Should -Be $forestMode
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'ADDomain\Test-TargetResource' {
            $correctDomainName = 'present.com'
            $correctChildDomainName = 'present'
            $correctDomainNetBIOSName = 'PRESENT'
            $incorrectDomainName = 'incorrect.com'
            $parentDomainName = 'parent.com'
            $testAdminCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @(
                'DummyUser',
                (ConvertTo-SecureString -String 'DummyPassword' -AsPlainText -Force)
            )

            $testDefaultParams = @{
                Credential = $testAdminCredential
                SafeModeAdministratorPassword = $testAdminCredential
            }

            $stubDomain = @{
                DomainName = $correctDomainName
                DomainNetBIOSName = $correctDomainNetBIOSName
            }

            # Get-TargetResource returns the domain FQDN for .DomainName
            $stubChildDomain = @{
                DomainName = "$correctChildDomainName.$parentDomainName"
                ParentDomainName = $parentDomainName
                DomainNetBIOSName = $correctDomainNetBIOSName
            }

            It 'Returns "True" when "DomainName" matches' {
                Mock -CommandName Get-TargetResource -MockWith { return $stubDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName

                $result | Should -Be $true
            }

            It 'Returns "False" when "DomainName" does not match' {
                Mock -CommandName Get-TargetResource -MockWith { return $stubDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $incorrectDomainName

                $result | Should -Be $false
            }

            It 'Returns "True" when "DomainNetBIOSName" matches' {
                Mock -CommandName Get-TargetResource -MockWith { return $stubDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -DomainNetBIOSName $correctDomainNetBIOSName

                $result | Should -Be $true
            }

            It 'Returns "False" when "DomainNetBIOSName" does not match' {
                Mock -CommandName Get-TargetResource -MockWith { return $stubDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -DomainNetBIOSName 'INCORRECT'

                $result | Should -Be $false
            }

            It 'Returns "True" when "ParentDomainName" matches' {
                Mock -CommandName Get-TargetResource -MockWith { return $stubChildDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctChildDomainName -ParentDomainName $parentDomainName

                $result | Should -Be $true
            }

            It 'Returns "False" when "ParentDomainName" does not match' {
                Mock -CommandName Get-TargetResource -MockWith { return $stubChildDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctChildDomainName -ParentDomainName 'incorrect.com'

                $result | Should -Be $false
            }

        }
        #endregion

        #region Function Set-TargetResource
        Describe 'ADDomain\Set-TargetResource' {
            function Install-ADDSForest
            {
                param
                (
                     $DomainName,
                     $SafeModeAdministratorPassword,
                     $CreateDnsDelegation,
                     $DatabasePath,
                     $DnsDelegationCredential,
                     $InstallDns,
                     $LogPath,
                     $NoRebootOnCompletion,
                     $SysvolPath,
                     $DomainNetbiosName,
                     $ForestMode,
                     $DomainMode
                 )
            }

            function Install-ADDSDomain
            {
                param
                (
                    $NewDomainName,
                    $ParentDomainName,
                    $SafeModeAdministratorPassword,
                    $CreateDnsDelegation,
                    $Credential,
                    $DatabasePath,
                    $DnsDelegationCredential,
                    $DomainType,
                    $InstallDns,
                    $LogPath,
                    $NewDomainNetbiosName,
                    $NoRebootOnCompletion,
                    $SysvolPath,
                    $DomainMode
                )
            }

            $testDomainName = 'present.com'
            $testParentDomainName = 'parent.com'
            $testDomainNetBIOSNameName = 'PRESENT'
            $testDomainForestMode = 'WinThreshold'

            $testAdminCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @(
                'Admin',
                (ConvertTo-SecureString -String 'DummyPassword' -AsPlainText -Force)
            )

            $testSafemodePassword = (ConvertTo-SecureString -String 'DummyPassword' -AsPlainText -Force)
            $testSafemodeCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @(
                'Safemode',
                $testSafemodePassword
            )

            $testDelegationCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @(
                'Delegation',
                (ConvertTo-SecureString -String 'DummyPassword' -AsPlainText -Force)
            )

            $newForestParams = @{
                DomainName = $testDomainName
                Credential = $testAdminCredential
                SafeModeAdministratorPassword = $testSafemodeCredential
            }

            $newDomainParams = @{
                DomainName = $testDomainName
                ParentDomainName = $testParentDomainName
                Credential = $testAdminCredential
                SafeModeAdministratorPassword = $testSafemodeCredential
            }

            $stubTargetResource = @{
                DomainName = $testDomainName
                ParentDomainName = $testParentDomainName
                DomainNetBIOSName = $testDomainNetBIOSNameName
                ForestName = $testParentDomainName
                ForestMode = $testDomainForestMode
                DomainMode = $testDomainForestMode
            }
            Mock -CommandName Get-TargetResource -MockWith { return $stubTargetResource; }

            It 'Calls "Install-ADDSForest" with "DomainName" when creating forest' {
                Mock -CommandName Install-ADDSForest -ParameterFilter { $DomainName -eq $testDomainName }

                Set-TargetResource @newForestParams

                Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter  { $DomainName -eq $testDomainName } -Scope It
            }

            It 'Calls "Install-ADDSForest" with "SafeModeAdministratorPassword" when creating forest' {
                Mock -CommandName Install-ADDSForest -ParameterFilter { $SafeModeAdministratorPassword -eq $testSafemodePassword }

                Set-TargetResource @newForestParams

                Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter { $SafeModeAdministratorPassword -eq $testSafemodePassword } -Scope It
            }

            It 'Calls "Install-ADDSForest" with "DnsDelegationCredential" when creating forest, if specified' {
                Mock -CommandName Install-ADDSForest -ParameterFilter { $DnsDelegationCredential -eq $testDelegationCredential }

                Set-TargetResource @newForestParams -DnsDelegationCredential $testDelegationCredential

                Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter  { $DnsDelegationCredential -eq $testDelegationCredential } -Scope It
            }

            It 'Calls "Install-ADDSForest" with "CreateDnsDelegation" when creating forest, if specified' {
                Mock -CommandName Install-ADDSForest -ParameterFilter { $CreateDnsDelegation -eq $true }

                Set-TargetResource @newForestParams -DnsDelegationCredential $testDelegationCredential

                Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter  { $CreateDnsDelegation -eq $true } -Scope It
            }

            It 'Calls "Install-ADDSForest" with "DatabasePath" when creating forest, if specified' {
                $testPath = 'TestPath'
                Mock -CommandName Install-ADDSForest -ParameterFilter { $DatabasePath -eq $testPath }

                Set-TargetResource @newForestParams -DatabasePath $testPath

                Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter { $DatabasePath -eq $testPath } -Scope It
            }

            It 'Calls "Install-ADDSForest" with "LogPath" when creating forest, if specified' {
                $testPath = 'TestPath'
                Mock -CommandName Install-ADDSForest -ParameterFilter { $LogPath -eq $testPath }

                Set-TargetResource @newForestParams -LogPath $testPath

                Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter { $LogPath -eq $testPath } -Scope It
            }

            It 'Calls "Install-ADDSForest" with "SysvolPath" when creating forest, if specified' {
                $testPath = 'TestPath'
                Mock -CommandName Install-ADDSForest -ParameterFilter { $SysvolPath -eq $testPath }

                Set-TargetResource @newForestParams -SysvolPath $testPath

                Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter { $SysvolPath -eq $testPath } -Scope It
            }

            It 'Calls "Install-ADDSForest" with "DomainNetbiosName" when creating forest, if specified' {
                Mock -CommandName Install-ADDSForest -ParameterFilter { $DomainNetbiosName -eq $testDomainNetBIOSNameName }

                Set-TargetResource @newForestParams -DomainNetBIOSName $testDomainNetBIOSNameName

                Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter { $DomainNetbiosName -eq $testDomainNetBIOSNameName } -Scope It
            }

            It 'Calls "Install-ADDSForest" with "ForestMode" when creating forest, if specified' {
                Mock -CommandName Install-ADDSForest -ParameterFilter { $ForestMode -eq $testDomainForestMode }

                Set-TargetResource @newForestParams -ForestMode $testDomainForestMode

                Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter { $ForestMode -eq $testDomainForestMode } -Scope It
            }

            It 'Calls "Install-ADDSForest" with "DomainMode" when creating forest, if specified' {
                Mock -CommandName Install-ADDSForest -ParameterFilter { $DomainMode -eq $testDomainForestMode }

                Set-TargetResource @newForestParams -DomainMode $testDomainForestMode

                Assert-MockCalled -CommandName Install-ADDSForest -ParameterFilter { $DomainMode -eq $testDomainForestMode } -Scope It
            }

            # ADDSDomain

            It 'Calls "Install-ADDSDomain" with "NewDomainName" when creating child domain' {
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $NewDomainName -eq $testDomainName }

                Set-TargetResource @newDomainParams

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter  { $NewDomainName -eq $testDomainName } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "ParentDomainName" when creating child domain' {
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $ParentDomainName -eq $testParentDomainName }

                Set-TargetResource @newDomainParams

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter  { $ParentDomainName -eq $testParentDomainName } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "DomainType" when creating child domain' {
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $DomainType -eq 'ChildDomain' }

                Set-TargetResource @newDomainParams

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter  { $DomainType -eq 'ChildDomain' } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "SafeModeAdministratorPassword" when creating child domain' {
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $SafeModeAdministratorPassword -eq $testSafemodePassword }

                Set-TargetResource @newDomainParams

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter { $SafeModeAdministratorPassword -eq $testSafemodePassword } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "Credential" when creating child domain' {
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $Credential -eq $testParentDomainName }

                Set-TargetResource @newDomainParams

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter  { $ParentDomainName -eq $testParentDomainName } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "ParentDomainName" when creating child domain' {
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $ParentDomainName -eq $testParentDomainName }

                Set-TargetResource @newDomainParams

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter  { $ParentDomainName -eq $testParentDomainName } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "DnsDelegationCredential" when creating child domain, if specified' {
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $DnsDelegationCredential -eq $testDelegationCredential }

                Set-TargetResource @newDomainParams -DnsDelegationCredential $testDelegationCredential

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter  { $DnsDelegationCredential -eq $testDelegationCredential } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "CreateDnsDelegation" when creating child domain, if specified' {
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $CreateDnsDelegation -eq $true }

                Set-TargetResource @newDomainParams -DnsDelegationCredential $testDelegationCredential

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter  { $CreateDnsDelegation -eq $true } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "DatabasePath" when creating child domain, if specified' {
                $testPath = 'TestPath'
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $DatabasePath -eq $testPath }

                Set-TargetResource @newDomainParams -DatabasePath $testPath

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter { $DatabasePath -eq $testPath } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "LogPath" when creating child domain, if specified' {
                $testPath = 'TestPath'
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $LogPath -eq $testPath }

                Set-TargetResource @newDomainParams -LogPath $testPath

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter { $LogPath -eq $testPath } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "SysvolPath" when creating child domain, if specified' {
                $testPath = 'TestPath'
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $SysvolPath -eq $testPath }

                Set-TargetResource @newDomainParams -SysvolPath $testPath

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter { $SysvolPath -eq $testPath } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "NewDomainNetbiosName" when creating child domain, if specified' {
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $NewDomainNetbiosName -eq $testDomainNetBIOSNameName }

                Set-TargetResource @newDomainParams -DomainNetBIOSName $testDomainNetBIOSNameName

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter { $NewDomainNetbiosName -eq $testDomainNetBIOSNameName } -Scope It
            }

            It 'Calls "Install-ADDSDomain" with "DomainMode" when creating child domain, if specified' {
                Mock -CommandName Install-ADDSDomain -ParameterFilter { $DomainMode -eq $testDomainForestMode }

                Set-TargetResource @newDomainParams -DomainMode $testDomainForestMode

                Assert-MockCalled -CommandName Install-ADDSDomain -ParameterFilter { $DomainMode -eq $testDomainForestMode } -Scope It
            }
        }
        #endregion

    }
    #endregion
}
finally
{
    Invoke-TestCleanup
}
