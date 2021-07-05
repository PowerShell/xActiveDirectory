$script:dscModuleName = 'ActiveDirectoryDsc'
$script:dscResourceName = 'MSFT_ADUser'

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

        $testDomainController = 'TESTDC'
        $testPassword = ConvertTo-SecureString -String 'P@ssW0rd1' -AsPlainText -Force
        $testCredential = [System.Management.Automation.PSCredential]::new('user', $testPassword)
        $testChangedPassword = ConvertTo-SecureString -String 'P@ssW0rd2' -AsPlainText -Force
        $testChangedCredential = [System.Management.Automation.PSCredential]::new('user', $testChangedPassword)
        $mockThumbnailPhotoHash = 'D8719F18D789F449CBD14B5798BE79F7'
        $mockThumbnailPhotoBase64 = '/9j/4AAQSkZJRgABAQEAYABgAAD/4QBmRXhp'
        $mockThumbnailPhotoByteArray = [System.Byte[]] (
            255, 216, 255, 224, 0, 16, 74, 70, 73, 70, 0, 1, 1, 1, 0, 96, 0, 96, 0, 0, 255, 225, 0, 102, 69, 120, 105
        )
        $mockChangedThumbnailPhotoHash = '473CA6636A51A3B2953FD5A7D859020F'
        $mockChangedThumbnailPhotoBase64 = '/9j/4AAQSkZJRgABAQEAYABgAAD/4QBmRXhq'

        $mockPath = 'CN=Users,DC=contoso,DC=com'
        $UserName = 'TestUser'

        $mockResource = @{
            DomainName                        = 'contoso.com'
            UserName                          = $UserName
            Path                              = $mockPath
            DistinguishedName                 = "CN=$UserName,$mockPath"
            DisplayName                       = 'Test User'
            SamAccountName                    = $UserName
            Initials                          = 'T'
            Enabled                           = $true
            GivenName                         = 'Test'
            CommonName                        = $UserName
            Password                          = $testCredential
            Description                       = 'This is the test user'
            Surname                           = 'User'
            StreetAddress                     = '1 Highway Road'
            POBox                             = 'PO Box 1'
            City                              = 'Cityville'
            State                             = 'State'
            UserPrincipalName                 = 'testuser@contoso.com'
            ServicePrincipalNames             = 'spn/a', 'spn/b'
            ThumbnailPhoto                    = $mockThumbnailPhotoBase64
            ThumbnailPhotoHash                = $mockThumbnailPhotoHash
            PostalCode                        = 'AA1 1AA'
            Country                           = 'US'
            Department                        = 'IT'
            Division                          = 'Global'
            Company                           = 'Contoso'
            Office                            = 'Office 1'
            JobTitle                          = 'Test'
            EmailAddress                      = 'testuser@contoso.com'
            EmployeeID                        = 'ID1'
            EmployeeNumber                    = '1'
            HomeDirectory                     = '\\fs01\users\testuser'
            HomeDrive                         = 'H:'
            HomePage                          = 'www.contoso.com/users/testuser'
            ProfilePath                       = 'profilepath'
            LogonScript                       = 'logonscript.ps1'
            Notes                             = 'This is a test user'
            OfficePhone                       = '+1 12345'
            MobilePhone                       = '+1 23456'
            Fax                               = '+1 34567'
            Pager                             = '+1 45678'
            IPPhone                           = '12345'
            HomePhone                         = '+1 56789'
            Manager                           = 'John Doe'
            LogonWorkstations                 = 'PC01,PC02'
            Organization                      = 'Contoso'
            OtherName                         = 'User1'
            PasswordNeverExpires              = $false
            CannotChangePassword              = $false
            ChangePasswordAtLogon             = $true
            TrustedForDelegation              = $false
            AccountNotDelegated               = $true
            AllowReversiblePasswordEncryption = $false
            CompoundIdentitySupported         = $false
            PasswordNotRequired               = $false
            SmartcardLogonRequired            = $false
            ProxyAddresses                    = 'testuser1@fabrikam.com', 'testuser2@fabrikam.com'
            Ensure                            = 'Present'
        }

        $mockAbsentResource = @{
            DomainName                        = 'contoso.com'
            UserName                          = $UserName
            Path                              = $null
            DistinguishedName                 = $null
            DisplayName                       = $null
            Initials                          = $null
            Enabled                           = $null
            GivenName                         = $null
            CommonName                        = $null
            Password                          = $null
            Description                       = $null
            Surname                           = $null
            StreetAddress                     = $null
            POBox                             = $null
            City                              = $null
            State                             = $null
            UserPrincipalName                 = $null
            ServicePrincipalNames             = $null
            ThumbnailPhoto                    = $null
            ThumbnailPhotoHash                = $null
            PostalCode                        = $null
            Country                           = $null
            Department                        = $null
            Division                          = $null
            Company                           = $null
            Office                            = $null
            JobTitle                          = $null
            EmailAddress                      = $null
            EmployeeID                        = $null
            EmployeeNumber                    = $null
            HomeDirectory                     = $null
            HomeDrive                         = $null
            HomePage                          = $null
            ProfilePath                       = $null
            LogonScript                       = $null
            Notes                             = $null
            OfficePhone                       = $null
            MobilePhone                       = $null
            Fax                               = $null
            Pager                             = $null
            IPPhone                           = $null
            HomePhone                         = $null
            Manager                           = $null
            LogonWorkstations                 = $null
            Organization                      = $null
            OtherName                         = $null
            PasswordNeverExpires              = $null
            CannotChangePassword              = $null
            ChangePasswordAtLogon             = $null
            TrustedForDelegation              = $null
            AccountNotDelegated               = $null
            AllowReversiblePasswordEncryption = $null
            CompoundIdentitySupported         = $null
            PasswordNotRequired               = $null
            SmartcardLogonRequired            = $null
            ProxyAddresses                    = $null
            Ensure                            = 'Absent'
        }

        $mockChangedResource = @{
            Path                              = 'OU=Staff,DC=contoso,DC=com'
            DisplayName                       = 'Test User Changed'
            SamAccountName                    = 'TestUserChanged'
            Initials                          = 'S'
            Enabled                           = $false
            GivenName                         = 'Test Changed'
            CommonName                        = 'Common Changed'
            Description                       = 'This is the test user changed'
            Surname                           = 'User Changed'
            StreetAddress                     = '1 Highway Road Changed'
            POBox                             = 'PO Box 1 Changed'
            City                              = 'Cityville Changed'
            State                             = 'State Changed'
            ServicePrincipalNames             = 'spn/c', 'spn/d'
            ThumbnailPhoto                    = $mockChangedThumbnailPhotoBase64
            PostalCode                        = 'AA1 1AA Changed'
            Country                           = 'GB'
            Department                        = 'IT Changed'
            Division                          = 'Global Changed'
            Company                           = 'Contoso Changed'
            Office                            = 'Office 1 Changed'
            JobTitle                          = 'Test Changed'
            EmailAddress                      = 'testuserchanged@contoso.com'
            EmployeeID                        = 'ID1 Changed'
            EmployeeNumber                    = '2'
            HomeDirectory                     = '\\fs01\users\testuserchanged'
            HomeDrive                         = 'I:'
            HomePage                          = 'www.contoso.com/users/testuserchanged'
            ProfilePath                       = 'changed profile path'
            LogonScript                       = 'logonscript-changed.ps1'
            Notes                             = 'This is a test user changed'
            OfficePhone                       = '+1 123456'
            MobilePhone                       = '+1 234567'
            Fax                               = '+1 345678'
            Pager                             = '+1 456789'
            IPPhone                           = '123456'
            HomePhone                         = '+1 567890'
            Manager                           = 'John Doe Changed'
            LogonWorkstations                 = 'PC03,PC04'
            Organization                      = 'Contoso Changed'
            OtherName                         = 'User1 Changed'
            PasswordNeverExpires              = $true
            CannotChangePassword              = $true
            ChangePasswordAtLogon             = $false
            TrustedForDelegation              = $true
            AccountNotDelegated               = $false
            AllowReversiblePasswordEncryption = $true
            CompoundIdentitySupported         = $true
            PasswordNotRequired               = $true
            SmartcardLogonRequired            = $true
            ProxyAddresses                    = 'testuser3@fabrikam.com', 'testuser4@fabrikam.com'
        }

        $mockGetADUserResult = @{
            samAccountName                    = $mockResource.SamAccountName
            cn                                = $mockResource.CommonName
            UserPrincipalName                 = $mockResource.UserPrincipalName
            DisplayName                       = $mockResource.DisplayName
            distinguishedName                 = "CN=$($mockResource.Username),$($mockResource.Path)"
            GivenName                         = $mockResource.GivenName
            Initials                          = $mockResource.Initials
            sn                                = $mockResource.Surname
            Description                       = $mockResource.Description
            StreetAddress                     = $mockResource.StreetAddress
            PostOfficeBox                     = $mockResource.POBox
            l                                 = $mockResource.City
            St                                = $mockResource.State
            PostalCode                        = $mockResource.PostalCode
            c                                 = $mockResource.Country
            Department                        = $mockResource.Department
            Division                          = $mockResource.Division
            Company                           = $mockResource.Company
            physicalDeliveryOfficeName        = $mockResource.Office
            title                             = $mockResource.JobTitle
            mail                              = $mockResource.EmailAddress
            EmployeeID                        = $mockResource.EmployeeID
            EmployeeNumber                    = $mockResource.EmployeeNumber
            HomeDirectory                     = $mockResource.HomeDirectory
            HomeDrive                         = $mockResource.HomeDrive
            wWWHomePage                       = $mockResource.HomePage
            ProfilePath                       = $mockResource.ProfilePath
            scriptPath                        = $mockResource.LogonScript
            info                              = $mockResource.Notes
            telephoneNumber                   = $mockResource.OfficePhone
            mobile                            = $mockResource.MobilePhone
            facsimileTelephoneNumber          = $mockResource.Fax
            Pager                             = $mockResource.Pager
            IPPhone                           = $mockResource.IPPhone
            HomePhone                         = $mockResource.HomePhone
            Enabled                           = $mockResource.Enabled
            Manager                           = $mockResource.Manager
            userWorkstations                  = $mockResource.LogonWorkstations
            O                                 = $mockResource.Organization
            middleName                        = $mockResource.OtherName
            ThumbnailPhoto                    = $mockThumbnailPhotoByteArray
            PasswordNeverExpires              = $mockResource.PasswordNeverExpires
            CannotChangePassword              = $mockResource.CannotChangePassword
            pwdLastSet                        = 0
            TrustedForDelegation              = $mockResource.TrustedForDelegation
            AccountNotDelegated               = $mockResource.AccountNotDelegated
            AllowReversiblePasswordEncryption = $mockResource.AllowReversiblePasswordEncryption
            CompoundIdentitySupported         = $mockResource.CompoundIdentitySupported
            PasswordNotRequired               = $mockResource.PasswordNotRequired
            SmartcardLogonRequired            = $mockResource.SmartcardLogonRequired
            ServicePrincipalName              = $mockResource.ServicePrincipalNames
            ProxyAddresses                    = $mockResource.ProxyAddresses
        }

        $mockGetTargetResourceResult = $mockResource.Clone()

        $mockGetTargetResourcePresentResult = $mockGetTargetResourceResult.Clone()
        $mockGetTargetResourcePresentResult.Ensure = 'Present'

        $mockGetTargetResourceAbsentResult = $mockGetTargetResourceResult.Clone()
        $mockGetTargetResourceAbsentResult.Ensure = 'Absent'

        Describe 'ADUser\Get-TargetResource' {
            BeforeAll {
                Mock -CommandName Assert-Module

                $getTargetResourceParameters = @{
                    DomainName = $mockResource.DomainName
                    UserName   = $mockResource.UserName
                }
            }

            Context 'When the resource is present' {
                BeforeAll {
                    Mock -CommandName Get-ADUser -MockWith { $mockGetADUserResult }

                    $targetResource = Get-TargetResource @getTargetResourceParameters
                }

                foreach ($property in $mockResource.Keys)
                {
                    if ($property -ne 'Password')
                    {
                        It "Should return the correct '$property' property" {
                            $targetResource.$property | Should -Be $mockResource.$property

                        }
                    }
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Assert-Module `
                        -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ADUser `
                        -ParameterFilter { $Identity -eq $mockResource.UserName } `
                        -Exactly -Times 1
                }

                Context 'When the "ChangePassswordAtLogon" parameter is false' {
                    BeforeAll {
                        $mockChangePasswordFalseGetADUserResult = $mockGetADUserResult.Clone()
                        $mockChangePasswordFalseGetADUserResult['pwdLastSet'] = 12345678

                        Mock -CommandName Get-ADUser -MockWith { $mockChangePasswordFalseGetADUserResult }
                    }

                    It 'Should return the correct property' {
                        $targetResource = Get-TargetResource @getTargetResourceParameters

                        $targetResource.ChangePasswordAtLogon | Should -BeFalse
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Assert-Module `
                            -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-ADUser `
                            -ParameterFilter { $Identity -eq $mockResource.UserName } `
                            -Exactly -Times 1
                    }
                }

                Context 'When the "ThumbnailPhoto" parameter is empty' {
                    BeforeAll {
                        $mockThumbnailPhotoEmptyGetADUserResult = $mockGetADUserResult.Clone()
                        $mockThumbnailPhotoEmptyGetADUserResult['ThumbnailPhoto'] = ''

                        Mock -CommandName Get-ADUser -MockWith { $mockThumbnailPhotoEmptyGetADUserResult }
                    }

                    It 'Should return the correct property' {
                        $targetResource = Get-TargetResource @getTargetResourceParameters

                        $targetResource.ThumbnailPhoto | Should -BeNullOrEmpty
                        $targetResource.ThumbnailPhotoHash | Should -BeNullOrEmpty
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Assert-Module `
                            -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-ADUser `
                            -ParameterFilter { $Identity -eq $mockResource.UserName } `
                            -Exactly -Times 1
                    }
                }
            }

            Context 'When the resource is absent' {
                BeforeAll {
                    Mock -CommandName Get-ADUser `
                        -MockWith { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }

                    $targetResource = Get-TargetResource @getTargetResourceParameters
                }

                foreach ($property in $mockResource.Keys)
                {
                    It "Should return the correct '$property' property" {
                        $targetResource.$property | Should -Be $mockAbsentResource.$property
                    }
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Assert-Module `
                        -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ADUser `
                        -ParameterFilter { $Identity -eq $mockResource.UserName } `
                        -Exactly -Times 1
                }
            }

            Context 'When Get-ADUser returns an unknown error' {
                BeforeAll {
                    Mock -CommandName Get-ADUser -MockWith { throw }

                    $expectedError = ($script:localizedData.RetrievingADUserError -f
                        $getTargetResourceParameters.UserName, $getTargetResourceParameters.DomainName)
                }

                It 'Should throw the correct exception ' {
                    { Get-TargetResource @getTargetResourceParameters } | Should -Throw $expectedError
                }
            }

            Context 'When the "DomainController" parameter is specified' {
                BeforeAll {
                    Mock -CommandName Get-ADUser -MockWith { $mockGetADUserResult }

                    Get-TargetResource @getTargetResourceParameters -DomainController $testDomainController
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Assert-Module `
                        -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ADUser `
                        -ParameterFilter { $Server -eq $testDomainController } `
                        -Exactly -Times 1
                }
            }

            Context 'When the "Credential" parameter is specified' {
                BeforeAll {
                    Mock -CommandName Get-ADUser -MockWith { $mockGetADUserResult }

                    Get-TargetResource @getTargetResourceParameters -Credential $testCredential
                }

                It "Should call the expected mocks" {
                    Assert-MockCalled -CommandName Assert-Module `
                        -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ADUser `
                        -ParameterFilter { $Credential -eq $testCredential } `
                        -Exactly -Times 1
                }
            }
        }

        Describe 'ADUser\Test-TargetResource' {
            BeforeAll {
                $testTargetResourceParams = @{
                    DomainName = $mockResource.DomainName
                    UserName   = $mockResource.UserName
                }

                $testTargetResourcePresentParams = $testTargetResourceParams.Clone()
                $testTargetResourcePresentParams.Ensure = 'Present'

                $testTargetResourceAbsentParams = $testTargetResourceParams.Clone()
                $testTargetResourceAbsentParams.Ensure = 'Absent'
            }

            Context 'When the Resource is Present' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentResult }
                    Mock -CommandName Test-Password
                }

                Context 'When the Resource should be Present' {
                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourcePresentParams } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { $UserName -eq $testTargetResourcePresentParams.UserName } `
                            -Exactly -Times 1
                    }

                    foreach ($property in $mockChangedResource.Keys)
                    {
                        Context "When the '$property' property is not in the desired state" {
                            BeforeAll {
                                $testTargetResourceNotInDesiredStateParams = $testTargetResourcePresentParams.Clone()
                                $testTargetResourceNotInDesiredStateParams.$property = $mockChangedResource.$property
                            }

                            It 'Should return $false' {
                                Test-TargetResource @testTargetResourceNotInDesiredStateParams | Should -Be $false
                            }
                        }

                        if ($mockChangedResource.$property -isnot [Boolean])
                        {
                            if ($mockChangedResource.$property -isnot [Array])
                            {
                                Context "When the '$property' parameter should be null" {
                                    BeforeAll {
                                        $testTargetResourceNullParams = $testTargetResourcePresentParams.Clone()
                                        $testTargetResourceNullParams.$property = $null
                                    }

                                    It 'Should return $false' {
                                        Test-TargetResource @testTargetResourceNullParams | Should -Be $false
                                    }
                                }
                            }

                            Context "When the '$property' parameter should be empty" {
                                BeforeAll {
                                    $testTargetResourceEmptyParams = $testTargetResourcePresentParams.Clone()
                                    $testTargetResourceEmptyParams.$property = ''
                                }

                                It 'Should return $false' {
                                    Test-TargetResource @testTargetResourceEmptyParams | Should -Be $false
                                }
                            }
                        }

                        if ($mockChangedResource.$property -is [Array])
                        {
                            Context "When the '$property' parameter should be an empty array" {
                                BeforeAll {
                                    $testTargetResourceEmptyArrayParams = $testTargetResourcePresentParams.Clone()
                                    $testTargetResourceEmptyArrayParams.$property = @()
                                }

                                It 'Should return $false' {
                                    Test-TargetResource @testTargetResourceEmptyArrayParams | Should -Be $false
                                }
                            }
                        }
                    }

                    Context 'When all the resource properties are in the desired state' {
                        It 'Should return the desired result' {
                            Test-TargetResource @testTargetResourcePresentParams | Should -Be $true
                        }
                    }

                    Context 'When the "DomainController" parameter is specified' {
                        It 'Should not throw' {
                            { Test-TargetResource @testTargetResourcePresentParams `
                                    -DomainController $testDomainController } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $DomainController -eq $testDomainController } `
                                -Exactly -Times 1
                        }
                    }

                    Context 'When the "Credential" parameter is specified' {
                        It 'Should not throw' {
                            { Test-TargetResource @testTargetResourcePresentParams `
                                    -Credential $testCredential } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $Credential -eq $testCredential } `
                                -Exactly -Times 1
                        }
                    }

                    Context 'When the "Password" parameter is specified' {
                        Context 'When the specified Password has changed' {
                            BeforeAll {
                                Mock -CommandName Test-Password -MockWith { $false }
                            }

                            Context 'When the "PasswordNeverResets" parameter is False' {
                                It 'Should return the desired result' {
                                    Test-TargetResource @testTargetResourcePresentParams `
                                        -Password $testCredential `
                                        -PasswordNeverResets $false | Should -BeFalse
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $testTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $testTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential } `
                                        -Exactly -Times 1
                                }
                            }

                            Context 'When the "PasswordNeverResets" parameter is True' {
                                It 'Should return the desired result' {
                                    Test-TargetResource @testTargetResourcePresentParams `
                                        -Password $testCredential `
                                        -PasswordNeverResets $true | Should -BeTrue
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $testTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -Exactly -Times 0
                                }
                            }

                            Context 'When the "Credential" parameter is specified' {
                                It 'Should return the desired result' {
                                    Test-TargetResource @testTargetResourcePresentParams `
                                        -Credential $testCredential `
                                        -Password $testCredential | Should -BeFalse
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $testTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $testTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential -and `
                                            $Credential -eq $testCredential } `
                                        -Exactly -Times 1
                                }
                            }

                            Context 'When the "PasswordAuthentication" parameter is specified as "Default"' {
                                BeforeAll {
                                    $testPasswordAuthentication = 'Default'
                                }

                                It 'Should return the desired result' {
                                    Test-TargetResource @testTargetResourcePresentParams `
                                        -Password $testCredential `
                                        -PasswordAuthentication $testPasswordAuthentication | Should -BeFalse
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $testTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $testTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential -and `
                                            $PasswordAuthentication -eq $testPasswordAuthentication } `
                                        -Exactly -Times 1
                                }
                            }

                            Context 'When the "PasswordAuthentication" parameter is specified as "Negotiate"' {
                                BeforeAll {
                                    $testPasswordAuthentication = 'Negotiate'
                                }

                                It 'Should return the desired result' {
                                    Test-TargetResource @testTargetResourcePresentParams `
                                        -Password $testCredential `
                                        -PasswordAuthentication $testPasswordAuthentication | Should -BeFalse
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $testTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $testTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential -and `
                                            $PasswordAuthentication -eq $testPasswordAuthentication } `
                                        -Exactly -Times 1
                                }
                            }
                        }

                        Context 'When the specified Password has not changed' {
                            BeforeAll {
                                Mock -CommandName Test-Password -MockWith { $true }
                            }

                            Context 'When the "PasswordNeverResets" parameter is False' {
                                It 'Should return the desired result' {
                                    Test-TargetResource @testTargetResourcePresentParams `
                                        -Password $testCredential `
                                        -PasswordNeverResets $false | Should -BeTrue
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $testTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $testTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential } `
                                        -Exactly -Times 1
                                }
                            }

                            Context 'When the "PasswordNeverResets" parameter is True' {
                                It 'Should return the desired result' {
                                    Test-TargetResource @testTargetResourcePresentParams `
                                        -Password $testCredential `
                                        -PasswordNeverResets $true | Should -BeTrue
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $testTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -Exactly -Times 0
                                }
                            }

                            Context 'When the "Credential" parameter is specified' {
                                It 'Should return the desired result' {
                                    Test-TargetResource @testTargetResourcePresentParams `
                                        -Credential $testCredential `
                                        -Password $testCredential | Should -BeTrue
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $testTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $testTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential -and `
                                            $Credential -eq $testCredential } `
                                        -Exactly -Times 1
                                }
                            }

                            Context 'When the "PasswordAuthentication" parameter is specified as "Default"' {
                                BeforeAll {
                                    $testPasswordAuthentication = 'Default'
                                }

                                It 'Should return the desired result' {
                                    Test-TargetResource @testTargetResourcePresentParams `
                                        -Password $testCredential `
                                        -PasswordAuthentication $testPasswordAuthentication | Should -BeTrue
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $testTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $testTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential -and `
                                            $PasswordAuthentication -eq $testPasswordAuthentication } `
                                        -Exactly -Times 1
                                }
                            }

                            Context 'When the "PasswordAuthentication" parameter is specified as "Negotiate"' {
                                BeforeAll {
                                    $testPasswordAuthentication = 'Negotiate'
                                }

                                It 'Should return the desired result' {
                                    Test-TargetResource @testTargetResourcePresentParams `
                                        -Password $testCredential `
                                        -PasswordAuthentication $testPasswordAuthentication | Should -BeTrue
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $testTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $testTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential -and `
                                            $PasswordAuthentication -eq $testPasswordAuthentication } `
                                        -Exactly -Times 1
                                }
                            }
                        }
                    }
                }

                Context 'When the Resource should be Absent' {
                    It 'Should return the desired result' {
                        Test-TargetResource @testTargetResourceAbsentParams | Should -BeFalse
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { $UserName -eq $testTargetResourceAbsentParams.UserName } `
                            -Exactly -Times 1
                    }
                }
            }

            Context 'When the Resource is Absent' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith { $testTargetResourceAbsentParams }
                }

                Context 'When the Resource should be Present' {
                    It 'Should return the desired result' {
                        Test-TargetResource @testTargetResourcePresentParams | Should -BeFalse
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { $UserName -eq $testTargetResourceAbsentParams.UserName } `
                            -Exactly -Times 1
                    }

                    Context 'When ChangePasswordAtLogon is true and does not match the AD Account property' {
                        BeforeAll {
                            $mockGetTargetResourceAbsentPasswordTrueResult = `
                                $mockGetTargetResourceAbsentResult.Clone()
                            $mockGetTargetResourceAbsentPasswordTrueResult['ChangePasswordAtLogon'] = $false

                            Mock -CommandName Get-TargetResource `
                                -MockWith { $mockGetTargetResourceAbsentPasswordTrueResult }
                        }

                        It 'Should return the desired result' {
                            Test-TargetResource @testTargetResourcePresentParams -ChangePasswordAtLogon $true |
                                Should -BeFalse
                        }
                    }
                }

                Context 'When the Resource should be Absent' {
                    It 'Should return the desired result' {
                        Test-TargetResource @testTargetResourceAbsentParams | Should -BeTrue
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { $UserName -eq $testTargetResourceAbsentParams.UserName } `
                            -Exactly -Times 1
                    }
                }
            }
        }

        Describe 'ADUser\Set-TargetResource' {
            BeforeAll {
                $setTargetResourceParams = @{
                    DomainName = $mockResource.DomainName
                    UserName   = $mockResource.UserName

                }

                $setTargetResourcePresentParams = $setTargetResourceParams.Clone()
                $setTargetResourcePresentParams['Ensure'] = 'Present'

                $setTargetResourceAbsentParams = $setTargetResourceParams.Clone()
                $setTargetResourceAbsentParams['Ensure'] = 'Absent'

                Mock -CommandName Set-ADUser
                Mock -CommandName Move-ADObject
                Mock -CommandName Rename-ADObject
                Mock -CommandName Set-ADAccountPassword
                Mock -CommandName Test-Password
                Mock -CommandName Remove-ADUser
                Mock -CommandName New-ADUser
                Mock -CommandName Restore-ADCommonObject
            }

            Context 'When the resource is present' {
                BeforeAll {
                    $mockChangedSetResource = $mockChangedResource.Clone()
                    $mockChangedSetResource.Remove('Path')
                    $mockChangedSetResource.Remove('CommonName')
                    $mockChangedSetResource.Remove('ChangePasswordAtLogon')

                    Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentResult }
                }

                Context 'When the resource should be present' {
                    foreach ($property in $mockChangedSetResource.Keys)
                    {
                        Context "When the '$property' parameter has changed" {
                            BeforeAll {
                                $setTargetResourceParamsChangedProperty = $setTargetResourcePresentParams.Clone()
                                $setTargetResourceParamsChangedProperty.$property = $mockChangedSetResource.$property
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceParamsChangedProperty } |
                                    Should -Not -Throw
                            }

                            It 'Should call the correct mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { `
                                        $Name -eq $setTargetResourceParamsChangedProperty.Name } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADUser `
                                    -ParameterFilter { $TargetName -eq $setTargetResourceParamsChangedProperty.Name } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Move-ADObject `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Rename-ADObject `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Set-ADAccountPassword `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Test-Password `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Remove-ADUser `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName New-ADUser `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 0
                            }
                        }

                        if ($mockChangedSetResource.$property -isnot [Boolean])
                        {
                            if ($mockChangedSetResource.$property -isnot [Array])
                            {
                                Context "When the '$property' parameter should be null" {
                                    BeforeAll {
                                        $setTargetResourceNullParams = $setTargetResourcePresentParams.Clone()
                                        $setTargetResourceNullParams.$property = $null
                                    }

                                    It 'Should not throw' {
                                        { Set-TargetResource @setTargetResourceNullParams } | Should -Not -Throw
                                    }

                                    It 'Should call the correct mocks' {
                                        Assert-MockCalled -CommandName Get-TargetResource `
                                            -ParameterFilter { `
                                                $Name -eq $setTargetResourceParamsChangedProperty.Name } `
                                            -Exactly -Times 1
                                        Assert-MockCalled -CommandName Set-ADUser `
                                            -ParameterFilter { `
                                                $TargetName -eq $setTargetResourceParamsChangedProperty.Name } `
                                            -Exactly -Times 1
                                        Assert-MockCalled -CommandName Move-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Rename-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Set-ADAccountPassword `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Test-Password `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Remove-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName New-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                                            -Exactly -Times 0
                                    }
                                }
                            }

                            Context "When the '$property' parameter should be empty" {
                                BeforeAll {
                                    $setTargetResourceEmptyParams = $setTargetResourcePresentParams.Clone()
                                    $setTargetResourceEmptyParams.$property = ''
                                }

                                It 'Should not throw' {
                                    { Set-TargetResource @setTargetResourceEmptyParams } | Should -Not -Throw
                                }

                                It 'Should call the correct mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { `
                                            $Name -eq $setTargetResourceParamsChangedProperty.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Set-ADUser `
                                        -ParameterFilter { `
                                            $TargetName -eq $setTargetResourceParamsChangedProperty.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Move-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Rename-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Set-ADAccountPassword `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Test-Password `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Remove-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName New-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Restore-ADCommonObject `
                                        -Exactly -Times 0
                                }
                            }
                        }

                        if ($mockChangedSetResource.$property -is [Array])
                        {
                            Context "When the $property parameter should be an empty array" {
                                BeforeAll {
                                    $setTargetResourceEmptyArrayParams = $setTargetResourcePresentParams.Clone()
                                    $setTargetResourceEmptyArrayParams.$property = @()
                                }

                                It 'Should not throw' {
                                    { Set-TargetResource @setTargetResourceEmptyArrayParams } | Should -Not -Throw
                                }

                                It 'Should call the correct mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { `
                                            $Name -eq $setTargetResourceParamsChangedProperty.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Set-ADUser `
                                        -ParameterFilter { `
                                            $TargetName -eq $setTargetResourceParamsChangedProperty.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Move-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Rename-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Set-ADAccountPassword `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Test-Password `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Remove-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName New-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Restore-ADCommonObject `
                                        -Exactly -Times 0
                                }
                            }
                        }
                    }

                    Context 'When the "Path" property has changed' {
                        BeforeAll {
                            $changedTargetPath = 'OU=Changed,DC=contoso,DC=com'
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -Path $changedTargetPath } | Should -Not -Throw
                        }

                        It "Should call the expected mocks" {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { `
                                    $Name -eq $setTargetResourcePresentParams.Name } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Move-ADObject `
                                -ParameterFilter { $TargetPath -eq $changedTargetPath } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Rename-ADObject `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADAccountPassword `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Test-Password `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Remove-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName New-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                        }
                    }

                    Context 'When the "CommonName" property has changed' {
                        BeforeAll {
                            $testCommonName = 'Test Common Name'
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams -CommonName $testCommonName } |
                                Should -Not -Throw
                        }

                        It "Should call the expected mocks" {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { `
                                    $Name -eq $setTargetResourcePresentParams.Name } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Rename-ADObject `
                                -ParameterFilter { $NewName -eq $testCommonName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Move-ADObject `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADAccountPassword `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Test-Password `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Remove-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName New-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                        }
                    }

                    Context 'When the "DomainController" parameter is specified' {
                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -DomainController $testDomainController } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $DomainController -eq $testDomainController } `
                                -Exactly -Times 1
                        }
                    }

                    Context 'When the "Password" parameter is specified' {
                        Context 'When the specified Password has changed' {
                            BeforeAll {
                                Mock -CommandName Test-Password -MockWith { $false }
                            }

                            Context 'When the "PasswordNeverResets" parameter is False' {

                                It 'Should not throw' {
                                    { Set-TargetResource @setTargetResourcePresentParams `
                                            -Password $testCredential `
                                            -PasswordNeverResets $false } | Should -Not -Throw
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $setTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Set-ADAccountPassword `
                                        -ParameterFilter { $NewPassword -eq $testCredential.Password } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $setTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Rename-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Move-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Set-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Remove-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName New-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Restore-ADCommonObject `
                                        -Exactly -Times 0
                                }
                            }

                            Context 'When the "PasswordNeverResets" parameter is True' {
                                It 'Should not throw' {
                                    { Set-TargetResource @setTargetResourcePresentParams `
                                            -Password $testCredential `
                                            -PasswordNeverResets $true } | Should -Not -Throw
                                }

                                It "Should call the expected mocks" {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $setTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Set-ADAccountPassword `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Rename-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Move-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Set-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Test-Password `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Remove-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName New-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Restore-ADCommonObject `
                                        -Exactly -Times 0
                                }
                            }

                            Context 'When the "Credential" parameter is specified' {
                                It 'Should not throw' {
                                    { Set-TargetResource @setTargetResourcePresentParams `
                                            -Password $testCredential `
                                            -Credential $testCredential } | Should -Not -Throw
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $setTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $setTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential -and `
                                            $Credential -eq $testCredential } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Set-ADAccountPassword `
                                        -ParameterFilter { $NewPassword -eq $testCredential.Password } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Rename-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Move-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Set-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Remove-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName New-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Restore-ADCommonObject `
                                        -Exactly -Times 0
                                }
                            }

                            Context 'When the "PasswordAuthentication" parameter is specified as "Default"' {
                                BeforeAll {
                                    $testPasswordAuthentication = 'Default'
                                }

                                It 'Should not throw' {
                                    { Set-TargetResource @setTargetResourcePresentParams `
                                            -Password $testCredential `
                                            -PasswordAuthentication $testPasswordAuthentication } | Should -Not -Throw
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $setTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $setTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential -and `
                                            $PasswordAuthentication -eq $testPasswordAuthentication } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Set-ADAccountPassword `
                                        -ParameterFilter { $NewPassword -eq $testCredential.Password } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Rename-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Move-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Set-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Remove-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName New-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Restore-ADCommonObject `
                                        -Exactly -Times 0
                                }
                            }

                            Context 'When the "PasswordAuthentication" parameter is specified as "Negotiate"' {
                                BeforeAll {
                                    $testPasswordAuthentication = 'Negotiate'
                                }

                                It 'Should not throw' {
                                    { Set-TargetResource @setTargetResourcePresentParams `
                                            -Password $testCredential `
                                            -PasswordAuthentication $testPasswordAuthentication } | Should -Not -Throw
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Name -eq $setTargetResourcePresentParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Test-Password `
                                        -ParameterFilter { `
                                            $UserName -eq $setTargetResourcePresentParams.UserName -and `
                                            $Password -eq $testCredential -and `
                                            $PasswordAuthentication -eq $testPasswordAuthentication } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Set-ADAccountPassword `
                                        -ParameterFilter { $NewPassword -eq $testCredential.Password } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Rename-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Move-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Set-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Remove-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName New-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Restore-ADCommonObject `
                                        -Exactly -Times 0
                                }
                            }

                            Context 'When the specified Password has not changed' {
                                BeforeAll {
                                    Mock -CommandName Test-Password -MockWith { $true }
                                }

                                Context 'When the "PasswordNeverResets" parameter is False' {

                                    It 'Should not throw' {
                                        { Set-TargetResource @setTargetResourcePresentParams `
                                                -Password $testCredential `
                                                -PasswordNeverResets $false } | Should -Not -Throw
                                    }

                                    It 'Should call the expected mocks' {
                                        Assert-MockCalled -CommandName Get-TargetResource `
                                            -ParameterFilter { $Name -eq $setTargetResourcePresentParams.Name } `
                                            -Exactly -Times 1
                                        Assert-MockCalled -CommandName Test-Password `
                                            -ParameterFilter { `
                                                $UserName -eq $setTargetResourcePresentParams.UserName -and `
                                                $Password -eq $testCredential } `
                                            -Exactly -Times 1
                                        Assert-MockCalled -CommandName Set-ADAccountPassword `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Rename-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Move-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Set-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Remove-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName New-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                                            -Exactly -Times 0
                                    }
                                }

                                Context 'When the "PasswordNeverResets" parameter is True' {
                                    It 'Should not throw' {
                                        { Set-TargetResource @setTargetResourcePresentParams `
                                                -Password $testCredential `
                                                -PasswordNeverResets $true } | Should -Not -Throw
                                    }

                                    It "Should call the expected mocks" {
                                        Assert-MockCalled -CommandName Get-TargetResource `
                                            -ParameterFilter { $Name -eq $setTargetResourcePresentParams.Name } `
                                            -Exactly -Times 1
                                        Assert-MockCalled -CommandName Set-ADAccountPassword `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Rename-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Move-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Set-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Test-Password `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Remove-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName New-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                                            -Exactly -Times 0
                                    }
                                }

                                Context 'When the "Credential" parameter are specified' {
                                    It 'Should not throw' {
                                        { Set-TargetResource @setTargetResourcePresentParams `
                                                -Password $testCredential `
                                                -Credential $testCredential } | Should -Not -Throw
                                    }

                                    It 'Should call the expected mocks' {
                                        Assert-MockCalled -CommandName Get-TargetResource `
                                            -ParameterFilter { $Name -eq $setTargetResourcePresentParams.Name } `
                                            -Exactly -Times 1
                                        Assert-MockCalled -CommandName Test-Password `
                                            -ParameterFilter { `
                                                $UserName -eq $setTargetResourcePresentParams.UserName -and `
                                                $Password -eq $testCredential -and `
                                                $Credential -eq $testCredential } `
                                            -Exactly -Times 1
                                        Assert-MockCalled -CommandName Set-ADAccountPassword `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Rename-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Move-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Set-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Remove-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName New-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                                            -Exactly -Times 0
                                    }
                                }

                                Context 'When the "PasswordAuthentication" parameter is specified as "Default"' {
                                    BeforeAll {
                                        $testPasswordAuthentication = 'Default'
                                    }

                                    It 'Should not throw' {
                                        { Set-TargetResource @setTargetResourcePresentParams `
                                                -Password $testCredential `
                                                -PasswordAuthentication $testPasswordAuthentication } |
                                            Should -Not -Throw
                                    }

                                    It 'Should call the expected mocks' {
                                        Assert-MockCalled -CommandName Get-TargetResource `
                                            -ParameterFilter { $Name -eq $setTargetResourcePresentParams.Name } `
                                            -Exactly -Times 1
                                        Assert-MockCalled -CommandName Test-Password `
                                            -ParameterFilter { `
                                                $UserName -eq $setTargetResourcePresentParams.UserName -and `
                                                $Password -eq $testCredential -and `
                                                $PasswordAuthentication -eq $testPasswordAuthentication } `
                                            -Exactly -Times 1
                                        Assert-MockCalled -CommandName Set-ADAccountPassword `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Rename-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Move-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Set-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Remove-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName New-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                                            -Exactly -Times 0
                                    }
                                }

                                Context 'When the "PasswordAuthentication" parameter is specified as "Negotiate"' {
                                    BeforeAll {
                                        $testPasswordAuthentication = 'Negotiate'
                                    }

                                    It 'Should not throw' {
                                        { Set-TargetResource @setTargetResourcePresentParams `
                                                -Password $testCredential `
                                                -PasswordAuthentication $testPasswordAuthentication } |
                                            Should -Not -Throw
                                    }

                                    It 'Should call the expected mocks' {
                                        Assert-MockCalled -CommandName Get-TargetResource `
                                            -ParameterFilter { $Name -eq $setTargetResourcePresentParams.Name } `
                                            -Exactly -Times 1
                                        Assert-MockCalled -CommandName Test-Password `
                                            -ParameterFilter { `
                                                $UserName -eq $setTargetResourcePresentParams.UserName -and `
                                                $Password -eq $testCredential -and `
                                                $PasswordAuthentication -eq $testPasswordAuthentication } `
                                            -Exactly -Times 1
                                        Assert-MockCalled -CommandName Set-ADAccountPassword `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Rename-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Move-ADObject `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Set-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Remove-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName New-ADUser `
                                            -Exactly -Times 0
                                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                                            -Exactly -Times 0
                                    }
                                }
                            }
                        }
                    }

                    Context 'When "ChangePasswordAtLogon" is true' {
                        BeforeAll {
                            $mockGetTargetResourcePresentBoolTrueResult = $mockGetTargetResourcePresentResult.Clone()
                            $mockGetTargetResourcePresentBoolTrueResult['ChangePasswordAtLogon'] = $false
                            Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentBoolTrueResult }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams -ChangePasswordAtLogon:$true } |
                                Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { `
                                    $Name -eq $setTargetResourcePresentParams.Name } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Test-Password `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADAccountPassword `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Rename-ADObject `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Move-ADObject `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Remove-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName New-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                        }
                    }
                }

                Context 'When the resource should be absent' {
                    It 'Should not throw' {
                        { Set-TargetResource @setTargetResourceAbsentParams } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { `
                                $Name -eq $setTargetResourceAbsentParams.Name } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Remove-ADUser `
                            -ParameterFilter { $Identity -eq $setTargetResourceAbsentParams.UserName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Set-ADUser `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Test-Password `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Set-ADAccountPassword `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Rename-ADObject `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Move-ADObject `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName New-ADUser `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                            -Exactly -Times 0
                    }
                }
            }

            Context 'When the resource is absent' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceAbsentResult }
                }

                Context 'When the resource should be present' {
                    foreach ($property in $mockChangedResource.Keys)
                    {
                        if ($property -eq 'CommonName')
                        {
                            Context 'When the CommonName does not match the UserName' {
                                BeforeAll {
                                    $setTargetResourceNewParams = $setTargetResourcePresentParams.Clone()
                                    $setTargetResourceNewParams.CommonName = $mockChangedResource.CommonName
                                    $mockNewAdUserResult = @{
                                        DistinguishedName = $mockResource.DistinguishedName
                                    }

                                    Mock -CommandName New-ADUser -MockWith { $mockNewAdUserResult }
                                }

                                It 'Should not throw' {
                                    { Set-TargetResource @setTargetResourceNewParams } |
                                        Should -Not -Throw
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { `
                                            $Name -eq $setTargetResourceNewParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName New-ADUser `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Rename-ADObject `
                                        -ParameterFilter { $NewName -eq $setTargetResourceNewParams.CommonName } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Remove-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Set-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Test-Password `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Set-ADAccountPassword `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Move-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Restore-ADCommonObject `
                                        -Exactly -Times 0
                                }
                            }
                        }
                        else
                        {
                            Context "When the '$property' parameter is specified" {
                                BeforeAll {
                                    $setTargetResourceNewParams = $setTargetResourcePresentParams.Clone()
                                    $setTargetResourceNewParams.$property = $mockChangedResource.$property
                                }

                                It 'Should not throw' {
                                    { Set-TargetResource @setTargetResourceNewParams } | Should -Not -Throw
                                }

                                It 'Should call the correct mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { `
                                            $Name -eq $setTargetResourceNewParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName New-ADUser `
                                        -ParameterFilter { $TargetName -eq $setTargetResourceNewParams.Name } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Set-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Move-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Rename-ADObject `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Set-ADAccountPassword `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Test-Password `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Remove-ADUser `
                                        -Exactly -Times 0
                                    Assert-MockCalled -CommandName Restore-ADCommonObject `
                                        -Exactly -Times 0
                                }
                            }
                        }
                    }

                    Context "When the Password parameter is specified" {
                        BeforeAll {
                            $setTargetResourceNewParams = $setTargetResourcePresentParams.Clone()
                            $setTargetResourceNewParams.Password = $mockResource.Password
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceNewParams } | Should -Not -Throw
                        }

                        It 'Should call the correct mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { `
                                    $Name -eq $setTargetResourceNewParams.Name } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName New-ADUser `
                                -ParameterFilter { $AccountPassword -eq $setTargetResourceNewParams.Password.Password } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Move-ADObject `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Rename-ADObject `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADAccountPassword `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Test-Password `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Remove-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                        }
                    }

                    Context 'When the "RestoreFromRecycleBin" parameter is specified' {

                        Context 'When the user is found in the recycle bin' {
                            BeforeAll {
                                Mock -CommandName Restore-ADCommonObject `
                                    -MockWith { @{ ObjectClass = 'user' } }
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourcePresentParams `
                                        -RestoreFromRecycleBin $true } | Should -Not -Throw
                            }

                            It 'Should call the expected mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { `
                                        $Name -eq $setTargetResourcePresentParams.Name } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADUser `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName New-ADUser `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Remove-ADUser `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Test-Password `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Set-ADAccountPassword `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Rename-ADObject `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Move-ADObject `
                                    -Exactly -Times 0
                            }
                        }

                        Context 'When the user is not found in the recycle bin' {
                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourcePresentParams `
                                        -RestoreFromRecycleBin $true } | Should -Not -Throw
                            }

                            It 'Should call the expected mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { `
                                        $Name -eq $setTargetResourcePresentParams.Name } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName New-ADUser `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADUser `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Remove-ADUser `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Test-Password `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Set-ADAccountPassword `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Rename-ADObject `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Move-ADObject `
                                    -Exactly -Times 0
                            }
                        }

                        Context 'When the user cannot be restored from the recylce bin' {
                            BeforeAll {
                                Mock -CommandName Restore-ADCommonObject -MockWith { throw }
                            }

                            It 'Should throw the correct exception' {
                                { Set-TargetResource @setTargetResourcePresentParams `
                                        -RestoreFromRecycleBin $true } | Should -Throw
                            }

                            It 'Should call the expected mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { `
                                        $Name -eq $setTargetResourcePresentParams.Name } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName New-ADUser `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Set-ADUser `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Remove-ADUser `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Test-Password `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Set-ADAccountPassword `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Rename-ADObject `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Move-ADObject `
                                    -Exactly -Times 0
                            }
                        }
                    }
                }

                Context 'When the resource should be absent' {
                    It 'Should not throw' {
                        { Set-TargetResource @setTargetResourceAbsentParams } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { `
                                $Name -eq $setTargetResourceAbsentParams.Name } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName New-ADUser `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Set-ADUser `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Remove-ADUser `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Test-Password `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Set-ADAccountPassword `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Rename-ADObject `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Move-ADObject `
                            -Exactly -Times 0
                    }
                }
            }
        }

        Describe 'ADUser\Assert-Parameters' {
            Context 'When both parameters PasswordNeverExpires and CannotChangePassword are specified' {
                It 'Should not throw ' {
                    { Assert-Parameters -PasswordNeverExpires $true -CannotChangePassword $true } |
                        Should -Not -Throw
                }
            }

            Context 'When the parameter Enabled is set to $false and the parameter Password is also specified' {
                It 'Should throw the correct exception' {
                    { Assert-Parameters -Password $testCredential -Enabled $false } |
                        Should -Throw ($script:localizedData.PasswordParameterConflictError -f
                            'Enabled', $false, 'Password')
                }
            }

            Context 'When the parameter TrustedForDelegation is specified' {
                It 'Should not throw' {
                    { Assert-Parameters -TrustedForDelegation $true } | Should -Not -Throw
                }
            }

            Context 'when both parameters PasswordNeverExpires and ChangePasswordAtLogon are specified' {
                It 'Should throw the correct exception' {
                    { Assert-Parameters -PasswordNeverExpires $true -ChangePasswordAtLogon $true } |
                        Should -Throw $script:localizedData.ChangePasswordParameterConflictError
                }
            }
        }

        Describe 'ADUser\Get-MD5HashString' {
            It 'Should return the correct hash' {
                Get-MD5HashString -Bytes $mockThumbnailPhotoByteArray | Should -Be $mockThumbnailPhotoHash
            }
        }

        Describe 'ADUser\Get-ThumbnailByteArray' {
            Context 'When providing a Base64-encoded string' {
                It 'Should return the correct byte array' {
                    Get-ThumbnailByteArray -ThumbnailPhoto $mockThumbnailPhotoBase64 |
                        Should -Be $mockThumbnailPhotoByteArray
                }
            }

            Context 'When providing a file path to a jpeg image' {
                It 'Should return the correct byte array' {
                    $mockThumbnailPhotoPath = Join-Path $PSScriptRoot -ChildPath '..\TestHelpers\DSC_Logo_96.jpg'

                    (Get-ThumbnailByteArray `
                            -ThumbnailPhoto $mockThumbnailPhotoPath)[0..($mockThumbnailPhotoByteArray.Count - 1)] |
                        Should -Be $mockThumbnailPhotoByteArray
                }
            }

            Context 'When providing the wrong file path to a jpeg image' {
                It 'Should throw the correct exception' {
                    $mockThumbnailPhotoPath = Join-Path $TestDrive -ChildPath 'WrongFile.jpg'
                    { Get-ThumbnailByteArray -ThumbnailPhoto $mockThumbnailPhotoPath } |
                        Should -Throw $script:localizedData.ThumbnailPhotoNotAFile
                }
            }
        }

        Describe 'ADUser\Compare-ThumbnailPhoto' {
            Context 'When current and desired thumbnail photo are the same' {
                BeforeAll {
                    $compareThumbnailPhotoParameters = @{
                        DesiredThumbnailPhoto     = $mockThumbnailPhotoBase64
                        CurrentThumbnailPhotoHash = $mockThumbnailPhotoHash
                    }
                }

                It 'Should return the correct result' {
                    Compare-ThumbnailPhoto @compareThumbnailPhotoParameters | Should -BeNullOrEmpty
                }
            }

            Context 'When there is no current thumbnail photo, and there should be no thumbnail photo' {
                BeforeAll {
                    $compareThumbnailPhotoParameters = @{
                        DesiredThumbnailPhoto     = ''
                        CurrentThumbnailPhotoHash = $null
                    }
                }

                It 'Should return the correct result' {
                    Compare-ThumbnailPhoto @compareThumbnailPhotoParameters | Should -BeNullOrEmpty
                }
            }

            Context 'When the current thumbnail photo is not the desired thumbnail photo' {
                BeforeAll {
                    $compareThumbnailPhotoParameters = @{
                        DesiredThumbnailPhoto     = $mockChangedThumbnailPhotoBase64
                        CurrentThumbnailPhotoHash = $mockThumbnailPhotoHash
                    }

                    $compareThumbnailPhotoResult = Compare-ThumbnailPhoto @compareThumbnailPhotoParameters
                }

                It 'Should return the correct result' {
                    $compareThumbnailPhotoResult | Should -BeOfType [System.Collections.Hashtable]
                    $compareThumbnailPhotoResult.CurrentThumbnailPhotoHash | Should -Be $mockThumbnailPhotoHash
                    $compareThumbnailPhotoResult.DesiredThumbnailPhotoHash | Should -Be $mockChangedThumbnailPhotoHash
                }
            }

            Context 'When there is no current thumbnail photo, but there should be a thumbnail photo' {
                BeforeAll {
                    $compareThumbnailPhotoParameters = @{
                        DesiredThumbnailPhoto     = $mockThumbnailPhotoBase64
                        CurrentThumbnailPhotoHash = $null
                    }

                    $compareThumbnailPhotoResult = Compare-ThumbnailPhoto @compareThumbnailPhotoParameters
                }

                It 'Should return the correct result' {
                    $compareThumbnailPhotoResult | Should -BeOfType [System.Collections.Hashtable]
                    $compareThumbnailPhotoResult.CurrentThumbnailPhotoHash | Should -BeNullOrEmpty
                    $compareThumbnailPhotoResult.DesiredThumbnailPhotoHash | Should -Be $mockThumbnailPhotoHash
                }
            }

            Context 'When there is a current thumbnail photo, but there should be no thumbnail photo' {
                BeforeAll {
                    $compareThumbnailPhotoParameters = @{
                        DesiredThumbnailPhoto     = ''
                        CurrentThumbnailPhotoHash = $mockThumbnailPhotoHash
                    }
                }

                It 'Should return the correct result' {
                    $compareThumbnailPhotoResult = Compare-ThumbnailPhoto @compareThumbnailPhotoParameters
                    $compareThumbnailPhotoResult | Should -BeOfType [System.Collections.Hashtable]
                    $compareThumbnailPhotoResult.CurrentThumbnailPhotoHash | Should -Be $mockThumbnailPhotoHash
                    $compareThumbnailPhotoResult.DesiredThumbnailPhotoHash | Should -BeNullOrEmpty
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
