[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$script:dscModuleName = 'xActiveDirectory'
$script:dscResourceName = 'MSFT_xWaitForADDomain'

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
        $domainUserCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @(
            'Username',
            $(ConvertTo-SecureString -String 'Password' -AsPlainText -Force)
        )

        $domainName = 'example.com'
        $testParams = @{
            DomainName = $domainName
            DomainUserCredential = $domainUserCredential
            RetryIntervalSec = 10
            RetryCount = 5
        }

        $rebootTestParams = @{
            DomainName = $domainName
            DomainUserCredential = $domainUserCredential
            RetryIntervalSec = 10
            RetryCount = 5
            RebootRetryCount = 3
        }

        $fakeDomainObject = @{Name = $domainName}

        #region Function Get-TargetResource
        Describe 'xWaitForADDomain\Get-TargetResource' {
            It 'Returns a "System.Collections.Hashtable" object type' {
                Mock -CommandName Get-Domain -MockWith {return $fakeDomainObject}
                $targetResource = Get-TargetResource @testParams
                $targetResource -is [System.Collections.Hashtable] | Should -Be $true
            }

            It "Returns DomainName = $($testParams.DomainName) when domain is found" {
                Mock -CommandName Get-Domain -MockWith {return $fakeDomainObject}
                $targetResource = Get-TargetResource @testParams
                $targetResource.DomainName | Should -Be $testParams.DomainName
            }

            It "Returns an empty DomainName when domain is not found" {
                Mock -CommandName Get-Domain
                $targetResource = Get-TargetResource @testParams
                $targetResource.DomainName | Should -Be $null
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe 'xWaitForADDomain\Test-TargetResource' {
            It 'Returns a "System.Boolean" object type' {
                Mock -CommandName Get-Domain -MockWith {return $fakeDomainObject}
                $targetResource =  Test-TargetResource @testParams
                $targetResource -is [System.Boolean] | Should -Be $true
            }

            It 'Passes when domain found' {
                Mock -CommandName Get-Domain -MockWith {return $fakeDomainObject}
                Test-TargetResource @testParams | Should -Be $true
            }

            It 'Fails when domain not found' {
                Mock -CommandName Get-Domain
                Test-TargetResource @testParams | Should -Be $false
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe 'xWaitForADDomain\Set-TargetResource' {
            BeforeEach{
                $global:DSCMachineStatus = $null
            }

            It "Doesn't throw exception and doesn't call Start-Sleep, Clear-DnsClientCache or set `$global:DSCMachineStatus when domain found" {
                Mock -CommandName Get-Domain -MockWith {return $fakeDomainObject}
                Mock -CommandName Start-Sleep
                Mock -CommandName Clear-DnsClientCache
                {Set-TargetResource @testParams} | Should -Not -Throw
                $global:DSCMachineStatus | Should -Not -Be 1
                Assert-MockCalled -CommandName Start-Sleep -Times 0 -Scope It
                Assert-MockCalled -CommandName Clear-DnsClientCache -Times 0 -Scope It
            }

            It "Throws exception and does not set `$global:DSCMachineStatus when domain not found after $($testParams.RetryCount) retries when RebootRetryCount is not set" {
                Mock -CommandName Get-Domain
                {Set-TargetResource @testParams} | Should -Throw
                $global:DSCMachineStatus | Should -Not -Be 1
            }

            It "Throws exception when domain not found after $($rebootTestParams.RebootRetryCount) reboot retries when RebootRetryCount is exceeded" {
                Mock -CommandName Get-Domain
                Mock -CommandName Get-Content -MockWith {return $rebootTestParams.RebootRetryCount}
                {Set-TargetResource @rebootTestParams} | Should -Throw
            }

            It "Calls Set-Content if reboot count is less than RebootRetryCount when domain not found" {
                Mock -CommandName Get-Domain
                Mock -CommandName Get-Content -MockWith {return 0}
                Mock -CommandName Set-Content
                {Set-TargetResource @rebootTestParams} | Should -Not -Throw
                Assert-MockCalled -CommandName Set-Content -Times 1 -Exactly -Scope It
            }

            It "Sets `$global:DSCMachineStatus = 1 and does not throw an exception if the domain is not found and RebootRetryCount is not exceeded" {
                Mock -CommandName Get-Domain
                Mock -CommandName Get-Content -MockWith {return 0}
                {Set-TargetResource @rebootTestParams} | Should -Not -Throw
                $global:DSCMachineStatus | Should -Be 1
            }

            It "Calls Get-Domain exactly $($testParams.RetryCount) times when domain not found" {
                Mock -CommandName Get-Domain
                Mock -CommandName Start-Sleep
                Mock -CommandName Clear-DnsClientCache
                {Set-TargetResource @testParams} | Should -Throw
                Assert-MockCalled -CommandName Get-Domain -Times $testParams.RetryCount -Exactly -Scope It
            }

            It "Calls Start-Sleep exactly $($testParams.RetryCount) times when domain not found" {
                Mock -CommandName Get-Domain
                Mock -CommandName Start-Sleep
                Mock -CommandName Clear-DnsClientCache
                {Set-TargetResource @testParams} | Should -Throw
                Assert-MockCalled -CommandName Start-Sleep -Times $testParams.RetryCount -Exactly -Scope It
            }

            It "Calls Clear-DnsClientCache exactly $($testParams.RetryCount) times when domain not found" {
                Mock -CommandName Get-Domain
                Mock -CommandName Start-Sleep
                Mock -CommandName Clear-DnsClientCache
                {Set-TargetResource @testParams} | Should -Throw
                Assert-MockCalled -CommandName Clear-DnsClientCache -Times $testParams.RetryCount -Exactly -Scope It
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
