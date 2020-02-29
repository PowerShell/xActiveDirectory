<#
    .SYNOPSIS
        Pester integration test for the ADUser Resource of the ActiveDirectoryDsc Module

    .DESCRIPTION
        Verbose/Debug output can be set by running:

        Invoke-pester -Script @{Path='.\MSFT_ADUser.Integration.Tests.ps1';Parameters=@{Verbose=$true;Debug=$true}}
#>

[CmdletBinding()]
param ()

Set-StrictMode -Version 1.0

$script:dscModuleName = 'ActiveDirectoryDsc'
$script:dscResourceFriendlyName = 'ADUser'
$script:dscResourceName = "MSFT_$($script:dscResourceFriendlyName)"

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop' -Verbose:$false
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

try
{
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configFile

    Describe "$($script:dscResourceName)_Integration" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"
        }
        foreach ($testName in $ConfigurationData.AllNodes.Tests.Keys)
        {
            $configurationName = "$($script:dscResourceName)_$($testName)_Config"

            Context ('When using configuration {0}' -f $configurationName) {
                BeforeAll {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        # The variable $ConfigurationData was dot-sourced above.
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters -Debug:$false

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }
                }

                It 'Should compile and apply the MOF without throwing' {
                    { Start-DscConfiguration @startDscConfigurationParameters } |
                        Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { $script:currentConfiguration = Get-DscConfiguration -ErrorAction Stop } |
                        Should -Not -Throw
                }

                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                foreach ($property in $ConfigurationData.AllNodes.Tests.$testName.Keys)
                {
                    It "Should have set the correct '$property' property" {
                        $resourceCurrentState.$property | Sort-Object |
                            Should -Be ($ConfigurationData.AllNodes.Tests.$testName.$property | Sort-Object)
                    }
                }

                It 'Should return $true when Test-DscConfiguration is run' {
                    Test-DscConfiguration | Should -Be 'True'
                }
            }
        }
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
    #endregion
}
