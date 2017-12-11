[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$Global:DSCModuleName      = 'xActiveDirectory' # Example xNetworking
$Global:DSCResourceName    = 'MSFT_xADComputer' # Example MSFT_xFirewall

#region HEADER
# Unit Test Template Version: 1.1.0
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
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
#endregion HEADER


# Begin Testing
try
{

    #region Pester Tests

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $Global:DSCResourceName {

        $testPresentParams = @{
            ComputerName = 'TESTCOMPUTER';
            Ensure = 'Present';
        }

        $testAbsentParams = $testPresentParams.Clone();
        $testAbsentParams['Ensure'] = 'Absent';

        $fakeADComputer = @{
            DistinguishedName = "CN=$($testPresentParams.ComputerName),CN=Computers,DC=contoso,DC=com";
            Enabled = $true;
            Name = $testPresentParams.ComputerName;
            SamAccountName = '{0}$' -f $testPresentParams.ComputerName;
            SID = 'S-1-5-21-1409167834-891301383-2860967316-1143';
            ObjectClass = 'computer';
            ObjectGUID = [System.Guid]::NewGuid();
            UserPrincipalName = 'TESTCOMPUTER@contoso.com';
            ServicePrincipalNames = @('spn/a','spn/b');
            Location = 'Test location';
            DnsHostName = '{0}.contoso.com' -f $testPresentParams.ComputerName;
            DisplayName = $testPresentParams.ComputerName;
            Description = 'Test description';
            ManagedBy = 'CN=Manager,CN=Users,DC=contoso,DC=com';
        }

        $testDomainController = 'TESTDC';
        $testCredential = [System.Management.Automation.PSCredential]::Empty;

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            It "Returns a 'System.Collections.Hashtable' object type" {
                Mock Get-ADComputer { return [PSCustomObject] $fakeADComputer; }

                $adUser = Get-TargetResource @testPresentParams;

                $adUser -is [System.Collections.Hashtable] | Should Be $true;
            }

            It "Returns 'Ensure' is 'Present' when user account exists" {
                Mock Get-ADComputer { return [PSCustomObject] $fakeADComputer; }

                $adUser = Get-TargetResource @testPresentParams;

                $adUser.Ensure | Should Be 'Present';
            }

            It "Returns 'Ensure' is 'Absent' when user account does not exist" {
                Mock Get-ADComputer { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }

                $adUser = Get-TargetResource @testPresentParams;

                $adUser.Ensure | Should Be 'Absent';
            }

            It "Calls 'Get-ADComputer' with 'Server' parameter when 'DomainController' specified" {
                Mock Get-ADComputer -ParameterFilter { $Server -eq $testDomainController } -MockWith { return [PSCustomObject] $fakeADComputer; }

                Get-TargetResource @testPresentParams -DomainController $testDomainController;

                Assert-MockCalled Get-ADComputer -ParameterFilter { $Server -eq $testDomainController } -Scope It;
            }

            It "Calls 'Get-ADComputer' with 'Credential' parameter when 'DomainAdministratorCredential' specified" {
                Mock Get-ADComputer -ParameterFilter { $Credential -eq $testCredential } -MockWith { return [PSCustomObject] $fakeADComputer; }

                Get-TargetResource @testPresentParams -DomainAdministratorCredential $testCredential;

                Assert-MockCalled Get-ADComputer -ParameterFilter { $Credential -eq $testCredential } -Scope It;
            }

        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            $testStringProperties = @(
                'Location',
                'DnsHostName',
                'UserPrincipalName',
                'DisplayName',
                'Path',
                'Description',
                'Manager'
            );
            $testArrayProperties = @(
                'ServicePrincipalNames'
            );
            $testBooleanProperties = @(
                'Enabled'
            );

            It "Passes when computer account does not exist and 'Ensure' is 'Absent'" {
                Mock Get-TargetResource { return $testAbsentParams }

                Test-TargetResource @testAbsentParams | Should Be $true;
            }

            It "Passes when computer account exists and 'Ensure' is 'Present'" {
                Mock Get-TargetResource { return $testPresentParams }

                Test-TargetResource @testPresentParams | Should Be $true;
            }

            It "Fails when computer account does not exist and 'Ensure' is 'Present'" {
                Mock Get-TargetResource { return $testAbsentParams }

                Test-TargetResource @testPresentParams | Should Be $false;
            }

            It "Fails when computer account exists, and 'Ensure' is 'Absent'" {
                Mock Get-TargetResource { return $testPresentParams }

                Test-TargetResource @testAbsentParams | Should Be $false;
            }

            foreach ($testParameter in $testStringProperties) {

                It "Passes when computer account '$testParameter' matches AD account property" {
                    $testParameterValue = 'Test Parameter String Value';
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $validADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $validADComputer[$testParameter] = $testParameterValue;
                        return $validADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $true;
                }

                It "Fails when computer account '$testParameter' does not match incorrect AD account property value" {
                    $testParameterValue = 'Test Parameter String Value';
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $invalidADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $invalidADComputer[$testParameter] = $testParameterValue.Substring(0, ([System.Int32] $testParameterValue.Length/2));
                        return $invalidADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $false;
                }

                It "Fails when computer account '$testParameter' does not match empty AD account property value" {
                    $testParameterValue = 'Test Parameter String Value';
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $invalidADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $invalidADComputer[$testParameter] = '';
                        return $invalidADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $false;
                }

                It "Fails when computer account '$testParameter' does not match null AD account property value" {
                    $testParameterValue = 'Test Parameter String Value';
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $invalidADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $invalidADComputer[$testParameter] = $null;
                        return $invalidADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $false;
                }

                It "Passes when empty computer account '$testParameter' matches empty AD account property" {
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $validADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $validADComputer[$testParameter] = '';
                        return $validADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $true;
                }

                It "Passes when empty computer account '$testParameter' matches null AD account property" {
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $validADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $validADComputer[$testParameter] = $null;
                        return $validADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $true;
                }

            } #end foreach test string property

            foreach ($testParameter in $testArrayProperties) {

                It "Passes when computer account '$testParameter' matches empty AD account property" {
                    $testParameterValue = @();
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $validADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $validADComputer[$testParameter] = $testParameterValue;
                        return $validADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $true;
                }

                It "Passes when computer account '$testParameter' matches single AD account property" {
                    $testParameterValue = @('Entry1');
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $validADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $validADComputer[$testParameter] = $testParameterValue;
                        return $validADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $true;
                }

                It "Passes when computer account '$testParameter' matches multiple AD account property" {
                    $testParameterValue = @('Entry1','Entry2');
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $validADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $validADComputer[$testParameter] = $testParameterValue;
                        return $validADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $true;
                }

                It "Fails when computer account '$testParameter' does not match AD account property count" {
                    $testParameterValue = @('Entry1','Entry2');
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $validADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $validADComputer[$testParameter] = @('Entry1');
                        return $validADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $false;
                }

                It "Fails when computer account '$testParameter' does not match AD account property name" {
                    $testParameterValue = @('Entry1');
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $validADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $validADComputer[$testParameter] = @('Entry2');
                        return $validADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $false;
                }

                It "Fails when computer account '$testParameter' does not match empty AD account property" {
                    $testParameterValue = @('Entry1');
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $validADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $validADComputer[$testParameter] = @();
                        return $validADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $false;
                }

                It "Fails when empty computer account '$testParameter' does not match AD account property" {
                    $testParameterValue = @();
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $validADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $validADComputer[$testParameter] = @('ExtraEntry1');
                        return $validADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $false;
                }

            } #end foreach test string property

            foreach ($testParameter in $testBooleanProperties) {

                It "Passes when computer account '$testParameter' matches AD account property" {
                    $testParameterValue = $true;
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $validADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $validADComputer[$testParameter] = $testParameterValue;
                        return $validADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $true;
                }

                It "Fails when computer account '$testParameter' does not match AD account property value" {
                    $testParameterValue = $true;
                    $testValidPresentParams = $testPresentParams.Clone();
                    $testValidPresentParams[$testParameter] = $testParameterValue;
                    $invalidADComputer = $testPresentParams.Clone();
                    Mock Get-TargetResource {
                        $invalidADComputer[$testParameter] = -not $testParameterValue;
                        return $invalidADComputer;
                    }

                    Test-TargetResource @testValidPresentParams | Should Be $false;
                }

            } #end foreach test boolean property

            Context 'When configuration is in desired state' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return $fakeADComputer
                    }
                }

                Context 'When not specifying the parameter Enabled' {
                    It 'Should return the desired state as $true' {
                        $setTargetResourceParameters = $testPresentParams.Clone()

                        $testTargetResourceResult = Test-TargetResource @setTargetResourceParameters
                        $testTargetResourceResult | Should -Be $true
                    }
                }

                Context 'When specifying the parameter Enabled with the value $true' {
                    It 'Should return the desired state as $true' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['Enabled'] = $true

                        $testTargetResourceResult = Test-TargetResource @setTargetResourceParameters
                        $testTargetResourceResult | Should -Be $true
                    }
                }

                Context 'When specifying the parameter CreateDisabled with the value $false' {
                    It 'Should return the desired state as $true' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['CreateDisabled'] = $false

                        $testTargetResourceResult = Test-TargetResource @setTargetResourceParameters
                        $testTargetResourceResult | Should -Be $true
                    }
                }

                Context 'When specifying the parameter CreateDisabled with the value $false and parameter Enabled with value $true' {
                    It 'Should return the desired state as $true' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['Enabled'] = $true
                        $setTargetResourceParameters['CreateDisabled'] = $false

                        $testTargetResourceResult = Test-TargetResource @setTargetResourceParameters
                        $testTargetResourceResult | Should -Be $true
                    }
                }

                Context 'When specifying the parameter CreateDisabled with the value $true' {
                    It 'Should return the desired state as $true' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['CreateDisabled'] = $true

                        $testTargetResourceResult = Test-TargetResource @setTargetResourceParameters
                        $testTargetResourceResult | Should -Be $true
                    }
                }

                Context 'When specifying the parameter CreateDisabled with the value $true and parameter Enabled with value $true' {
                    It 'Should return the desired state as $true' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['Enabled'] = $true
                        $setTargetResourceParameters['CreateDisabled'] = $true

                        $testTargetResourceResult = Test-TargetResource @setTargetResourceParameters
                        $testTargetResourceResult | Should -Be $true
                    }
                }
            }

            Context 'When configuration is not in desired state' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return $fakeADComputer
                    }
                }

                Context 'When specifying the parameter Enabled with the value $false' {
                    It 'Should return the desired state as $false' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['Enabled'] = $false

                        $testTargetResourceResult = Test-TargetResource @setTargetResourceParameters
                        $testTargetResourceResult | Should -Be $false
                    }
                }

                Context 'When specifying the parameter CreateDisabled with the value $false and parameter Enabled with value $false' {
                    It 'Should return the desired state as $false' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['Enabled'] = $false
                        $setTargetResourceParameters['CreateDisabled'] = $false

                        $testTargetResourceResult = Test-TargetResource @setTargetResourceParameters
                        $testTargetResourceResult | Should -Be $false
                    }
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            $testStringProperties = @(
                'Location',
                'DnsHostName',
                'UserPrincipalName',
                'DisplayName',
                'Description'
                # Manager is translated to ManagedBy
            );

            $testArrayProperties = @(
                'ServicePrincipalNames'
            );
            $testBooleanProperties = @(
                'Enabled'
            );

            It "Calls 'New-ADComputer' when 'Ensure' is 'Present' and the account does not exist" {
                $newComputerName = 'NEWCOMPUTER'
                $newAbsentParams = $testAbsentParams.Clone();
                $newAbsentParams['ComputerName'] = $newComputerName;
                $newPresentParams = $testPresentParams.Clone();
                $newPresentParams['ComputerName'] = $newComputerName;
                Mock New-ADComputer -ParameterFilter { $Name -eq $newComputerName } -MockWith { }
                Mock Set-ADComputer { }
                Mock Get-TargetResource -ParameterFilter { $ComputerName -eq $newComputerName } -MockWith { return $newAbsentParams; }

                Set-TargetResource @newPresentParams;

                Assert-MockCalled New-ADComputer -ParameterFilter { $Name -eq $newComputerName } -Scope It;
            }

            It "Calls 'New-ADComputer' when 'Ensure' is 'Present' and the account does not exist, RequestFile is set, DJOIN OK" {
                $newComputerName = 'NEWCOMPUTER'
                $newAbsentParams = $testAbsentParams.Clone();
                $newAbsentParams['ComputerName'] = $newComputerName;
                $newPresentParams = $testPresentParams.Clone();
                $newPresentParams['ComputerName'] = $newComputerName;
                $newPresentParams['RequestFile'] = 'c:\ODJTest.txt';
                Mock New-ADComputer -ParameterFilter { $Name -eq $newComputerName } -MockWith { }
                Mock djoin.exe -MockWith { $LASTEXITCODE = 0; 'OK' }
                Mock Set-ADComputer { }
                Mock Get-TargetResource -ParameterFilter { $ComputerName -eq $newComputerName } -MockWith { return $newAbsentParams; }

                Set-TargetResource @newPresentParams;

                Assert-MockCalled New-ADComputer -ParameterFilter { $Name -eq $newComputerName } -Scope It -Exactly 0;
                Assert-MockCalled djoin.exe -Exactly 1;
            }

            It "Calls 'New-ADComputer' with 'Path' when specified" {
                $newComputerName = 'NEWCOMPUTER'
                $newAbsentParams = $testAbsentParams.Clone();
                $newAbsentParams['ComputerName'] = $newComputerName;
                $newPresentParams = $testPresentParams.Clone();
                $newPresentParams['ComputerName'] = $newComputerName;
                $targetPath = 'OU=Test,DC=contoso,DC=com';
                Mock New-ADComputer -ParameterFilter { $Path -eq $targetPath } -MockWith { }
                Mock Set-ADComputer { }
                Mock Get-TargetResource -ParameterFilter { $ComputerName -eq $newComputerName } -MockWith { return $newAbsentParams; }

                Set-TargetResource @newPresentParams -Path $targetPath;

                Assert-MockCalled New-ADComputer -ParameterFilter { $Path -eq $targetPath } -Scope It;
            }

            It "Calls 'Move-ADObject' when 'Ensure' is 'Present', the computer account exists but Path is incorrect" {
                $testTargetPath = 'OU=NewPath,DC=contoso,DC=com';
                Mock Set-ADComputer { }
                Mock Get-ADComputer {
                    $duffADComputer = $fakeADComputer.Clone();
                    $duffADComputer['DistinguishedName'] = 'CN={0},OU=WrongPath,DC=contoso,DC=com' -f $testPresentParams.ComputerName;
                    return $duffADComputer;
                }
                Mock Move-ADObject -ParameterFilter { $TargetPath -eq $testTargetPath } -MockWith { }

                Set-TargetResource @testPresentParams -Path $testTargetPath;

                Assert-MockCalled Move-ADObject -ParameterFilter { $TargetPath -eq $testTargetPath } -Scope It;
            }

            foreach ($testParameter in $testStringProperties) {

                It "Calls 'Set-ADComputer' with 'Remove' when '$testParameter' is `$null" {
                    Mock Get-ADComputer { return $fakeADComputer; }
                    Mock Set-ADComputer -ParameterFilter { $Remove.ContainsKey($testParameter) } { }

                    $setTargetResourceParams = $testPresentParams.Clone();
                    $setTargetResourceParams[$testParameter] = '';
                    Set-TargetResource @setTargetResourceParams;

                    Assert-MockCalled Set-ADComputer -ParameterFilter { $Remove.ContainsKey($testParameter) } -Scope It -Exactly 1;
                }

                It "Calls 'Set-ADComputer' with 'Replace' when existing '$testParameter' is not `$null" {
                    Mock Get-ADComputer { return $fakeADComputer; }
                    Mock Set-ADComputer -ParameterFilter { $Replace.ContainsKey($testParameter) } { }

                    $setTargetResourceParams = $testPresentParams.Clone();
                    $setTargetResourceParams[$testParameter] = 'NewStringValue';
                    Set-TargetResource @setTargetResourceParams;

                    Assert-MockCalled Set-ADComputer -ParameterFilter { $Replace.ContainsKey($testParameter) } -Scope It -Exactly 1;
                }

            } #end foreach string parameter

            It "Calls 'Set-ADComputer' with 'Remove' when 'Manager' is `$null" {
                ## Manager translates to AD attribute 'managedBy'
                Mock Get-ADComputer { return $fakeADComputer; }
                Mock Set-ADComputer -ParameterFilter { $Remove.ContainsKey('ManagedBy') } { }

                $setTargetResourceParams = $testPresentParams.Clone();
                $setTargetResourceParams['Manager'] = '';
                Set-TargetResource @setTargetResourceParams;

                Assert-MockCalled Set-ADComputer -ParameterFilter { $Remove.ContainsKey('ManagedBy') } -Scope It -Exactly 1;
            }

            It "Calls 'Set-ADComputer' with 'Replace' when existing 'Manager' is not `$null" {
                ## Manager translates to AD attribute 'managedBy'
                Mock Get-ADComputer { return $fakeADComputer; }
                Mock Set-ADComputer -ParameterFilter { $Replace.ContainsKey('ManagedBy') } { }

                $setTargetResourceParams = $testPresentParams.Clone();
                $setTargetResourceParams['Manager'] = 'NewValue';
                Set-TargetResource @setTargetResourceParams;

                Assert-MockCalled Set-ADComputer -ParameterFilter { $Replace.ContainsKey('ManagedBy') } -Scope It -Exactly 1;
            }

            It "Calls 'Set-ADComputer' with 'ServicePrincipalNames' when specified" {
                $testSPNs = @('spn/a','spn/b');
                Mock Get-ADComputer { return $fakeADComputer; }
                Mock Set-ADComputer -ParameterFilter { $Replace.ContainsKey('ServicePrincipalName') } { }

                Set-TargetResource @testPresentParams -ServicePrincipalNames $testSPNs;

                Assert-MockCalled Set-ADComputer -ParameterFilter { $Replace.ContainsKey('ServicePrincipalName') } -Scope It -Exactly 1;
            }

            It "Calls 'Remove-ADComputer' when 'Ensure' is 'Absent' and computer account exists" {
                Mock Get-ADComputer { return $fakeADComputer; }
                Mock Remove-ADComputer -ParameterFilter { $Identity.ToString() -eq $testAbsentParams.ComputerName } -MockWith { }

                Set-TargetResource @testAbsentParams;

                Assert-MockCalled Remove-ADComputer -ParameterFilter { $Identity.ToString() -eq $testAbsentParams.ComputerName } -Scope It;
            }

            Context 'When a computer account that should be disabled' {
                BeforeAll {
                    Mock -CommandName Set-ADComputer
                    Mock -CommandName Set-DscADComputer
                    Mock -CommandName New-ADComputer

                    Mock -CommandName Get-TargetResource -MockWith {
                        return $fakeADComputer
                    }
                }

                Context 'When specifying the parameter Enabled with the value $false' {
                    It 'Should call Set-ADComputer to disable the computer account' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['Enabled'] = $false

                        Set-TargetResource @setTargetResourceParameters

                        Assert-MockCalled -CommandName New-ADComputer -Scope It -Exactly -Times 0
                        Assert-MockCalled -CommandName Set-DscADComputer -ParameterFilter {
                            $SetADComputerParameters.Enabled -eq $false
                        } -Scope It -Exactly -Times 1
                    }
                }
            }

            Context 'When a computer account that should be enabled' {
                BeforeAll {
                    Mock -CommandName Set-ADComputer
                    Mock -CommandName Set-DscADComputer
                    Mock -CommandName New-ADComputer

                    Mock -CommandName Get-TargetResource -MockWith {
                        $disabledFakeADComputer = $fakeADComputer.Clone()
                        $disabledFakeADComputer['Enabled'] = $false
                        return $disabledFakeADComputer
                    }
                }

                Context 'When specifying the parameter Enabled with the value $true' {
                    It 'Should call Set-ADComputer to enable the computer account' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['Enabled'] = $true

                        Set-TargetResource @setTargetResourceParameters

                        Assert-MockCalled -CommandName New-ADComputer -Scope It -Exactly -Times 0
                        Assert-MockCalled -CommandName Set-DscADComputer -ParameterFilter {
                            $SetADComputerParameters.Enabled -eq $true
                        } -Scope It -Exactly -Times 1
                    }
                }
            }

            Context 'When creating a computer account that should be enabled' {
                BeforeAll {
                    Mock -CommandName Set-ADComputer
                    Mock -CommandName New-ADComputer

                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            Ensure = 'Absent'
                        }
                    }
                }

                Context 'When not specifying the parameter Enabled' {
                    It 'Should create a computer account that is enabled' {
                        $setTargetResourceParameters = $testPresentParams.Clone()

                        Set-TargetResource @setTargetResourceParameters

                        Assert-MockCalled -CommandName New-ADComputer -ParameterFilter {
                            $Enabled -eq $true
                        } -Scope It -Exactly -Times 1

                        Assert-MockCalled -CommandName Set-ADComputer -ParameterFilter {
                            $Enabled -eq $true -or $Enabled -eq $false
                        } -Scope It -Exactly -Times 0
                    }
                }

                Context 'When specifying the parameter Enabled with the value $true' {
                    It 'Should create a computer account that is enabled' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['Enabled'] = $true

                        Set-TargetResource @setTargetResourceParameters

                        Assert-MockCalled -CommandName New-ADComputer -ParameterFilter {
                            $Enabled -eq $true
                        } -Scope It -Exactly -Times 1

                        Assert-MockCalled -CommandName Set-ADComputer -ParameterFilter {
                            $Enabled -eq $true -or $Enabled -eq $false
                        } -Scope It -Exactly -Times 0
                    }
                }

                Context 'When specifying the parameter CreateDisabled with the value $false and parameter Enabled with value $true' {
                    It 'Should create a computer account that is enabled' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['CreateDisabled'] = $false
                        $setTargetResourceParameters['Enabled'] = $true

                        Set-TargetResource @setTargetResourceParameters

                        Assert-MockCalled -CommandName New-ADComputer -ParameterFilter {
                            $Enabled -eq $true
                        } -Scope It -Exactly -Times 1

                        Assert-MockCalled -CommandName Set-ADComputer -ParameterFilter {
                            $Enabled -eq $true -or $Enabled -eq $false
                        } -Scope It -Exactly -Times 0
                    }
                }

                Context 'When specifying the parameter CreateDisabled with the value $true and parameter Enabled with value $true' {
                    It 'Should create a computer account that are enabled' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['CreateDisabled'] = $true
                        $setTargetResourceParameters['Enabled'] = $true

                        Set-TargetResource @setTargetResourceParameters

                        Assert-MockCalled -CommandName New-ADComputer -ParameterFilter {
                            $Enabled -eq $true
                        } -Scope It -Exactly -Times 1

                        Assert-MockCalled -CommandName Set-ADComputer -ParameterFilter {
                            $Enabled -eq $true -or $Enabled -eq $false
                        } -Scope It -Exactly -Times 0
                    }
                }
            }

            Context 'When creating a computer account that should be disabled' {
                BeforeAll {
                    Mock -CommandName Set-ADComputer
                    Mock -CommandName New-ADComputer

                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            Ensure = 'Absent'

                            # This is needed for the second call to Get-TargetResource.
                            # Enabled = $true
                        }
                    }
                }

                Context 'When specifying the parameter Enabled with the value $false' {
                    It 'Should create a computer account that is disabled' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['Enabled'] = $false

                        Set-TargetResource @setTargetResourceParameters

                        Assert-MockCalled -CommandName New-ADComputer -ParameterFilter {
                            $Enabled -eq $false
                        } -Scope It -Exactly -Times 1

                        Assert-MockCalled -CommandName Set-ADComputer -ParameterFilter {
                            $Enabled -eq $true -or $Enabled -eq $false
                        } -Scope It -Exactly -Times 0
                    }
                }

                Context 'When specifying the parameter CreateDisabled with the value $true' {
                    It 'Should create a computer account that is disabled' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['CreateDisabled'] = $true

                        Set-TargetResource @setTargetResourceParameters

                        Assert-MockCalled -CommandName New-ADComputer -ParameterFilter {
                            $Enabled -eq $false
                        } -Scope It -Exactly -Times 1

                        Assert-MockCalled -CommandName Set-ADComputer -ParameterFilter {
                            $Enabled -eq $true -or $Enabled -eq $false
                        } -Scope It -Exactly -Times 0
                    }
                }

                Context 'When specifying the parameter CreateDisabled with the value $false and Enabled with value $false' {
                    It 'Should create a computer account that is disabled' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['CreateDisabled'] = $false
                        $setTargetResourceParameters['Enabled'] = $false

                        Set-TargetResource @setTargetResourceParameters

                        Assert-MockCalled -CommandName New-ADComputer -ParameterFilter {
                            $Enabled -eq $false
                        } -Scope It -Exactly -Times 1

                        Assert-MockCalled -CommandName Set-ADComputer -ParameterFilter {
                            $Enabled -eq $true -or $Enabled -eq $false
                        } -Scope It -Exactly -Times 0
                    }
                }

                Context 'When specifying the parameter CreateDisabled with the value $true and Enabled with value $false' {
                    It 'Should create a computer account that is disabled' {
                        $setTargetResourceParameters = $testPresentParams.Clone()
                        $setTargetResourceParameters['CreateDisabled'] = $true
                        $setTargetResourceParameters['Enabled'] = $false

                        Set-TargetResource @setTargetResourceParameters

                        Assert-MockCalled -CommandName New-ADComputer -ParameterFilter {
                            $Enabled -eq $false
                        } -Scope It -Exactly -Times 1

                        Assert-MockCalled -CommandName Set-ADComputer -ParameterFilter {
                            $Enabled -eq $true -or $Enabled -eq $false
                        } -Scope It -Exactly -Times 0
                    }
                }
            }

        }
        #endregion
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
