#region HEADER
# Integration Test Config Template Version: 1.2.0
#endregion

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    <#
        Allows reading the configuration data from a JSON file, for real testing
        scenarios outside of the CI.
    #>
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $currentDomain = Get-ADDomain
    $netBiosDomainName = $currentDomain.NetBIOSName
    $domainDistinguishedName = $currentDomain.DistinguishedName
    $dnsRoot = $currentDomain.DNSRoot

    $userName = 'DSCTestUser'
    $password = ConvertTo-SecureString -String 'P@ssW0rd1' -AsPlainText -Force
    $credential = [System.Management.Automation.PSCredential]::new('N/A', $password)
    $thumbnailPhoto1Path = Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\DSC_Logo_96.jpg'
    $thumbnailPhoto1Hash = 'E3253C13DFF396BE98D6144F0DFA6105'
    $thumbnailPhoto2Base64 = '/9j/4AAQSkZJRgABAQEAYABgAAD/4QBmRXhpZgAATU0AKgAAAAgABgESAAMAAAABAAEA'
    $thumbnailPhoto2Hash = 'B1482D60C348FCC604FAF648C4ABD189'
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName                = 'localhost'
                CertificateFile         = $env:DscPublicCertificatePath

                DomainDistinguishedName = $domainDistinguishedName
                NetBIOSName             = $netBiosDomainName

                Password                = $credential
                ThumbnailPhoto1Path     = $thumbnailPhoto1Path
                ThumbnailPhoto2Base64   = $thumbnailPhoto2Base64

                Tests                   = [Ordered]@{
                    CreateUser = @{
                        UserName                          = $userName
                        UserPrincipalName                 = "DscTestUser@$dnsRoot"
                        CommonName                        = 'DscTestUserCN'
                        DisplayName                       = 'Test User'
                        Initials                          = 'T'
                        Enabled                           = $true
                        GivenName                         = 'Test'
                        Description                       = 'This is the test user'
                        Surname                           = 'User'
                        StreetAddress                     = '1 Highway Road'
                        POBox                             = 'PO Box 1'
                        City                              = 'Cityville'
                        State                             = 'State'
                        ServicePrincipalNames             = 'spn/a', 'spn/b'
                        ThumbnailPhotoHash                = $thumbnailPhoto1Hash
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
                        Organization                      = 'Contoso'
                        OtherName                         = 'User1'
                        PasswordNeverExpires              = $false
                        CannotChangePassword              = $false
                        ChangePasswordAtLogon             = $false
                        TrustedForDelegation              = $false
                        AccountNotDelegated               = $true
                        AllowReversiblePasswordEncryption = $false
                        CompoundIdentitySupported         = $false
                        PasswordNotRequired               = $false
                        SmartcardLogonRequired            = $false
                        ProxyAddresses                    = 'testuser1@fabrikam.com', 'testuser2@fabrikam.com'
                        Ensure                            = 'Present'
                    }
                    ModifyUser = @{
                        UserName           = $userName
                        UserPrincipalName  = "DscTestUser2@$dnsRoot"
                        CommonName         = 'DscTestUser2'
                        Description        = 'Dsc Test User2'
                        ThumbnailPhotoHash = $thumbnailPhoto2Hash
                        Ensure             = 'Present'
                    }
                    RemoveUser = @{
                        UserName = $userName
                        Ensure   = 'Present'
                    }
                }
            }
        )
    }
}

<#
    .SYNOPSIS
        Create an AD user account.
