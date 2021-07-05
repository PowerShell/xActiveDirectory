[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', "",
    Justification = 'False positive on ManagedPasswordPrincipals')]
param ()

$script:dscModuleName = 'ActiveDirectoryDsc'
$script:dscResourceName = 'MSFT_ADManagedServiceAccount'

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

        $mockDefaultMsaPath = 'CN=Managed Service Accounts,DC=contoso,DC=com'
        $mockChangedPath = 'OU=Service Accounts,DC=contoso,DC=com'
        $mockDomainController = 'MockDC'
        $mockDomainName = 'contoso.com'

        $mockCredentials = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @(
            'DummyUser',
            (ConvertTo-SecureString -String 'DummyPassword' -AsPlainText -Force)
        )

        $mockADUSer = @{
            DistinguishedName = 'CN=User1,CN=Users,DC=contoso,DC=com'
            Name              = 'User1'
            ObjectClass       = 'user'
            ObjectGUID        = '91bffe90-4c84-4026-b1fc-d03671ff56ab'
            ObjectSid         = 'S-1-5-21-1409167834-891301383-2860967316-1142'
            SamAccountName    = 'User1'
        }

        $mockADComputer = @{
            DistinguishedName = 'CN=Node1,CN=Computers,DC=contoso,DC=com'
            Name              = 'Node1'
            ObjectClass       = 'computer'
            ObjectGUID        = '91bffe90-4c84-4026-b1fc-d03671ff56ac'
            ObjectSID         = 'S-1-5-21-1409167834-891301383-2860967316-1143'
            SamAccountName    = 'Node1$'
        }

        $mockAdServiceAccountStandalone = @{
            ServiceAccountName        = 'TestSMSA'
            AccountType               = 'Standalone'
            CommonName                = 'TestSMSACN'
            DistinguishedName         = "CN=TestSMSACN,$mockDefaultMsaPath"
            Description               = 'Dummy StandAlone service account for unit testing'
            DisplayName               = 'TestSMSA'
            Enabled                   = $true
            KerberosEncryptionType    = 'RC4', 'AES128', 'AES256'
            ManagedPasswordPrincipals = @()
            MembershipAttribute       = 'SamAccountName'
            Ensure                    = 'Present'
        }

        $mockAdServiceAccountStandaloneAbsent = @{
            ServiceAccountName        = $mockAdServiceAccountStandalone.ServiceAccountName
            AccountType               = $mockAdServiceAccountStandalone.AccountType
            CommonName                = $null
            DistinguishedName         = $null
            Description               = $null
            DisplayName               = $null
            Enabled                   = $false
            ManagedPasswordPrincipals = @()
            MembershipAttribute       = $mockAdServiceAccountStandalone.MembershipAttribute
            KerberosEncryptionType    = @()
            Ensure                    = 'Absent'
        }

        $mockAdServiceAccountChanged = @{
            CommonName                = 'Changed commonName'
            Description               = 'Changed description'
            DisplayName               = 'Changed displayname'
            KerberosEncryptionType    = 'AES128', 'AES256'
            ManagedPasswordPrincipals = $mockADUSer.SamAccountName
        }

        $mockAdServiceAccountGroup = @{
            ServiceAccountName        = 'TestGMSA'
            AccountType               = 'Group'
            CommonName                = 'TestGMSACN'
            DistinguishedName         = "CN=TestGMSACN,$mockDefaultMsaPath"
            Description               = 'Dummy group service account for unit testing'
            DisplayName               = 'TestGMSA'
            Enabled                   = $true
            KerberosEncryptionType    = 'RC4', 'AES128', 'AES256'
            ManagedPasswordPrincipals = $mockADUSer.SamAccountName, $mockADComputer.SamAccountName
            MembershipAttribute       = 'SamAccountName'
            Ensure                    = 'Present'
        }

        $mockAdServiceAccountGroupAbsent = @{
            ServiceAccountName        = $mockAdServiceAccountGroup.ServiceAccountName
            AccountType               = $mockAdServiceAccountGroup.AccountType
            CommonName                = $null
            DistinguishedName         = $null
            Description               = $null
            DisplayName               = $null
            Enabled                   = $false
            ManagedPasswordPrincipals = @()
            MembershipAttribute       = $mockAdServiceAccountGroup.MembershipAttribute
            KerberosEncryptionType    = @()
            Ensure                    = 'Absent'
        }

        $mockGetAdServiceAccountResultsStandAlone = @{
            CN                     = $mockAdServiceAccountStandAlone.CommonName
            Description            = $mockAdServiceAccountStandalone.Description
            DisplayName            = $mockAdServiceAccountStandalone.DisplayName
            DistinguishedName      = $mockAdServiceAccountStandalone.DistinguishedName
            Enabled                = $mockAdServiceAccountStandalone.Enabled
            KerberosEncryptionType = $mockAdServiceAccountStandalone.KerberosEncryptionType
            Name                   = $mockAdServiceAccountStandalone.ServiceAccountName
            ObjectClass            = 'msDS-ManagedServiceAccount'
            ObjectGUID             = '91bffe90-4c84-4026-b1fc-d03671ff56ad'
            SamAccountName         = $mockAdServiceAccountStandalone.ServiceAccountName
            SID                    = 'S-1-5-21-1409167834-891301383-2860967316-1144'
            UserPrincipalName      = ''
        }

        $mockGetAdServiceAccountResultsGroup = @{
            CN                                         = $mockAdServiceAccountGroup.CommonName
            Description                                = $mockAdServiceAccountGroup.Description
            DisplayName                                = $mockAdServiceAccountGroup.DisplayName
            DistinguishedName                          = $mockAdServiceAccountGroup.DistinguishedName
            Enabled                                    = $mockAdServiceAccountGroup.Enabled
            KerberosEncryptionType                     = $mockAdServiceAccountGroup.KerberosEncryptionType
            Name                                       = $mockAdServiceAccountGroup.ServiceAccountName
            ObjectClass                                = 'msDS-GroupManagedServiceAccount'
            ObjectGUID                                 = '91bffe90-4c84-4026-b1fc-d03671ff56ae'
            PrincipalsAllowedToRetrieveManagedPassword = $mockAdServiceAccountGroup.ManagedPasswordPrincipals
            SamAccountName                             = $mockAdServiceAccountGroup.ServiceAccountName
            SID                                        = 'S-1-5-21-1409167834-891301383-2860967316-1145'
            UserPrincipalName                          = ''
        }

        $mockGetTargetResourceResultsStandAlone = @{
            ServiceAccountName        = $mockGetAdServiceAccountResultsStandAlone.Name
            DistinguishedName         = $mockGetAdServiceAccountResultsStandAlone.DistinguishedName
            Path                      = $mockDefaultMsaPath
            CommonName                = $mockGetAdServiceAccountResultsStandAlone.CN
            Description               = $mockGetAdServiceAccountResultsStandAlone.Description
            DisplayName               = $mockGetAdServiceAccountResultsStandAlone.DisplayName
            AccountType               = 'Standalone'
            Ensure                    = 'Present'
            Enabled                   = $true
            ManagedPasswordPrincipals = @()
            MembershipAttribute       = 'SamAccountName'
            Credential                = $mockCredentials
            DomainController          = $mockDomainController
            KerberosEncryptionType    = 'RC4', 'AES128', 'AES256'
        }

        $mockGetTargetResourceResultsGroup = @{
            ServiceAccountName        = $mockGetAdServiceAccountResultsGroup.Name
            DistinguishedName         = $mockGetAdServiceAccountResultsGroup.DistinguishedName
            Path                      = $mockDefaultMsaPath
            CommonName                = $mockGetAdServiceAccountResultsGroup.CN
            Description               = $mockGetAdServiceAccountResultsGroup.Description
            DisplayName               = $mockGetAdServiceAccountResultsGroup.DisplayName
            AccountType               = 'Group'
            Ensure                    = 'Present'
            Enabled                   = $true
            ManagedPasswordPrincipals = $mockGetAdServiceAccountResultsGroup.PrincipalsAllowedToRetrieveManagedPassword
            MembershipAttribute       = 'SamAccountName'
            Credential                = $mockCredentials
            DomainController          = $mockDomainController
            KerberosEncryptionType    = 'RC4', 'AES128', 'AES256'
        }

        $mockGetTargetResourceResultsStandAloneAbsent = @{
            ServiceAccountName        = $mockGetAdServiceAccountResultsStandAlone.Name
            DistinguishedName         = $null
            Path                      = $null
            CN                        = $null
            Description               = $null
            DisplayName               = $null
            AccountType               = $null
            Ensure                    = 'Absent'
            Enabled                   = $false
            ManagedPasswordPrincipals = @()
            MembershipAttribute       = 'SamAccountName'
            KerberosEncryptionType    = @()
        }

        #region Function Get-TargetResource
        Describe -Name 'MSFT_ADManagedServiceAccount\Get-TargetResource' -Tag 'Get' {
            BeforeAll {
                Mock -CommandName Assert-Module
                Mock -CommandName Get-ADObjectParentDN
                Mock -CommandName Get-AdObject
            }

            $getTargetResourceParametersStandalone = @{
                ServiceAccountName = $mockAdServiceAccountStandAlone.ServiceAccountName
                AccountType        = $mockAdServiceAccountStandAlone.AccountType
            }

            $getTargetResourceParametersGroup = @{
                ServiceAccountName = $mockAdServiceAccountGroup.ServiceAccountName
                AccountType        = $mockAdServiceAccountGroup.AccountType
            }

            Context 'When the resource is Present' {

                Context 'When the Resource is a StandAlone account' {
                    Mock -CommandName Get-ADServiceAccount `
                        -MockWith { $mockGetAdServiceAccountResultsStandAlone }

                    Mock -CommandName Get-AdObjectParentDN `
                        -MockWith { $mockDefaultMsaPath }

                    $result = Get-TargetResource @getTargetResourceParametersStandalone

                    foreach ($property in $mockAdServiceAccountStandalone.Keys)
                    {
                        It "Should return the correct $property property" {
                            $result.$property | Should -Be $mockAdServiceAccountStandalone.$property
                        }
                    }

                    It 'Should return the correct Ensure property' {
                        $result.Ensure | Should -Be 'Present'
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Assert-Module `
                            -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-ADServiceAccount `
                            -ParameterFilter { $Identity -eq $getTargetResourceParametersStandalone.ServiceAccountName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-AdObject `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Get-ADObjectParentDN `
                            -ParameterFilter { $DN -eq $mockAdServiceAccountStandalone.DistinguishedName } `
                            -Exactly -Times 1
                    }
                }

                Context 'When the Resource is a Group account' {
                    Mock -CommandName Get-ADServiceAccount `
                        -MockWith { $mockGetAdServiceAccountResultsGroup }

                    Mock -CommandName Get-ADObject `
                        -ParameterFilter { $mockADComputer.SamAccountName -eq $Identity } `
                        -MockWith { $mockADComputer }

                    Mock -CommandName Get-ADObject `
                        -ParameterFilter { $mockADUser.SamAccountName -eq $Identity } `
                        -MockWith { $mockADUser }

                    Mock -CommandName Get-AdObjectParentDN `
                        -MockWith { $mockDefaultMsaPath }

                    $result = Get-TargetResource @getTargetResourceParametersGroup

                    foreach ($property in $mockAdServiceAccountGroup.Keys)
                    {
                        It "Should return the correct $property property" {
                            $result.$property | Should -Be $mockAdServiceAccountGroup.$property
                        }
                    }

                    It 'Should return the correct Ensure property' {
                        $result.Ensure | Should -Be 'Present'
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Assert-Module `
                            -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-ADServiceAccount `
                            -ParameterFilter { $Identity -eq $getTargetResourceParametersGroup.ServiceAccountName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-AdObject `
                            -ParameterFilter { `
                                $Identity -eq $mockGetAdServiceAccountResultsGroup.PrincipalsAllowedToRetrieveManagedPassword[0] } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-AdObject `
                            -ParameterFilter { `
                                $Identity -eq $mockGetAdServiceAccountResultsGroup.PrincipalsAllowedToRetrieveManagedPassword[1] } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-ADObjectParentDN `
                            -ParameterFilter { $DN -eq $mockGetAdServiceAccountResultsGroup.DistinguishedName } `
                            -Exactly -Times 1
                    }
                }
                Context 'When Get-AdServiceAccount throws an unexpected error' {
                    Mock -CommandName Get-ADServiceAccount `
                        -MockWith { throw 'UnexpectedError' }

                    It 'Should throw the correct exception' {
                        { Get-TargetResource  @getTargetResourceParametersStandAlone } |
                            Should -Throw ($script:localizedData.RetrievingManagedServiceAccountError -f
                                $getTargetResourceParametersStandAlone.ServiceAccountName)
                    }
                }

                Context 'When the group service account member property contains an unknown principal' {
                    $mockGetAdServiceAccountResultsGroupUnknownPrincipal = $mockGetAdServiceAccountResultsGroup.Clone()
                    $mockGetAdServiceAccountResultsGroupUnknownPrincipal.PrincipalsAllowedtoRetrieveManagedPassword = `
                        $mockADUSer.ObjectSid, $mockADComputer.ObjectSid

                    Mock -CommandName Get-ADServiceAccount `
                        -MockWith { $mockGetAdServiceAccountResultsGroupUnknownPrincipal }

                    Mock -CommandName Get-ADObject `
                        -MockWith { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }

                    $result = Get-TargetResource  @getTargetResourceParametersGroup

                    It 'Should return the correct ManagedPasswordPrincipals property`' {
                        $result.ManagedPasswordPrincipals | Should -Be $mockADUSer.ObjectSid, $mockADComputer.ObjectSid
                    }
                }

                Context 'When Get-AdObject throws an unexpected error' {
                    Mock -CommandName Get-ADServiceAccount `
                        -MockWith { $mockGetAdServiceAccountResultsGroup }

                    Mock -CommandName Get-ADObject `
                        -MockWith { throw 'UnexpectedError' }

                    It 'Should throw the correct exception' {
                        { Get-TargetResource  @getTargetResourceParametersGroup } |
                            Should -Throw ($script:localizedData.RetrievingManagedPasswordPrincipalsError -f
                                $mockGetAdServiceAccountResultsGroup.PrincipalsAllowedToRetrieveManagedPassword[0])
                    }
                }
            }

            Context 'When the resource is Absent' {

                Context 'When the Resource is a StandAlone account' {
                    Mock -CommandName Get-AdServiceAccount `
                        -MockWith { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }

                    $result = Get-TargetResource @getTargetResourceParametersStandalone

                    foreach ($property in $mockAdServiceAccountStandaloneAbsent.Keys)
                    {
                        It "Should return the correct $property property" {
                            $result.$property | Should -Be $mockAdServiceAccountStandaloneAbsent.$property
                        }
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Assert-Module `
                            -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-ADServiceAccount `
                            -ParameterFilter { `
                                $Identity -eq $getTargetResourceParametersStandalone.ServiceAccountName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-AdObject `
                            -Exactly -Times 0
                    }
                }

                Context 'When the Resource is a Group account' {
                    Mock -CommandName Get-AdServiceAccount `
                        -MockWith { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }

                    $result = Get-TargetResource @getTargetResourceParametersGroup

                    foreach ($property in $mockAdServiceAccountGroupAbsent.Keys)
                    {
                        It "Should return the correct $property property" {
                            $result.$property | Should -Be $mockAdServiceAccountGroupAbsent.$property
                        }
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Assert-Module `
                            -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-ADServiceAccount `
                            -ParameterFilter { $Identity -eq $getTargetResourceParametersGroup.ServiceAccountName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-AdObject `
                            -Exactly -Times 0
                    }
                }
            }
        }
        #endregion Function Get-TargetResource

        #region Function Test-TargetResource
        Describe -Name 'MSFT_ADManagedServiceAccount\Test-TargetResource' -Tag 'Test' {

            $testTargetResourceParametersStandalone = @{
                ServiceAccountName        = $mockAdServiceAccountStandalone.ServiceAccountName
                AccountType               = $mockAdServiceAccountStandalone.AccountType
                CommonName                = $mockAdServiceAccountStandalone.CommonName
                Description               = $mockAdServiceAccountStandalone.Description
                DisplayName               = $mockAdServiceAccountStandalone.DisplayName
                KerberosEncryptionType    = $mockAdServiceAccountStandalone.KerberosEncryptionType
                ManagedPasswordPrincipals = $mockAdServiceAccountStandalone.ManagedPasswordPrincipals
                MembershipAttribute       = $mockAdServiceAccountStandalone.MembershipAttribute
                Ensure                    = $mockAdServiceAccountStandalone.Ensure
            }

            $testTargetResourceParametersStandaloneAbsent = $testTargetResourceParametersStandalone.Clone()
            $testTargetResourceParametersStandaloneAbsent.Ensure = 'Absent'

            Context 'When the Resource is Present' {

                Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResultsStandAlone }

                Context 'When the Resource should be Present' {

                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParametersStandalone } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { `
                                $ServiceAccountName -eq $testTargetResourceParametersStandalone.ServiceAccountName } `
                            -Exactly -times 1
                    }

                    Context 'When all the resource properties are in the desired state' {

                        It 'Should return $true' {
                            Test-TargetResource @testTargetResourceParametersStandalone | Should -Be $true
                        }
                    }

                    foreach ($property in $mockAdServiceAccountChanged.Keys)
                    {
                        Context "When the $property resource property is not in the desired state" {

                            It 'Should return $false' {
                                $testTargetResourceParametersChanged = $testTargetResourceParametersStandalone.Clone()
                                $testTargetResourceParametersChanged.$property = $mockAdServiceAccountChanged.$property

                                Test-TargetResource @testTargetResourceParametersChanged | Should -Be $false
                            }
                        }
                    }
                }

                Context 'When the Resource should be Absent' {

                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParametersStandAloneAbsent } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter {
                            $ServiceAccountName -eq $testTargetResourceParametersStandAloneAbsent.ServiceAccountName } `
                            -Exactly -times 1
                    }

                    It 'Should return $false' {
                        Test-TargetResource @testTargetResourceParametersStandAloneAbsent | Should -Be $false
                    }
                }
            }

            Context 'When the Resource is Absent' {

                Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResultsStandAloneAbsent }

                Context 'When the Resource should be Present' {

                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParametersStandAlone } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter {
                            $ServiceAccountName -eq $testTargetResourceParametersStandAlone.ServiceAccountName } `
                            -Exactly -times 1
                    }

                    It 'Should return $false' {
                        Test-TargetResource @testTargetResourceParametersStandAlone | Should -Be $false
                    }
                }

                Context 'When the Resource should be Absent' {

                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParametersStandAloneAbsent } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { `
                                $ServiceAccountName -eq $testTargetResourceParametersStandAloneAbsent.ServiceAccountName } `
                            -Exactly -times 1
                    }

                    It 'Should return $true' {
                        Test-TargetResource @testTargetResourceParametersStandAloneAbsent | Should -Be $true
                    }
                }
            }
        }
        #endregion Function Test-TargetResource

        #region Function Set-TargetResource
        Describe -Name 'MSFT_ADManagedServiceAccount\Set-TargetResource' -Tag 'Set' {
            BeforeAll {
                $mockGetAdDomainResults = @{
                    DistinguishedName = 'DC=' + $mockDomainName.Replace('.', ',DC=')
                }

                Mock -CommandName New-ADServiceAccount
                Mock -CommandName Remove-ADServiceAccount
                Mock -CommandName Move-ADObject
                Mock -CommandName Rename-ADObject
                Mock -CommandName Set-ADServiceAccount
                Mock -CommandName Get-DomainName -MockWith { $mockDomainName }
                Mock -CommandName Get-ADDomain -MockWith { $mockGetAdDomainResults }
            }

            $setTargetResourceParametersStandAlone = @{
                ServiceAccountName     = $mockAdServiceAccountStandAlone.ServiceAccountName
                AccountType            = $mockAdServiceAccountStandAlone.AccountType
                Path                   = $mockDefaultMsaPath
                CommonName             = $mockAdServiceAccountStandalone.CommonName
                Description            = $mockAdServiceAccountStandalone.Description
                Ensure                 = $mockAdServiceAccountStandAlone.Ensure
                DisplayName            = $mockAdServiceAccountStandAlone.DisplayName
                KerberosEncryptionType = $mockAdServiceAccountStandAlone.KerberosEncryptionType
            }

            $setTargetResourceParametersStandAloneAbsent = $setTargetResourceParametersStandAlone.Clone()
            $setTargetResourceParametersStandAloneAbsent.Ensure = 'Absent'

            $setTargetResourceParametersGroup = @{
                ServiceAccountName        = $mockAdServiceAccountGroup.ServiceAccountName
                MembershipAttribute       = $mockAdServiceAccountGroup.MembershipAttribute
                AccountType               = $mockAdServiceAccountGroup.AccountType
                Path                      = $mockDefaultMsaPath
                CommonName                = $mockAdServiceAccountGroup.CommonName
                Description               = $mockAdServiceAccountGroup.Description
                Ensure                    = $mockAdServiceAccountGroup.Ensure
                ManagedPasswordPrincipals = $mockAdServiceAccountGroup.ManagedPasswordPrincipals
                DisplayName               = $mockAdServiceAccountGroup.Name.DisplayName
                KerberosEncryptionType    = $mockAdServiceAccountGroup.KerberosEncryptionType
            }
            Context 'When the Resource should be Present' {

                Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResultsStandAlone }

                Context 'When the Resource is Present' {

                    foreach ($property in $mockAdServiceAccountChanged.Keys)
                    {
                        $setTargetResourceParametersChangedProperty = $setTargetResourceParametersGroup.Clone()
                        $setTargetResourceParametersChangedProperty.$property = $mockAdServiceAccountChanged.$property

                        Mock -CommandName Get-TargetResource `
                            -ParameterFilter { $mockGetAdServiceAccountResultsGroup.Name -eq $ServiceAccountName } `
                            -MockWith { $mockGetTargetResourceResultsGroup }

                        It "Should call the correct mocks when $property has changed" {
                            Set-TargetResource @setTargetResourceParametersChangedProperty

                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { `
                                    $ServiceAccountName -eq $setTargetResourceParametersChangedProperty.ServiceAccountName } `
                                -Scope It -Exactly -Times 1
                            Assert-MockCalled -CommandName New-ADServiceAccount -Scope It -Exactly -Times 0
                            Assert-MockCalled -CommandName Remove-ADServiceAccount -Scope It -Exactly -Times 0
                            if ($property -eq 'CommonName') {
                                Assert-MockCalled -CommandName Rename-ADObject -Scope It -Exactly -Times 1
                            }
                            else {
                                Assert-MockCalled -CommandName Rename-ADObject -Scope It -Exactly -Times 0
                            }
                            Assert-MockCalled -CommandName Move-ADObject -Scope It -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADServiceAccount `
                                -ParameterFilter { `
                                    $Identity -eq $setTargetResourceParametersChangedProperty.ServiceAccountName } `
                                -Scope It -Exactly -Times 1
                            Assert-MockCalled -CommandName Get-DomainName -Scope It -Exactly -Times 0
                            Assert-MockCalled -CommandName Get-ADDomain -Scope It -Exactly -Times 0
                        }
                    }

                    Context 'When ''Set-AdServiceAccount'' throws an exception' {
                        Mock -CommandName Set-ADServiceAccount -MockWith { throw 'UnexpectedError' }

                        It 'Should throw the correct exception' {
                            { Set-TargetResource  @setTargetResourceParametersChangedProperty } |
                                Should -Throw ($script:localizedData.SettingManagedServiceAccountError -f
                                    $setTargetResourceParametersChangedProperty.AccountType,
                                    $setTargetResourceParametersChangedProperty.ServiceAccountName)
                        }
                    }

                    Context 'When the Resource has a changed AccountType' {
                        $setTargetResourceParametersChangedAccountType = $setTargetResourceParametersStandAlone.Clone()
                        $setTargetResourceParametersChangedAccountType.AccountType = 'Group'

                        Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResultsStandAlone }

                        It 'Should call the correct mocks' {
                            Set-TargetResource @setTargetResourceParametersChangedAccountType

                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { `
                                    $ServiceAccountName -eq $setTargetResourceParametersChangedAccountType.ServiceAccountName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName New-ADServiceAccount `
                                -ParameterFilter { `
                                    $Name -eq $setTargetResourceParametersChangedAccountType.CommonName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Remove-ADServiceAccount `
                                -ParameterFilter { `
                                    $Identity -eq $setTargetResourceParametersChangedAccountType.ServiceAccountName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Get-DomainName -Exactly -Times 1
                            Assert-MockCalled -CommandName Rename-ADObject -Exactly -Times 0
                            Assert-MockCalled -CommandName Move-ADObject -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADServiceAccount -Exactly -Times 0
                            Assert-MockCalled -CommandName Get-ADDomain -Exactly -Times 0
                        }

                        Context 'When ''Remove-AdServiceAccount'' throws an exception' {
                            Mock -CommandName Remove-ADServiceAccount -MockWith { throw 'UnexpectedError' }

                            It 'Should throw the correct exception' {
                                { Set-TargetResource  @setTargetResourceParametersChangedAccountType } |
                                    Should -Throw ($script:localizedData.RemovingManagedServiceAccountError -f
                                        $setTargetResourceParametersChangedAccountType.AccountType,
                                        $setTargetResourceParametersChangedAccountType.ServiceAccountName)
                            }
                        }
                    }

                    Context 'When the Resource has a changed Path' {
                        $setTargetResourceParametersChangedPath = $setTargetResourceParametersStandAlone.Clone()
                        $setTargetResourceParametersChangedPath.Path = $mockChangedPath

                        Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResultsStandAlone }

                        It 'Should call the correct mocks' {
                            Set-TargetResource @setTargetResourceParametersChangedPath

                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $ServiceAccountName -eq $setTargetResourceParametersChangedPath.ServiceAccountName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName New-ADServiceAccount -Exactly -Times 0
                            Assert-MockCalled -CommandName Remove-ADServiceAccount -Exactly -Times 0
                            Assert-MockCalled -CommandName Rename-ADObject -Exactly -Times 0
                            Assert-MockCalled -CommandName Move-ADObject `
                                -ParameterFilter { $Identity -eq $mockGetTargetResourceResultsStandAlone.DistinguishedName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADServiceAccount -Exactly -Times 0
                            Assert-MockCalled -CommandName Get-DomainName -Exactly -Times 0
                            Assert-MockCalled -CommandName Get-ADDomain -Exactly -Times 0
                        }

                        Context 'When ''Move-AdObject'' throws an exception' {
                            Mock -CommandName Move-AdObject -MockWith { throw 'UnexpectedError' }

                            It 'Should throw the correct exception' {
                                { Set-TargetResource  @setTargetResourceParametersChangedPath } |
                                    Should -Throw ($script:localizedData.MovingManagedServiceAccountError -f
                                        $setTargetResourceParametersChangedPath.AccountType,
                                        $setTargetResourceParametersChangedPath.ServiceAccountName,
                                        $mockGetTargetResourceResultsStandAlone.Path,
                                        $setTargetResourceParametersChangedPath.Path)
                            }
                        }
                    }
                }

                Context 'When the Resource is Absent' {
                    Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResultsStandAloneAbsent }

                    Context 'When the resource is a Standalone Account' {
                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceParametersStandAlone } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { `
                                    $ServiceAccountName -eq $setTargetResourceParametersStandAlone.ServiceAccountName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName New-ADServiceAccount `
                                -ParameterFilter { $Name -eq $setTargetResourceParametersStandAlone.CommonName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Remove-ADServiceAccount -Exactly -Times 0
                            Assert-MockCalled -CommandName Rename-ADObject -Exactly -Times 0
                            Assert-MockCalled -CommandName Move-ADObject -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADServiceAccount -Exactly -Times 0
                            Assert-MockCalled -CommandName Get-DomainName -Exactly -Times 0
                            Assert-MockCalled -CommandName Get-ADDomain -Exactly -Times 0
                        }

                        Context 'When "New-AdServiceAccount" throws an unexpected exception' {
                            Mock -CommandName New-AdServiceAccount -MockWith { throw 'UnexpectedError' }

                            It 'Should throw the correct exception' {
                                { Set-TargetResource  @setTargetResourceParametersStandAlone } |
                                    Should -Throw ($script:localizedData.AddingManagedServiceAccountError -f
                                        $setTargetResourceParametersStandAlone.AccountType,
                                        $setTargetResourceParametersStandAlone.ServiceAccountName,
                                        $setTargetResourceParametersStandAlone.Path)
                            }

                            Context 'When the Path property has not been specified' {
                                $setTargetResourceParametersStandAloneNoPath = $setTargetResourceParametersStandAlone.Clone()
                                $setTargetResourceParametersStandAloneNoPath.Remove('Path')

                                It 'Should throw the correct exception' {
                                    { Set-TargetResource  @setTargetResourceParametersStandAloneNoPath } |
                                        Should -Throw ($script:localizedData.AddingManagedServiceAccountError -f
                                            $setTargetResourceParametersStandAloneNoPath.AccountType,
                                            $setTargetResourceParametersStandAloneNoPath.ServiceAccountName,
                                            $mockDefaultMsaPath)
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-ADDomain -Scope Context -Exactly -Times 1
                                }

                                Context 'when "Get-ADDomain" throws an exception' {
                                    Mock -CommandName Get-ADDomain -MockWith { throw 'UnexpectedError' }

                                    It 'Should throw the correct exception' {
                                        { Set-TargetResource  @setTargetResourceParametersStandAloneNoPath } |
                                            Should -Throw $script:localizedData.GettingADDomainError
                                    }
                                }
                            }
                        }
                    }

                    Context 'When the resource is a Group Account' {
                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceParametersGroup } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter {
                                $ServiceAccountName -eq $setTargetResourceParametersGroup.ServiceAccountName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName New-ADServiceAccount `
                                -ParameterFilter { $Name -eq $setTargetResourceParametersGroup.CommonName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Get-DomainName -Exactly -Times 1
                            Assert-MockCalled -CommandName Remove-ADServiceAccount -Exactly -Times 0
                            Assert-MockCalled -CommandName Rename-ADObject -Exactly -Times 0
                            Assert-MockCalled -CommandName Move-ADObject -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADServiceAccount -Exactly -Times 0
                            Assert-MockCalled -CommandName Get-ADDomain -Exactly -Times 0
                        }

                        Context 'When "New-AdServiceAccount" throws an "ADException KDS key not found" exception' {
                            $mockADException = [Microsoft.ActiveDirectory.Management.ADException]::new()
                            $mockADException.ErrorCode = $script:errorCodeKdsRootKeyNotFound

                            Mock -CommandName New-AdServiceAccount -MockWith { throw $mockADException }

                            It 'Should throw the correct exception' {
                                { Set-TargetResource  @setTargetResourceParametersGroup } |
                                    Should -Throw ($script:localizedData.KdsRootKeyNotFoundError -f
                                        $setTargetResourceParametersGroup.ServiceAccountName)
                            }
                        }

                        Context 'When "New-AdServiceAccount" throws an unknown "ADException" exception' {
                            $mockADException = [Microsoft.ActiveDirectory.Management.ADException]::new()

                            Mock -CommandName New-AdServiceAccount -MockWith { throw $mockADException }

                            It 'Should throw the correct exception' {
                                { Set-TargetResource  @setTargetResourceParametersGroup } |
                                    Should -Throw ($script:localizedData.AddingManagedServiceAccountError -f
                                        $setTargetResourceParametersGroup.AccountType,
                                        $setTargetResourceParametersGroup.ServiceAccountName,
                                        $setTargetResourceParametersGroup.Path)
                            }
                        }
                    }
                }
            }

            Context 'When the Resource should be Absent' {

                Context 'When the Resource is Present' {
                    Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResultsStandAlone }

                    It 'Should not throw' {
                        { Set-TargetResource @setTargetResourceParametersStandAloneAbsent } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter {
                            $ServiceAccountName -eq $setTargetResourceParametersStandAloneAbsent.ServiceAccountName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName New-ADServiceAccount -Exactly -Times 0
                        Assert-MockCalled -CommandName Remove-ADServiceAccount `
                            -ParameterFilter {
                            $Identity -eq $setTargetResourceParametersStandAloneAbsent.ServiceAccountName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Rename-ADObject -Exactly -Times 0
                        Assert-MockCalled -CommandName Move-ADObject -Exactly -Times 0
                        Assert-MockCalled -CommandName Set-ADServiceAccount -Exactly -Times 0
                        Assert-MockCalled -CommandName Get-DomainName -Exactly -Times 0
                        Assert-MockCalled -CommandName Get-ADDomain -Exactly -Times 0
                    }

                    Context 'When ''Remove-AdServiceAccount'' throws an exception' {
                        Mock -CommandName Remove-ADServiceAccount -MockWith { throw 'UnexpectedError' }

                        It 'Should throw the correct exception' {
                            { Set-TargetResource  @setTargetResourceParametersStandAloneAbsent } |
                                Should -Throw ($script:localizedData.RemovingManagedServiceAccountError -f
                                    $setTargetResourceParametersStandAloneAbsent.AccountType,
                                    $setTargetResourceParametersStandAloneAbsent.ServiceAccountName)
                        }
                    }
                }

                Context 'When the Resource is Absent' {
                    Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResultsStandAloneAbsent }

                    It 'Should not throw' {
                        { Set-TargetResource @setTargetResourceParametersStandAloneAbsent } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { `
                                $ServiceAccountName -eq $setTargetResourceParametersStandAloneAbsent.ServiceAccountName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName New-ADServiceAccount -Exactly -Times 0
                        Assert-MockCalled -CommandName Remove-ADServiceAccount -Exactly -Times 0
                        Assert-MockCalled -CommandName Rename-ADObject -Exactly -Times 0
                        Assert-MockCalled -CommandName Move-ADObject -Exactly -Times 0
                        Assert-MockCalled -CommandName Set-ADServiceAccount -Exactly -Times 0
                        Assert-MockCalled -CommandName Get-DomainName -Exactly -Times 0
                        Assert-MockCalled -CommandName Get-ADDomain -Exactly -Times 0
                    }
                }
            }
        }
        #endregion Function Set-TargetResource
    }
}
finally
{
    Invoke-TestCleanup
}
