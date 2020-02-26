@{
    Parameters = @(
        @{
            Parameter          = 'CommonName'
            ADProperty         = 'cn'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'UserPrincipalName'
            ADProperty         = 'UserPrincipalName'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'DisplayName'
            ADProperty         = 'DisplayName'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Path'
            ADProperty         = 'distinguishedName'
            UseCmdletParameter = $true
            Array              = $false
        }
        @{
            Parameter          = 'GivenName'
            ADProperty         = 'GivenName'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Initials'
            ADProperty         = 'Initials'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Surname'
            ADProperty         = 'sn'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Description'
            ADProperty         = 'Description'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'StreetAddress'
            ADProperty         = 'StreetAddress'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'POBox'
            ADProperty         = 'PostOfficeBox'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'City'
            ADProperty         = 'l'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'State'
            ADProperty         = 'st'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'PostalCode'
            ADProperty         = 'PostalCode'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Country'
            ADProperty         = 'c'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Department'
            ADProperty         = 'Department'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Division'
            ADProperty         = 'Division'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Company'
            ADProperty         = 'Company'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Office'
            ADProperty         = 'physicalDeliveryOfficeName'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'JobTitle'
            ADProperty         = 'title'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'EmailAddress'
            ADProperty         = 'mail'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'EmployeeID'
            ADProperty         = 'EmployeeID'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'EmployeeNumber'
            ADProperty         = 'EmployeeNumber'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'HomeDirectory'
            ADProperty         = 'HomeDirectory'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'HomeDrive'
            ADProperty         = 'HomeDrive'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'HomePage'
            ADProperty         = 'wWWHomePage'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'ProfilePath'
            ADProperty         = 'ProfilePath'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'LogonScript'
            ADProperty         = 'scriptPath'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Notes'
            ADProperty         = 'info'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'OfficePhone'
            ADProperty         = 'telephoneNumber'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'MobilePhone'
            ADProperty         = 'mobile'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Fax'
            ADProperty         = 'facsimileTelephoneNumber'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Pager'
            ADProperty         = 'Pager'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'IPPhone'
            ADProperty         = 'IPPhone'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'HomePhone'
            ADProperty         = 'HomePhone'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Enabled'
            ADProperty         = 'Enabled'
            UseCmdletParameter = $true
            Array              = $false
        }
        @{
            Parameter          = 'Manager'
            ADProperty         = 'Manager'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'LogonWorkstations'
            ADProperty         = 'userWorkStations'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'Organization'
            ADProperty         = 'o'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'OtherName'
            ADProperty         = 'middleName'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'ThumbnailPhoto'
            ADProperty         = 'thumbnailPhoto'
            UseCmdletParameter = $false
            Array              = $false
        }
        @{
            Parameter          = 'PasswordNeverExpires'
            ADProperty         = 'PasswordNeverExpires'
            UseCmdletParameter = $true
            Array              = $false
        }
        @{
            Parameter          = 'CannotChangePassword'
            ADProperty         = 'CannotChangePassword'
            UseCmdletParameter = $true
            Array              = $false
        }
        @{
            Parameter          = 'ChangePasswordAtLogon'
            ADProperty         = 'pwdLastSet'
            UseCmdletParameter = $true
            Array              = $false
        }
        @{
            Parameter          = 'TrustedForDelegation'
            ADProperty         = 'TrustedForDelegation'
            UseCmdletParameter = $true
            Array              = $false
        }
        @{
            Parameter          = 'AccountNotDelegated'
            ADProperty         = 'AccountNotDelegated'
            UseCmdletParameter = $true
            Array              = $false
        }
        @{
            Parameter          = 'AllowReversiblePasswordEncryption'
            ADProperty         = 'AllowReversiblePasswordEncryption'
            UseCmdletParameter = $true
            Array              = $false
        }
        @{
            Parameter          = 'CompoundIdentitySupported'
            ADProperty         = 'CompoundIdentitySupported'
            UseCmdletParameter = $true
            Array              = $false
        }
        @{
            Parameter          = 'PasswordNotRequired'
            ADProperty         = 'PasswordNotRequired'
            UseCmdletParameter = $true
            Array              = $false
        }
        @{
            Parameter          = 'SmartcardLogonRequired'
            ADProperty         = 'SmartcardLogonRequired'
            UseCmdletParameter = $true
            Array              = $false
        }
        @{
            Parameter          = 'ServicePrincipalNames'
            ADProperty         = 'ServicePrincipalName'
            UseCmdletParameter = $false
            Array              = $true
        }
        @{
            Parameter          = 'ProxyAddresses'
            ADProperty         = 'ProxyAddresses'
            UseCmdletParameter = $false
            Array              = $true
        }
    )
}