#>
Configuration MSFT_ADUser_CreateUser_Config
{
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'

    $testName = 'CreateUser'

    node $AllNodes.NodeName
    {
        ADUser 'Integration_Test'
        {
            # Using distinguished name for DomainName - Regression test for issue #451.
            DomainName                        = $Node.DomainDistinguishedName
            UserName                          = $Node.Tests.$testName.UserName
            UserPrincipalName                 = $Node.Tests.$testName.UserPrincipalName
            CommonName                        = $Node.Tests.$testName.CommonName
            Description                       = $Node.Tests.$testName.Description
            Password                          = $Node.Password
            ThumbnailPhoto                    = $Node.ThumbnailPhoto1Path
            DisplayName                       = $Node.Tests.$testName.DisplayName
            Initials                          = $Node.Tests.$testName.Initials
            Enabled                           = $Node.Tests.$testName.Enabled
            GivenName                         = $Node.Tests.$testName.GivenName
            Surname                           = $Node.Tests.$testName.Surname
            StreetAddress                     = $Node.Tests.$testName.StreetAddress
            POBox                             = $Node.Tests.$testName.POBox
            City                              = $Node.Tests.$testName.City
            State                             = $Node.Tests.$testName.State
            ServicePrincipalNames             = $Node.Tests.$testName.ServicePrincipalNames
            PostalCode                        = $Node.Tests.$testName.PostalCode
            Country                           = $Node.Tests.$testName.Country
            Department                        = $Node.Tests.$testName.Department
            Division                          = $Node.Tests.$testName.Division
            Company                           = $Node.Tests.$testName.Company
            Office                            = $Node.Tests.$testName.Office
            JobTitle                          = $Node.Tests.$testName.JobTitle
            EmailAddress                      = $Node.Tests.$testName.EmailAddress
            EmployeeID                        = $Node.Tests.$testName.EmployeeID
            EmployeeNumber                    = $Node.Tests.$testName.EmployeeNumber
            HomeDirectory                     = $Node.Tests.$testName.HomeDirectory
            HomeDrive                         = $Node.Tests.$testName.HomeDrive
            HomePage                          = $Node.Tests.$testName.HomePage
            ProfilePath                       = $Node.Tests.$testName.Profilepath
            LogonScript                       = $Node.Tests.$testName.LogonScript
            Notes                             = $Node.Tests.$testName.Notes
            OfficePhone                       = $Node.Tests.$testName.OfficePhone
            MobilePhone                       = $Node.Tests.$testName.MobilePhone
            Fax                               = $Node.Tests.$testName.Fax
            Pager                             = $Node.Tests.$testName.Pager
            IPPhone                           = $Node.Tests.$testName.IPPhone
            HomePhone                         = $Node.Tests.$testName.HomePhone
            LogonWorkstations                 = $Node.Tests.$testName.LogonWorkstations
            Organization                      = $Node.Tests.$testName.Organization
            OtherName                         = $Node.Tests.$testName.OtherName
            PasswordNeverExpires              = $Node.Tests.$testName.PasswordNeverExpires
            CannotChangePassword              = $Node.Tests.$testName.CannotChangePassword
            ChangePasswordAtLogon             = $Node.Tests.$testName.ChangePasswordAtLogon
            TrustedForDelegation              = $Node.Tests.$testName.TrustedForDelegation
            AccountNotDelegated               = $Node.Tests.$testName.AccountNotDelegated
            AllowReversiblePasswordEncryption = $Node.Tests.$testName.AllowReversiblePasswordEncryption
            CompoundIdentitySupported         = $Node.Tests.$testName.CompoundIdentitySupported
            PasswordNotRequired               = $Node.Tests.$testName.PasswordNotRequired
            SmartcardLogonRequired            = $Node.Tests.$testName.SmartcardLogonRequired
            ProxyAddresses                    = $Node.Tests.$testName.ProxyAddresses
            Ensure                            = $Node.Tests.$testName.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Modify an AD user account.
#>
Configuration MSFT_ADUser_ModifyUser_Config
{
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'

    $testName = 'ModifyUser'

    node $AllNodes.NodeName
    {
        ADUser 'Integration_Test'
        {
            # Using distinguished name for DomainName - Regression test for issue #451.
            DomainName        = $Node.DomainDistinguishedName
            UserName          = $Node.Tests.$testName.UserName
            UserPrincipalName = $Node.Tests.$testName.UserPrincipalName
            CommonName        = $Node.Tests.$testName.CommonName
            Description       = $Node.Tests.$testName.Description
            Password          = $Node.Password
            ThumbnailPhoto    = $Node.ThumbnailPhoto2Base64
            Ensure            = $Node.Tests.$testName.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Remove an AD User account
#>
Configuration MSFT_ADUser_RemoveUser_Config
{
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'

    $testName = 'RemoveUser'

    node $AllNodes.NodeName
    {
        ADUser 'Integration_Test'
        {
            DomainName = $Node.DomainDistinguishedName
            UserName   = $Node.Tests.$testName.UserName
            Ensure     = $Node.Tests.$testName.Ensure
        }
    }
}
