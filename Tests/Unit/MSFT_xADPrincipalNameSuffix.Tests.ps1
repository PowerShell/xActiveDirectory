$Global:DSCModuleName   = 'xActiveDirectory' 
$Global:DSCResourceName = 'MSFT_xADPrincipalNameSuffix'

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit

try
{
    InModuleScope $Global:DSCResourceName {

        $forestName = 'contoso.com'
        $testCredential = [System.Management.Automation.PSCredential]::Empty;

        $testpresentParams = @{
            ForestName = $forestName
            UserPrincipalNameSuffix = 'cloudapp.net','fabrikam.com'
            ServicePrincipalNameSuffix = 'test.net'
            Ensure = 'Present'
        }

        $testAbsentParams = $testPresentParams.Clone();
        $testAbsentParams['Ensure'] = 'Absent';

    
        $presentForestMatch = @{
            Name = $forestName
            UPNSuffixes = @('cloudapp.net','fabrikam.com')
            SPNSuffixes = @('test.net')
        }

        $absentForestMatch = @{
            Name = $forestName
            UPNSuffixes = @('test1.value','test2.value')
            SPNSuffixes = @('test3.value')
        }

        Mock Assert-Module -MockWith { }
        Mock Import-Module -MockWith { }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            Mock Get-ADForest -MockWith { return [pscustomobject] $presentForestMatch }
            
            $targetResource = Get-TargetResource @testpresentParams

            It 'Should Return a "System.Collections.Hashtable" object type' {
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
            }

            It 'Should return ServicePrincipalNameSuffix'{
                $targetResource.ServicePrincipalNameSuffix | Should be $presentForestMatch.SPNSuffixes
            }
       
            It 'Should return UserPrincipalNameSuffix'{
                $targetResource.UserPrincipalNameSuffix | Should be $presentForestMatch.UPNSuffixes
            }
       
            It 'Should return Forest name'{
                $targetResource.ForestName | Should be $presentForestMatch.Name
            }
        }
        
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            It 'Should return $false if [Present] Suffix does NOT match'{
                Mock Get-ADForest -MockWith { return [pscustomobject] $absentForestMatch }

                Test-TargetResource @testpresentParams | Should be $false
            }

            It 'Should return $true if [Present] Suffix does matche'{
                Mock Get-ADForest -MockWith { return [pscustomobject] $presentForestMatch }

                Test-TargetResource @testpresentParams | Should be $true
            }

            It 'Should return $false if [Absent] Suffix does NOT match'{
                Mock Get-ADForest -MockWith { return [pscustomobject] $presentForestMatch }

                Test-TargetResource @testabsentParams | Should be $false
            }

            It 'Should return $true if [Absent] Suffix does match'{
                Mock Get-ADForest -MockWith { return [pscustomobject] $absentForestMatch }

                Test-TargetResource @testabsentParams | Should be $true
            }
        }
        
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            It 'Should call Set-AdForest with Credential parameter when Credential parameter is specified'{
                Mock Set-ADForest -ParameterFilter { $Credential -eq $testCredential } -MockWith { }

                Set-TargetResource @testPresentParams -Credential $testCredential

                Assert-MockCalled Set-ADForest -ParameterFilter { $Credential -eq $testCredential } -Scope It             
            }

            It 'Should call Set-ADForest with Replace action when ensure set to present'{
                Mock Set-ADForest -ParameterFilter {$SPNSuffixes.replace -eq  $testPresentParams.ServicePrincipalNameSuffix } -MockWith { }

                Set-TargetResource @testPresentParams 

                Assert-MockCalled Set-ADForest -ParameterFilter { $SPNSuffixes.replace -eq  $testPresentParams.ServicePrincipalNameSuffix } -Scope It
            }

            It 'Should call Set-ADForest with Remove action when ensure set to absent'{
                Mock Set-ADForest -ParameterFilter {$SPNSuffixes.remove -eq  $testAbsentParams.ServicePrincipalNameSuffix } -MockWith { }

                Set-TargetResource @testAbsentParams 

                Assert-MockCalled Set-ADForest -ParameterFilter { $SPNSuffixes.remove -eq  $testAbsentParams.ServicePrincipalNameSuffix } -Scope It
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
