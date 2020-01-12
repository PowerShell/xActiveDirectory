$script:dscModuleName = 'ActiveDirectoryDsc'
$script:dscResourceFriendlyName = 'ADManagedServiceAccount'
$script:dscResourceName = "MSFT_$($script:dscResourceFriendlyName)"

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
    -TestType 'Integration'

try
{
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configFile

    Describe "$($script:dscResourceName)_Integration" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"

            $DefaultManagedServiceAccountPath = "CN=Managed Service Accounts,$($ConfigurationData.AllNodes.DomainDistinguishedName)"

            $DefaultKerberosEncryptionType = 'RC4', 'AES128', 'AES256'

            $configurationParameters = @{
                OutputPath        = $TestDrive
                # The variable $ConfigurationData was dot-sourced above.
                ConfigurationData = $ConfigurationData
            }

            $startDscConfigurationParameters = @{
                Path         = $TestDrive
                ComputerName = 'localhost'
                Wait         = $true
                Verbose      = $true
                Force        = $true
                ErrorAction  = 'Stop'
            }
        }

        $configurationName = "$($script:dscResourceName)_Initialise_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    & $configurationName @configurationParameters
                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }
        }

        $configurationName = "$($script:dscResourceName)_CreateServiceAccount1_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    & $configurationName @configurationParameters
                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.ServiceAccountName | Should -Be $ConfigurationData.ManagedServiceAccount1.Name
                $resourceCurrentState.AccountType | Should -Be $ConfigurationData.ManagedServiceAccount1.AccountType
                $resourceCurrentState.Path | Should -Be $DefaultManagedServiceAccountPath
                $resourceCurrentState.Description | Should -BeNullOrEmpty
                $resourceCurrentState.DisplayName | Should -BeNullOrEmpty
                $resourceCurrentState.Enabled | Should -Be $true
                $resourceCurrentState.ManagedPasswordPrincipals | Should -BeNullOrEmpty
                $resourceCurrentState.MembershipAttribute | Should -Be 'SamAccountName'
                $resourceCurrentState.KerberosEncryptionType | Should -Be $DefaultKerberosEncryptionType
                $resourceCurrentState.DistinguishedName | Should -Be ('CN={0},CN=Managed Service Accounts,{1}' -f `
                        $ConfigurationData.ManagedServiceAccount1.Name, $ConfigurationData.AllNodes.DomainDistinguishedName)
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_CreateServiceAccount2_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    & $configurationName @configurationParameters
                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.ServiceAccountName | Should -Be $ConfigurationData.ManagedServiceAccount2.Name
                $resourceCurrentState.AccountType | Should -Be $ConfigurationData.ManagedServiceAccount2.AccountType
                $resourceCurrentState.Path | Should -Be $DefaultManagedServiceAccountPath
                $resourceCurrentState.Description | Should -BeNullOrEmpty
                $resourceCurrentState.DisplayName | Should -BeNullOrEmpty
                $resourceCurrentState.Enabled | Should -Be $true
                $resourceCurrentState.ManagedPasswordPrincipals | Should -BeNullOrEmpty
                $resourceCurrentState.MembershipAttribute | Should -Be 'SamAccountName'
                $resourceCurrentState.KerberosEncryptionType | Should -Be $DefaultKerberosEncryptionType
                $resourceCurrentState.DistinguishedName | Should -Be ('CN={0},{1}' -f `
                        $ConfigurationData.ManagedServiceAccount2.Name, $DefaultManagedServiceAccountPath)
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_CreateServiceAccount3_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    & $configurationName @configurationParameters
                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.ServiceAccountName | Should -Be $ConfigurationData.ManagedServiceAccount3.Name
                $resourceCurrentState.AccountType | Should -Be $ConfigurationData.ManagedServiceAccount3.AccountType
                $resourceCurrentState.Path | Should -Be $DefaultManagedServiceAccountPath
                $resourceCurrentState.Description | Should -BeNullOrEmpty
                $resourceCurrentState.DisplayName | Should -BeNullOrEmpty
                $resourceCurrentState.Enabled | Should -Be $true
                $resourceCurrentState.ManagedPasswordPrincipals | Should -BeNullOrEmpty
                $resourceCurrentState.MembershipAttribute | Should -Be 'SamAccountName'
                $resourceCurrentState.KerberosEncryptionType | Should -Be $DefaultKerberosEncryptionType
                $resourceCurrentState.DistinguishedName | Should -Be ('CN={0},{1}' -f $ConfigurationData.ManagedServiceAccount3.Name, `
                        $DefaultManagedServiceAccountPath)
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_RemoveServiceAccount1_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    & $configurationName @configurationParameters
                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.Ensure | Should -Be 'Absent'
                $resourceCurrentState.ServiceAccountName | Should -Be $ConfigurationData.ManagedServiceAccount1.Name
                $resourceCurrentState.AccountType | Should -Be $ConfigurationData.ManagedServiceAccount1.AccountType
                $resourceCurrentState.Path | Should -BeNullOrEmpty
                $resourceCurrentState.Description | Should -BeNullOrEmpty
                $resourceCurrentState.DisplayName | Should -BeNullOrEmpty
                $resourceCurrentState.Enabled | Should -BeFalse
                $resourceCurrentState.ManagedPasswordPrincipals | Should -BeNullOrEmpty
                $resourceCurrentState.MembershipAttribute | Should -Be 'SamAccountName'
                $resourceCurrentState.KerberosEncryptionType | Should -BeNullOrEmpty
                $resourceCurrentState.DistinguishedName | Should -BeNullOrEmpty
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_UpdateServiceAccount2_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    & $configurationName @configurationParameters
                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.ServiceAccountName | Should -Be $ConfigurationData.ManagedServiceAccount2.Name
                $resourceCurrentState.AccountType | Should -Be $ConfigurationData.ManagedServiceAccount2.AccountType
                $resourceCurrentState.Path | Should -Be $ConfigurationData.ManagedServiceAccount2.Path
                $resourceCurrentState.Description | Should -Be $ConfigurationData.ManagedServiceAccount2.Description
                $resourceCurrentState.DisplayName | Should -Be $ConfigurationData.ManagedServiceAccount2.DisplayName
                $resourceCurrentState.Enabled | Should -Be $true
                $resourceCurrentState.ManagedPasswordPrincipals | Should -BeNullOrEmpty
                $resourceCurrentState.MembershipAttribute | Should -Be 'SamAccountName'
                $resourceCurrentState.KerberosEncryptionType | Should -Be $ConfigurationData.ManagedServiceAccount2.KerberosEncryptionType
                $resourceCurrentState.DistinguishedName | Should -Be ('CN={0},{1}' -f `
                        $ConfigurationData.ManagedServiceAccount2.Name, $ConfigurationData.ManagedServiceAccount2.Path)
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_EnforcePasswordPrincipalsServiceAccount3_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    & $configurationName @configurationParameters
                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.ServiceAccountName | Should -Be $ConfigurationData.ManagedServiceAccount3.Name
                $resourceCurrentState.AccountType | Should -Be $ConfigurationData.ManagedServiceAccount3.AccountType
                $resourceCurrentState.Path | Should -Be $DefaultManagedServiceAccountPath
                $resourceCurrentState.Description | Should -BeNullOrEmpty
                $resourceCurrentState.DisplayName | Should -BeNullOrEmpty
                $resourceCurrentState.Enabled | Should -Be $true
                $resourceCurrentState.ManagedPasswordPrincipals | Should -Be $ConfigurationData.ManagedServiceAccount3.ManagedPasswordPrincipals
                $resourceCurrentState.MembershipAttribute | Should -Be 'SamAccountName'
                $resourceCurrentState.KerberosEncryptionType | Should -Be $DefaultKerberosEncryptionType
                $resourceCurrentState.DistinguishedName | Should -Be ('CN={0},{1}' -f `
                        $ConfigurationData.ManagedServiceAccount3.Name, $DefaultManagedServiceAccountPath)
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_ClearPasswordPrincipalsServiceAccount3_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    & $configurationName @configurationParameters
                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.ServiceAccountName | Should -Be $ConfigurationData.ManagedServiceAccount3.Name
                $resourceCurrentState.AccountType | Should -Be $ConfigurationData.ManagedServiceAccount3.AccountType
                $resourceCurrentState.Path | Should -Be $DefaultManagedServiceAccountPath
                $resourceCurrentState.Description | Should -BeNullOrEmpty
                $resourceCurrentState.DisplayName | Should -BeNullOrEmpty
                $resourceCurrentState.Enabled | Should -Be $true
                $resourceCurrentState.ManagedPasswordPrincipals | Should -BeNullOrEmpty
                $resourceCurrentState.MembershipAttribute | Should -Be 'SamAccountName'
                $resourceCurrentState.KerberosEncryptionType | Should -Be $DefaultKerberosEncryptionType
                $resourceCurrentState.DistinguishedName | Should -Be ('CN={0},{1}' -f `
                        $ConfigurationData.ManagedServiceAccount3.Name, $DefaultManagedServiceAccountPath)
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_Initialise_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    & $configurationName @configurationParameters
                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
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
