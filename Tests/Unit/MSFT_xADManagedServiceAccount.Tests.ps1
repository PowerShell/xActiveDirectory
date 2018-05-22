[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$Global:DSCModuleName      = 'xActiveDirectory' # Example xNetworking
$Global:DSCResourceName    = 'MSFT_xADManagedServiceAccount' # Example MSFT_xFirewall

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

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $Global:DSCResourceName {
       #region Pester Test Initialization
        $testPresentParams = @{
            ServiceAccountName = 'TestMSA'
            Path = 'OU=Fake,DC=contoso,DC=com'
            Description = 'Test MSA description'
            DisplayName = 'Test MSA display name'
            Ensure = 'Present'
        }

        $testAbsentParams = $testPresentParams.Clone()
        $testAbsentParams['Ensure'] = 'Absent'

        $fakeADMSA = @{
            Name = $testPresentParams.Name;
            Identity = $testPresentParams.Name;
            DistinguishedName = "CN=$($testPresentParams.Name),$($testPresentParams.Path)";
            Description = $testPresentParams.Description
            DisplayName = $testPresentParams.DisplayName
        }

        $testDomainController = 'TESTDC';
        $testCredentials = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            Mock Assert-Module -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } { }

            It 'Calls "Assert-Module" to check AD module is installed' {
                Mock Get-ADServiceAccount { return $fakeADMSA }

                $null = Get-TargetResource @testPresentParams

                Assert-MockCalled Assert-Module -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } -Scope It;
            }

            It "Returns 'Ensure' is 'Present' when group exists" {
                Mock Get-ADServiceAccount { return $fakeADMSA; }

                (Get-TargetResource @testPresentParams).Ensure | Should Be 'Present';
            }

            It "Returns 'Ensure' is 'Absent' when group does not exist" {
                Mock Get-ADServiceAccount { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }

                (Get-TargetResource @testPresentParams).Ensure | Should Be 'Absent';
            }

            It "Calls 'Get-ADServiceAccount' with 'Server' parameter when 'DomainController' specified" {
                Mock Get-ADServiceAccount -ParameterFilter { $Server -eq $testDomainController } -MockWith { return $fakeADMSA }

                $null = Get-TargetResource @testPresentParams -DomainController $testDomainController

                Assert-MockCalled Get-ADServiceAccount -ParameterFilter { $Server -eq $testDomainController } -Scope It
            }

            It "Calls 'Get-ADServiceAccount' with 'Credential' parameter when specified" {
                Mock Get-ADServiceAccount -ParameterFilter { $Credential -eq $testCredentials } -MockWith { return $fakeADMSA }

                $null = Get-TargetResource @testPresentParams -Credential $testCredentials

                Assert-MockCalled Get-ADServiceAccount -ParameterFilter { $Credential -eq $testCredentials } -Scope It
            }
        }
        #end region

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Mock Assert-Module -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } { }

            It "Fails when MSA does not exist and 'Ensure' is 'Present'" {
                Mock Get-TargetResource { return $testAbsentParams }

                Test-TargetResource @testPresentParams | Should Be $false
            }

            It "Fails when MSA exists, 'Ensure' is 'Present' but 'Path' is wrong" {
                Mock Get-TargetResource {
                    $duffADMSA = $testPresentParams.Clone();
                    $duffADMSA['Path'] = 'OU=WrongPath,DC=contoso,DC=com';
                    return $duffADMSA;
                }

                Test-TargetResource @testPresentParams | Should Be $false;
            }

            It "Fails when MSA exists, 'Ensure' is 'Present' but 'Description' is wrong" {
                Mock Get-TargetResource {
                    $duffADMSA = $testPresentParams.Clone();
                    $duffADMSA['Description'] = 'Test AD MSA description is wrong';
                    return $duffADMSA;
                }

                Test-TargetResource @testPresentParams | Should Be $false;
            }

            It "Fails when MSA exists, 'Ensure' is 'Present' but 'DisplayName' is wrong" {
                Mock Get-TargetResource {
                    $duffADMSA = $testPresentParams.Clone();
                    $duffADMSA['DisplayName'] = 'Wrong display name';
                    return $duffADMSA;
                }

                Test-TargetResource @testPresentParams | Should Be $false;
            }

            It "Fails when MSA exists and 'Ensure' is 'Absent'" {
                Mock Get-TargetResource { return $testPresentParams }

                Test-TargetResource @testAbsentParams | Should Be $false
            }

            It "Passes when MSA exists, target matches and 'Ensure' is 'Present'" {
                Mock Get-TargetResource { return $testPresentParams }

                Test-TargetResource @testPresentParams | Should Be $true
            }

            It "Passes when MSA does not exist and 'Ensure' is 'Absent'" {
                Mock Get-TargetResource { return $testAbsentParams }

                Test-TargetResource @testAbsentParams | Should Be $true
            }

        }
        #end region

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Mock Assert-Module -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } { }

            It "Calls 'New-ADServiceAccount' when 'Ensure' is 'Present' and the group does not exist" {
                Mock Get-ADServiceAccount { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }
                Mock Set-ADServiceAccount { }
                Mock New-ADServiceAccount { return [PSCustomObject] $fakeADMSA; }

                Set-TargetResource @testPresentParams;

                Assert-MockCalled New-ADServiceAccount -Scope It;
            }

            $testProperties = @{
                Description = 'Test AD MSA description is wrong';
                DisplayName = 'Test DisplayName';
            }

            foreach ($property in $testProperties.Keys) {
                It "Calls 'Set-ADServiceAccount' when 'Ensure' is 'Present' and '$property' is specified" {
                    Mock Set-ADServiceAccount { }
                    Mock Get-ADServiceAccount {
                        $duffADMSA = $fakeADMSA.Clone();
                        $duffADMSA[$property] = $testProperties.$property;
                        return $duffADMSA;
                    }

                    Set-TargetResource @testPresentParams;

                    Assert-MockCalled Set-ADServiceAccount -Scope It -Exactly 1;
                }
            }

            It "Removes MSA when 'Ensure' is 'Absent' and MSA exists" {
                Mock Get-ADServiceAccount { return $fakeADMSA; }
                Mock Remove-ADServiceAccount { }

                Set-TargetResource @testAbsentParams;

                Assert-MockCalled Remove-ADServiceAccount -Scope It;
            }

            It "Calls 'Set-ADServiceAccount' with credentials when 'Ensure' is 'Present' and the MSA exists (#106)" {
                Mock Get-ADServiceAccount { return $fakeADMSA; }
                Mock New-ADServiceAccount { return [PSCustomObject] $fakeADMSA; }
                Mock Set-ADServiceAccount -ParameterFilter { $Credential -eq $testCredentials } -MockWith { }

                Set-TargetResource @testPresentParams -Credential $testCredentials;

                Assert-MockCalled Set-ADServiceAccount -ParameterFilter { $Credential -eq $testCredentials } -Scope It;
            }

            It "Calls 'New-ADServiceAccount' with credentials when 'Ensure' is 'Present' and the MSA does not exist  (#106)" {
                Mock Get-ADServiceAccount { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }
                Mock New-ADServiceAccount -ParameterFilter { $Credential -eq $testCredentials } { return [PSCustomObject] $fakeADMSA; }

                Set-TargetResource @testPresentParams -Credential $testCredentials;

                Assert-MockCalled New-ADServiceAccount -ParameterFilter { $Credential -eq $testCredentials } -Scope It;
            }

            It "Calls 'Move-ADObject' with credentials when specified (#106)" {
                Mock Set-ADServiceAccount { }
                Mock Move-ADObject -ParameterFilter { $Credential -eq $testCredentials } { }
                Mock Get-ADServiceAccount {
                    $duffADMSA = $fakeADMSA.Clone();
                    $duffADMSA['DistinguishedName'] = "CN=$($testPresentParams.ServiceAccountName),OU=WrongPath,DC=contoso,DC=com";
                    return $duffADMSA;
                }

                Set-TargetResource @testPresentParams -Credential $testCredentials;

                Assert-MockCalled Move-ADObject -ParameterFilter { $Credential -eq $testCredentials } -Scope It;
            }
        }
        #end region

    }
    #end region
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}
