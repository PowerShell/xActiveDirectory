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
        $testCredential = [System.Management.Automation.PSCredential]::Empty

        $testStringProperties = @(
            'UserPrincipalName', 'DisplayName', 'Path', 'GivenName', 'Initials', 'Surname', 'Description', 'StreetAddress',
            'POBox', 'City', 'State', 'PostalCode', 'Country', 'Department', 'Division', 'Company', 'Office', 'JobTitle',
            'EmailAddress', 'EmployeeID', 'EmployeeNumber', 'HomeDirectory', 'HomeDrive', 'HomePage', 'ProfilePath',
            'LogonScript', 'Notes', 'OfficePhone', 'MobilePhone', 'Fax', 'Pager', 'IPPhone', 'HomePhone', 'CommonName',
            'Manager', 'LogonWorkstations', 'Organization', 'OtherName'
        )
        $testBooleanProperties = @(
            'PasswordNeverExpires', 'CannotChangePassword', 'TrustedForDelegation', 'Enabled', 'AccountNotDelegated',
            'AllowReversiblePasswordEncryption', 'CompoundIdentitySupported', 'PasswordNotRequired', 'SmartcardLogonRequired'
        )
        $testArrayProperties = @('ServicePrincipalNames', 'ProxyAddresses')

        $mockWrongThumbnailPhotoHash = '9C09BC64AB56D12A1A7E60D284DEB122'

        $mockThumbnailPhotoHash = 'D8719F18D789F449CBD14B5798BE79F7'
        $mockThumbnailPhotoBase64 = '/9j/4AAQSkZJRgABAQEAYABgAAD/4QBmRXhp'
        $mockThumbnailPhotoByteArray = [System.Byte[]] (
            255, 216, 255, 224, 0, 16, 74, 70, 73, 70, 0, 1, 1, 1, 0, 96, 0, 96, 0, 0, 255, 225, 0, 102, 69, 120, 105
        )
        $mockChangedThumbnailPhotoHash = 'D8719F18D789F449CBD14B5798BE79F7'
        $mockChangedThumbnailPhotoBase64 = '/9j/4AAQSkZJRgABAQEAYABgAAD/4QBmRXhq'
        $mockChangedThumbnailPhotoByteArray = [System.Byte[]] (
            255, 216, 255, 224, 0, 16, 74, 70, 73, 70, 0, 1, 1, 1, 0, 96, 0, 96, 0, 0, 255, 225, 0, 102, 69, 120, 106
        )
        $mockPath = 'CN=Users,DC=contoso,DC=com'
        $UserName = 'TestUser'

        $mockResource = @{
            DomainName                        = 'contoso.com'
            UserName                          = $UserName
            Path                              = $mockPath
            DistinguishedName                 = "CN=$UserName,$mockPath"
            DisplayName                       = 'Test User'
            Initials                          = 'T'
            Enabled                           = $true
            GivenName                         = 'Test'
            CommonName                        = 'Common'
            Password                          = 'password'
            Description                       = 'This is the test user'
            Surname                           = 'User'
            StreetAddress                     = '1 Highway Road'
            POBox                             = 'PO Box 1'
            City                              = 'Cityville'
            State                             = 'State'
            UserPrincipalName                 = 'testuser@contoso.com'
            ServicePrincipalNames             = @('spn/a', 'spn/b')
            ThumbnailPhoto                    = $mockThumbnailPhotoBase64
            ThumbnailPhotoHash                = $mockThumbnailPhotoHash
            PostalCode                        = 'AA1 1AA'
            Country                           = 'Country'
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
            UserName                          = 'TestUser'
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
            ServicePrincipalNames             = @('spn/c', 'spn/d')
            ThumbnailPhoto                    = $mockChangedThumbnailPhotoBase64
            PostalCode                        = 'AA1 1AA Changed'
            Country                           = 'Country Changed'
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
            samAccountName                    = $mockResource.UserName
            cn                                = $mockResource.CommonName
            UserPrincipalName                 = $mockResource.UserPrincipalName
            DisplayName                       = $mockResource.DisplayName
            distinguishedName                 = "CN=$($mockResource.Username),$($mockResource.Path)"
            GivenName                         = $mockResource.GivenName
            Initials                          = $mockResource.Initials
            sn                                = $mockResource.Surname
            Description                       = $mockResource.Description
            StreetAddress                     = $mockResource.StreetAddress
            POBox                             = $mockResource.POBox
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
            Organization                      = $mockResource.Organization
            OtherName                         = $mockResource.OtherName
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
                        It "Should return the correct $property property" {
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
                    It 'Should return the correct property' {
                        $mockChangePasswordFalseGetADUserResult = $mockGetADUserResult.Clone()
                        $mockChangePasswordFalseGetADUserResult['pwdLastSet'] = 12345678

                        Mock -CommandName Get-ADUser -MockWith { $mockChangePasswordFalseGetADUserResult }

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
            }

            Context 'When the resource is absent' {
                BeforeAll {
                    Mock -CommandName Get-ADUser `
                        -MockWith { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }

                    $targetResource = Get-TargetResource @getTargetResourceParameters
                }

                foreach ($property in $mockResource.Keys)
                {
                    It "Should return the correct $property property" {
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
                        Context "When the $property resource property is not in the desired state" {
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
                                Context "When the $property resource property should be null" {
                                    BeforeAll {
                                        $testTargetResourceNullParams = $testTargetResourcePresentParams.Clone()
                                        $testTargetResourceNullParams.$property = $null
                                    }

                                    It 'Should return $false' {
                                        Test-TargetResource @testTargetResourceNullParams | Should -Be $false
                                    }
                                }
                            }

                            Context "When the $property resource property should be empty" {
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
                            Context "When the $property resource property should be an empty array" {
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

                    Context 'When password does not match, "Password" is specified and "PasswordNeverResets" is True' {
                        BeforeAll {
                            Mock -CommandName Test-Password -MockWith { $false }
                        }

                        It 'Should return the desired result' {
                            Test-TargetResource @testTargetResourcePresentParams `
                                -Password $testCredential -PasswordNeverResets $true | Should -BeTrue
                        }
                    }

                    Context 'When password does not match, "Password" is specified and "PasswordNeverResets" is False' {
                        BeforeAll {
                            Mock -CommandName Test-Password -MockWith { $false }
                        }

                        It 'Should return the desired result' {
                            Test-TargetResource @testTargetResourcePresentParams `
                                -Password $testCredential -PasswordNeverResets $false | Should -BeFalse
                        }
                    }

                    Context 'When the "PasswordAuthentication" parameter is "Default"' {
                        BeforeAll {
                            Mock -CommandName Test-Password -MockWith { $true }
                        }

                        It 'Should not throw' {
                            { Test-TargetResource @testTargetResourcePresentParams -Password $testCredential } |
                                Should -Not -Throw
                        }

                        It 'should call the expected mocks' {
                            Assert-MockCalled -CommandName Test-Password `
                                -ParameterFilter { $PasswordAuthentication -eq 'Default' }
                        }
                    }

                    Context 'When the "PasswordAuthentication" parameter is "Negotiate"' {
                        BeforeAll {
                            Mock -CommandName Test-Password -MockWith { $false }
                        }

                        It 'Should not throw' {
                            { Test-TargetResource @testTargetResourcePresentParams `
                                    -Password $testCredential -PasswordAuthentication 'Negotiate' } |
                                Should -Not -Throw
                        }

                        It 'should call the expected mocks' {
                            Assert-MockCalled -CommandName Test-Password `
                                -ParameterFilter { $PasswordAuthentication -eq 'Negotiate' }
                        }
                    }

                    Context 'When ChangePasswordAtLogon is false and matches the AD Account property' {
                        BeforeAll {
                            $mockGetTargetResourcePresentPasswordFalseResult = `
                                $mockGetTargetResourcePresentResult.Clone()
                            $mockGetTargetResourcePresentPasswordFalseResult['ChangePasswordAtLogon'] = $false

                            Mock -CommandName Get-TargetResource `
                                -MockWith { $mockGetTargetResourcePresentPasswordFalseResult }
                        }

                        It 'Should return the desired result' {
                            Test-TargetResource @testTargetResourcePresentParams -ChangePasswordAtLogon $false |
                                Should -BeTrue
                        }
                    }

                    Context 'When ChangePasswordAtLogon is false and does not match the AD Account property' {
                        BeforeAll {
                            $mockGetTargetResourcePresentPasswordFalseResult = `
                                $mockGetTargetResourcePresentResult.Clone()
                            $mockGetTargetResourcePresentPasswordFalseResult['ChangePasswordAtLogon'] = $true

                            Mock -CommandName Get-TargetResource `
                                -MockWith { $mockGetTargetResourcePresentPasswordFalseResult }
                        }

                        It 'Should return the desired result' {
                            Test-TargetResource @testTargetResourcePresentParams -ChangePasswordAtLogon $false |
                                Should -BeFalse
                        }
                    }

                    Context 'When ChangePasswordAtLogon is true and matches the AD Account property' {
                        BeforeAll {
                            $mockGetTargetResourcePresentPasswordTrueResult = `
                                $mockGetTargetResourcePresentResult.Clone()
                            $mockGetTargetResourcePresentPasswordTrueResult['ChangePasswordAtLogon'] = $true

                            Mock -CommandName Get-TargetResource `
                                -MockWith { $mockGetTargetResourcePresentPasswordTrueResult }
                        }

                        It 'Should return the desired result' {
                            Test-TargetResource @testTargetResourcePresentParams -ChangePasswordAtLogon $true |
                                Should -BeTrue
                        }
                    }

                    Context 'When ChangePasswordAtLogon is true and does not match the AD Account property' {
                        BeforeAll {
                            $mockGetTargetResourcePresentPasswordTrueResult = `
                                $mockGetTargetResourcePresentResult.Clone()
                            $mockGetTargetResourcePresentPasswordTrueResult['ChangePasswordAtLogon'] = $false

                            Mock -CommandName Get-TargetResource `
                                -MockWith { $mockGetTargetResourcePresentPasswordTrueResult }
                        }

                        It 'Should return the desired result' {
                            Test-TargetResource @testTargetResourcePresentParams -ChangePasswordAtLogon $true |
                                Should -BeTrue
                        }
                    }
                }

                Context 'When the Resource should be Absent' {
                    It 'Should return the desired result' {
                        Test-TargetResource @testTargetResourcePresentParams | Should -BeTrue
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { $UserName -eq $testTargetResourcePresentParams.UserName } `
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
                    Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentResult }
                }

                Context 'When the resource should be present' {
                    BeforeAll {
                    }

                    Context 'When the Path property has changed' {
                        BeforeAll {
                            $changedTargetPath = 'OU=Changed,DC=contoso,DC=com'
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -Path $changedTargetPath } | Should -Not -Throw
                        }

                        It "Should call the expected mocks" {
                            Assert-MockCalled -CommandName Get-TargetResource `
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

                    Context 'When the "CommonName" has changed' {
                        BeforeAll {
                            $testCommonName = 'Test Common Name'
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -CommonName $testCommonName -Enabled $true } |
                                Should -Not -Throw
                        }

                        It "Should call the expected mocks" {
                            Assert-MockCalled -CommandName Get-TargetResource `
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

                    Context 'When the "Password" parameter is specified and "PasswordNeverResets" is False' {
                        BeforeAll {
                            Mock -CommandName Test-Password -MockWith { $false }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -Password $testCredential `
                                    -PasswordNeverResets $false } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
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
                            Assert-MockCalled -CommandName Test-Password `
                                -ParameterFilter { $UserName -eq $setTargetResourcePresentParams.UserName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Remove-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName New-ADUser `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                        }
                    }

                    Context 'When the "Password" parameter is specified and "PasswordNeverResets" is True' {
                        BeforeAll {
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -Password $testCredential `
                                    -PasswordNeverResets $true } | Should -Not -Throw
                        }

                        It "Should call the expected mocks" {
                            Assert-MockCalled -CommandName Get-TargetResource `
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

                    Context 'When the "Password" parameter is specified and is in the desired state' {
                        BeforeAll {
                            Mock -CommandName Test-Password -MockWith { $true }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -Password $testCredential } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Test-Password `
                                -ParameterFilter { $UserName -eq $setTargetResourcePresentParams.UserName } `
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

                    Context 'When the "Password" and "Credential" parameters are specified' {
                        BeforeAll {
                            Mock -CommandName Test-Password -MockWith { $true }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -Password $testCredential `
                                    -Credential $testCredential } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Test-Password `
                                -ParameterFilter { $Credential -eq $testCredential } `
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

                    Context 'When existing AD property is null' {
                        BeforeAll {
                            $testADPropertyName = 'Description'
                            $mockGetTargetResourcePresentNullResult = $mockGetTargetResourcePresentResult.Clone()
                            $mockGetTargetResourcePresentNullResult[$testADPropertyName] = $null
                            Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentNullResult }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -Description 'My custom description' } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $Replace.ContainsKey($testADPropertyName) } `
                                -Exactly -Times 1
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

                    Context 'When existing mismatched AD property is empty' {
                        BeforeAll {
                            $testADPropertyName = 'Description'
                            $mockGetTargetResourcePresentEmptyResult = $mockGetTargetResourcePresentResult.Clone()
                            $mockGetTargetResourcePresentEmptyResult[$testADPropertyName] = ''
                            Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentEmptyResult }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -Description 'My custom description' } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $Replace.ContainsKey($testADPropertyName) } `
                                -Exactly -Times 1
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

                    Context 'When new mismatched AD property is empty' {
                        BeforeAll {
                            $testADPropertyName = 'Description'
                            $mockGetTargetResourcePresentEmptyResult = $mockGetTargetResourcePresentResult.Clone()
                            Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentEmptyResult }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -Description '' } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $Clear -eq $testADPropertyName } `
                                -Exactly -Times 1
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

                    Context 'When existing mismatched AD property is null' {
                        BeforeAll {
                            $testADPropertyName = 'Title'
                            $mockGetTargetResourcePresentNullResult = $mockGetTargetResourcePresentResult.Clone()
                            $mockGetTargetResourcePresentNullResult[$testADPropertyName] = $null
                            Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentNullResult }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -JobTitle 'Gaffer' } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $Replace.ContainsKey($testADPropertyName) } `
                                -Exactly -Times 1
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

                    Context 'When new mismatched AD property is not empty' {
                        BeforeAll {
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -JobTitle 'Gaffer' } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $Replace.ContainsKey('Title') } `
                                -Exactly -Times 1
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

                    Context 'When existing mismatched AD array property is empty' {
                        BeforeAll {
                            $mockGetTargetResourcePresentSPNResult = $mockGetTargetResourcePresentResult.Clone()
                            $mockGetTargetResourcePresentSPNResult['ServicePrincipalNames'] = ''

                            Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentSPNResult }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -ServicePrincipalNames @('spn/a', 'spn/b') } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $Replace.ContainsKey('ServicePrincipalName') } `
                                -Exactly -Times 1
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

                    Context 'When existing mismatched AD array property is not empty' {
                        BeforeAll {
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -ServicePrincipalNames @('spn/c', 'spn/d') } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $Replace.ContainsKey('ServicePrincipalName') } `
                                -Exactly -Times 1
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

                    Context 'When new mismatched AD array property is empty' {
                        BeforeAll {
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -ServicePrincipalNames '' } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $Clear -eq 'ServicePrincipalName' } `
                                -Exactly -Times 1
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

                    Context 'When new mismatched AD array property is not empty' {
                        BeforeAll {
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -ServicePrincipalNames @('spn/c', 'spn/d') } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $Replace.ContainsKey('ServicePrincipalName') } `
                                -Exactly -Times 1
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

                    Context 'When new AD boolean property is true and old property is false' {
                        BeforeAll {
                            $mockGetTargetResourcePresentBoolFalseResult = $mockGetTargetResourcePresentResult.Clone()
                            $mockGetTargetResourcePresentBoolFalseResult['CannotChangePassword'] = $false
                            Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentBoolFalseResult }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -CannotChangePassword:$true } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $CannotChangePassword -eq $true } `
                                -Exactly -Times 1
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

                    Context 'When new AD boolean property is false and old property is true' {
                        BeforeAll {
                            $mockGetTargetResourcePresentBoolTrueResult = $mockGetTargetResourcePresentResult.Clone()
                            $mockGetTargetResourcePresentBoolTrueResult['CannotChangePassword'] = $true
                            Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentBoolTrueResult }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentParams `
                                    -CannotChangePassword:$false } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $CannotChangePassword -eq $false } `
                                -Exactly -Times 1
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

                    Context 'When the "ThumbnailPhoto" property is in the desired state' {
                        Context 'When the current thumbnail photo is correct' {
                            BeforeAll {
                                $setTargetResourcePhotoParameters = $setTargetResourcePresentParams.Clone()
                                $setTargetResourcePhotoParameters['ThumbnailPhoto'] = $mockThumbnailPhotoBase64
                                $mockGetTargetResourcePresentPhotoResult = $mockGetTargetResourcePresentResult.Clone()
                                $mockGetTargetResourcePresentPhotoResult['ThumbnailPhotoHash'] = $mockThumbnailPhotoHash

                                Mock -CommandName Get-TargetResource `
                                    -MockWith { $mockGetTargetResourcePresentPhotoResult }
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourcePhotoParameters } | Should -Not -Throw
                            }

                            It 'Should call the expected mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
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

                        Context 'When there is no thumbnail photo' {
                            BeforeAll {
                                $setTargetResourcePhotoParameters = $setTargetResourcePresentParams.Clone()
                                $setTargetResourcePhotoParameters['ThumbnailPhoto'] = ''
                                $mockGetTargetResourcePresentPhotoResult = $mockGetTargetResourcePresentResult.Clone()
                                $mockGetTargetResourcePresentPhotoResult['ThumbnailPhotoHash'] = $null

                                Mock -CommandName Get-TargetResource `
                                    -MockWith { $mockGetTargetResourcePresentPhotoResult }
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourcePhotoParameters } | Should -Not -Throw
                            }

                            It 'Should call the expected mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
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

                    Context 'When the "ThumbnailPhoto" property is not in the desired state' {
                        Context 'When there is no current thumbnail photo' {
                            BeforeAll {
                                $setTargetResourcePhotoParameters = $setTargetResourcePresentParams.Clone()
                                $setTargetResourcePhotoParameters['ThumbnailPhoto'] = $mockThumbnailPhotoBase64
                                $mockGetTargetResourcePresentPhotoResult = $mockGetTargetResourcePresentResult.Clone()
                                $mockGetTargetResourcePresentPhotoResult['ThumbnailPhotoHash'] = $null

                                Mock -CommandName Get-TargetResource `
                                    -MockWith { $mockGetTargetResourcePresentPhotoResult }
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourcePhotoParameters } | Should -Not -Throw
                            }

                            It 'Should call the expected mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADUser `
                                    -ParameterFilter { $Replace.ContainsKey('ThumbnailPhoto') } `
                                    -Exactly -Times 1
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

                        Context 'When the current thumbnail photo is not the desired one' {
                            BeforeAll {
                                $setTargetResourcePhotoParameters = $setTargetResourcePresentParams.Clone()
                                $setTargetResourcePhotoParameters['ThumbnailPhoto'] = $mockThumbnailPhotoBase64
                                $mockGetTargetResourcePresentPhotoResult = $mockGetTargetResourcePresentResult.Clone()
                                $mockGetTargetResourcePresentPhotoResult['ThumbnailPhotoHash'] = $mockWrongThumbnailPhotoHash

                                Mock -CommandName Get-TargetResource `
                                    -MockWith { $mockGetTargetResourcePresentPhotoResult }
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourcePhotoParameters } | Should -Not -Throw
                            }

                            It 'Should call the expected mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADUser `
                                    -ParameterFilter { $Replace.ContainsKey('ThumbnailPhoto') } `
                                    -Exactly -Times 1
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

                        Context 'When there is a current thumbnail photo, but there should not be' {
                            BeforeAll {
                                $setTargetResourcePhotoParameters = $setTargetResourcePresentParams.Clone()
                                $setTargetResourcePhotoParameters['ThumbnailPhoto'] = ''
                                $mockGetTargetResourcePresentPhotoResult = $mockGetTargetResourcePresentResult.Clone()
                                $mockGetTargetResourcePresentPhotoResult['ThumbnailPhotoHash'] = $mockWrongThumbnailPhotoHash

                                Mock -CommandName Get-TargetResource `
                                    -MockWith { $mockGetTargetResourcePresentPhotoResult }
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourcePhotoParameters } | Should -Not -Throw
                            }

                            It 'Should call the expected mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADUser `
                                    -ParameterFilter { $Clear.Contains('thumbnailPhoto') } `
                                    -Exactly -Times 1
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
                }

                Context 'When the resource should be absent' {
                    It 'Should not throw' {
                        { Set-TargetResource @setTargetResourceAbsentParams } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
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
                    It 'Should not throw' {
                        { Set-TargetResource @setTargetResourcePresentParams } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -Exactly -Times 2
                        Assert-MockCalled -CommandName New-ADUser `
                            -ParameterFilter { $Name -eq $setTargetResourcePresentParams.UserName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Remove-ADUser `
                            -Exactly -Times 0
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
                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                            -Exactly -Times 0
                    }

                    Context 'When the "ChangePasswordAtLogon" parameter is true' {
                        BeforeAll {
                            $mockPreGetTargetResourceResult = $mockGetTargetResourceAbsentResult.Clone()
                            $mockPreGetTargetResourceResult['ChangePasswordAtLogon'] = $null

                            $mockPostGetTargetResourceResult = $mockGetTargetResourcePresentResult.Clone()
                            $mockPostGetTargetResourceResult['ChangePasswordAtLogon'] = $false

                            $script:mockNewADUserWasCalled = $false

                            $setTargetResourcePresentPasswordParams = $setTargetResourcePresentParams.Clone()
                            $setTargetResourcePresentPasswordParams['ChangePasswordAtLogon'] = $true

                            Mock -CommandName New-ADUser -MockWith {
                                $script:mockNewADUserWasCalled = $true
                            }
                            Mock -CommandName Get-TargetResource `
                                -MockWith {
                                if (-not $script:mockNewADUserWasCalled)
                                {
                                    $mockPreGetTargetResourceResult
                                }
                                else
                                {
                                    $mockPostGetTargetResourceResult
                                }
                            }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourcePresentPasswordParams } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName New-ADUser `
                                -ParameterFilter { $Name -eq $mockPreGetTargetResourceResult.UserName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $Username -eq $mockPreGetTargetResourceResult.UserName } `
                                -Exactly -Times 2
                            Assert-MockCalled -CommandName Set-ADUser `
                                -ParameterFilter { $ChangePasswordAtLogon -eq $true } `
                                -Exactly -Times 1
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
                                    -Exactly -Times 2
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
                        DesiredThumbnailPhoto     = $mockThumbnailPhotoBase64
                        CurrentThumbnailPhotoHash = $mockWrongThumbnailPhotoHash
                    }

                    $compareThumbnailPhotoResult = Compare-ThumbnailPhoto @compareThumbnailPhotoParameters
                }

                It 'Should return the correct result' {
                    $compareThumbnailPhotoResult | Should -BeOfType [System.Collections.Hashtable]
                    $compareThumbnailPhotoResult.CurrentThumbnailPhotoHash | Should -Be $mockWrongThumbnailPhotoHash
                    $compareThumbnailPhotoResult.DesiredThumbnailPhotoHash | Should -Be $mockThumbnailPhotoHash
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
