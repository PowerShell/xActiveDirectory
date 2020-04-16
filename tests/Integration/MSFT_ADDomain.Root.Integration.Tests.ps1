<#
    .SYNOPSIS
        Pester integration test for the ADDomain Resource of the ActiveDirectoryDsc Module
        This Subtest creates a root domain in a new forest

    .DESCRIPTION
        Verbose/Debug output can be set by running:

        Invoke-pester -Script @{Path='.\MSFT_ADDomain.Root.Integration.Tests.ps1';Parameters=@{Verbose=$true;Debug=$true}}
#>

[CmdletBinding()]
param ()

Set-StrictMode -Version 1.0

$script:dscResourceFriendlyName = 'ADDomain'
$script:dscResourceName = "MSFT_$($script:dscResourceFriendlyName)"
$script:subTestName = 'Root'

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).$($script:subTestName).config.ps1"
. $configFile

Describe "$($script:dscResourceName).$($script:subTestName)_Integration" {
    BeforeAll {
        $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"
    }

    foreach ($testName in $ConfigurationData.AllNodes.Tests.Keys )
    {
        $configurationName = "$($script:dscResourceName)_$($testName)_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        # The variable $ConfigurationData was dot-sourced above.
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            $DscConfigurationStatus = Get-DscConfigurationStatus
            if ($DscConfigurationStatus.RebootRequested)
            {
                Write-Warning 'A Reboot has been requested by the DSC. Please reboot then re-run the test'
                Return
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -ErrorAction Stop
                } | Should -Not -Throw
            }

            $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
            }

            foreach ($property in $ConfigurationData.AllNodes.Tests.$testName.Keys)
            {
                It "Should have set the correct $property property" {
                    $resourceCurrentState.$property | Should -Be $ConfigurationData.AllNodes.Tests.$testName.$property
                }
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration | Should -Be 'True'
            }
        }
    }
}
