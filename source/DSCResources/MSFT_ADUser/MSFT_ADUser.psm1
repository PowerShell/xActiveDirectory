[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUserNameAndPassWordParams', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "PasswordAuthentication")]
param ()

$resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$modulesFolderPath = Join-Path -Path $resourceModulePath -ChildPath 'Modules'

$aDCommonModulePath = Join-Path -Path $modulesFolderPath -ChildPath 'ActiveDirectoryDsc.Common'
Import-Module -Name $aDCommonModulePath

$dscResourceCommonModulePath = Join-Path -Path $modulesFolderPath -ChildPath 'DscResource.Common'
Import-Module -Name $dscResourceCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

$script:dscResourceName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

# Import a property map that maps the DSC resource parameters to the Active Directory user attributes.
$adPropertyMapPath = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).PropertyMap.psd1"
$adPropertyMap = (Import-PowerShellDataFile -Path $adPropertyMapPath).Parameters

<#
    .SYNOPSIS
        Returns the current state of the Active Directory User

    .PARAMETER DomainName
        Name of the domain where the user account is located (only used if password is managed).

    .PARAMETER UserName
        Specifies the account name of the user. (You can identify a user by its distinguished
    name (DN), GUID, security identifier (SID) or Security Accounts Manager (SAM) account name.)

    .PARAMETER DomainController
        Specifies the Active Directory Domain Services instance to use to perform the task.

    .PARAMETER Credential
        Specifies the user account credentials to use to perform this task.

    .NOTES
        Used Functions:
            Name                          | Module
            ------------------------------|--------------------------
            Get-ADUser                    | ActiveDirectory
            Assert-Module                 | DscResource.Common
            New-InvalidOperationException | DscResource.Common
            Get-ADCommonParameters        | ActiveDirectoryDsc.Common
            Get-ADObjectParentDN          | ActiveDirectoryDsc.Common
            Get-MD5HashString             | MSFT_ADUser
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    Assert-Module -ModuleName 'ActiveDirectory'

    $adCommonParameters = Get-ADCommonParameters @PSBoundParameters

    Write-Verbose -Message ($script:localizedData.RetrievingADUser -f $UserName, $DomainName)

    try
    {
        $adUser = Get-ADUser @adCommonParameters -Properties $adPropertyMap.ADProperty
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        Write-Verbose -Message ($script:localizedData.ADUserNotPresent -f $UserName, $DomainName)

        $adUser = $null
    }
    catch
    {
        $errorMessage = $script:localizedData.RetrievingADUserError -f $UserName, $DomainName
        New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
    }

    if ($adUser)
    {
        Write-Verbose -Message ($script:localizedData.ADUserIsPresent -f $UserName, $DomainName)

        $targetResource = @{
            DistinguishedName = $adUser.DistinguishedName # Read-only property
            DomainController  = $DomainController
            DomainName        = $DomainName
            Ensure            = 'Present'
            Password          = $null
            UserName          = $UserName
        }

        # Retrieve each property from the ADPropertyMap and add to the hashtable
        foreach ($property in $adPropertyMap)
        {
            $parameter = $property.Parameter
            if ($parameter -eq 'Path')
            {
                # The path returned is not the parent container
                if (-not [System.String]::IsNullOrEmpty($adUser.DistinguishedName))
                {
                    $targetResource[$parameter] = Get-ADObjectParentDN -DN $adUser.DistinguishedName
                }
            }
            elseif ($parameter -eq 'ChangePasswordAtLogon')
            {
                if ($adUser.pwdlastset -eq 0)
                {
                    $targetResource[$parameter] = $true
                }
                else
                {
                    $targetResource[$parameter] = $false
                }
            }
            elseif ($parameter -eq 'ThumbnailPhoto')
            {
                if ([System.String]::IsNullOrEmpty($adUser.$parameter))
                {
                    $targetResource[$parameter] = $null
                    $targetResource['ThumbnailPhotoHash'] = $null
                }
                else
                {
                    $targetResource[$parameter] = [System.Convert]::ToBase64String($adUser.$parameter)
                    $targetResource['ThumbnailPhotoHash'] = Get-MD5HashString -Bytes $adUser.$parameter
                }
            }
            else
            {
                $aDProperty = $property.ADProperty
                if ($property.Array)
                {
                    $targetResource[$parameter] = [System.String[]] $adUser.$ADProperty
                }
                else
                {
                    $targetResource[$parameter] = $adUser.$aDProperty
                }
            }
        }
    }
    else
    {
        $targetResource = @{
            DistinguishedName = $null
            DomainController  = $DomainController
            DomainName        = $DomainName
            Ensure            = 'Absent'
            Password          = $null
            UserName          = $UserName
        }

        foreach ($property in $adPropertyMap)
        {
            $targetResource[$property.Parameter] = $null
        }
    }

    return $targetResource
} # end function Get-TargetResource

<#
    .SYNOPSIS
        Tests the state of the Active Directory user account.

    .PARAMETER DomainName
        Name of the domain where the user account is located (only used if password is managed).

    .PARAMETER UserName
        Specifies the account name of the user. (You can identify a user by its distinguished
    name (DN), GUID, security identifier (SID), or Security Accounts Manager (SAM) account name.)

    .PARAMETER Password
        Specifies a new password value for the account.

    .PARAMETER Ensure
        Specifies whether the user account should be present or absent. Default value is 'Present'.

    .PARAMETER CommonName
        Specifies the common name assigned to the user account (ldapDisplayName 'cn'). If not specified the default
        value will be the same value provided in parameter UserName.

    .PARAMETER UserPrincipalName
        Specifies the User Principal Name (UPN) assigned to the user account (ldapDisplayName 'userPrincipalName').

    .PARAMETER DisplayName
        Specifies the display name of the object (ldapDisplayName 'displayName').

    .PARAMETER SamAccountName
        Specifies the SamAccountName of the object (ldapDisplayName 'SamAccountName').

    .PARAMETER Path
        Specifies the X.500 path of the Organizational Unit (OU) or container where the new object is created.

    .PARAMETER GivenName
        Specifies the user's given name (ldapDisplayName 'givenName').

    .PARAMETER Initials
        Specifies the initials that represent part of a user's name (ldapDisplayName 'initials').

    .PARAMETER Surname
        Specifies the user's last name or surname (ldapDisplayName 'sn').

    .PARAMETER Description
        Specifies a description of the object (ldapDisplayName 'description').

    .PARAMETER StreetAddress
        Specifies the user's street address (ldapDisplayName 'streetAddress').

    .PARAMETER POBox
        Specifies the user's post office box number (ldapDisplayName 'postOfficeBox').

    .PARAMETER City
        Specifies the user's town or city (ldapDisplayName 'l').

    .PARAMETER State
        Specifies the user's or Organizational Unit's state or province (ldapDisplayName 'st').

    .PARAMETER PostalCode
        Specifies the user's postal code or zip code (ldapDisplayName 'postalCode').

    .PARAMETER Country
        Specifies the country or region code for the user's language of choice (ldapDisplayName 'c').

    .PARAMETER Department
        Specifies the user's department (ldapDisplayName 'department').

    .PARAMETER Division
        Specifies the user's division (ldapDisplayName 'division').

    .PARAMETER Company
        Specifies the user's company (ldapDisplayName 'company').

    .PARAMETER Office
        Specifies the location of the user's office or place of business (ldapDisplayName 'physicalDeliveryOfficeName').

    .PARAMETER JobTitle
        Specifies the user's title (ldapDisplayName 'title').

    .PARAMETER EmailAddress
        Specifies the user's e-mail address (ldapDisplayName 'mail').

    .PARAMETER EmployeeID
        Specifies the user's employee ID (ldapDisplayName 'employeeID').

    .PARAMETER EmployeeNumber
        Specifies the user's employee number (ldapDisplayName 'employeeNumber').

    .PARAMETER HomeDirectory
        Specifies a user's home directory path (ldapDisplayName 'homeDirectory').

    .PARAMETER HomeDrive
        Specifies a drive that is associated with the UNC path defined by the HomeDirectory property (ldapDisplayName
        'homeDrive').

    .PARAMETER HomePage
        Specifies the URL of the home page of the object (ldapDisplayName 'wWWHomePage').

    .PARAMETER ProfilePath
        Specifies a path to the user's profile (ldapDisplayName 'profilePath').

    .PARAMETER LogonScript
        Specifies a path to the user's log on script (ldapDisplayName 'scriptPath').

    .PARAMETER Notes
        Specifies the notes attached to the user's account (ldapDisplayName 'info').

    .PARAMETER OfficePhone
        Specifies the user's office telephone number (ldapDisplayName 'telephoneNumber').

    .PARAMETER MobilePhone
        Specifies the user's mobile phone number (ldapDisplayName 'mobile').

    .PARAMETER Fax
        Specifies the user's fax phone number (ldapDisplayName 'facsimileTelephoneNumber').

    .PARAMETER HomePhone
        Specifies the user's home telephone number (ldapDisplayName 'homePhone').

    .PARAMETER Pager
        Specifies the user's pager number (ldapDisplayName 'pager').

    .PARAMETER IPPhone
        Specifies the user's IP telephony phone number (ldapDisplayName 'ipPhone').

    .PARAMETER Manager
        Specifies the user's manager specified as a Distinguished Name (ldapDisplayName 'manager').

    .PARAMETER LogonWorkstations
        Specifies the computers that the user can access. To specify more than one computer, create a single
        comma-separated list. You can identify a computer by using the Security Account Manager (SAM) account name
        (SamAccountName) or the DNS host name of the computer. The SAM account name is the same as the NetBIOS name of
        the computer (ldapDisplayName 'userWorkStations').

    .PARAMETER Organization
        Specifies the user's organization. This parameter sets the Organization property of a user object
        (ldapDisplayName 'o').

    .PARAMETER OtherName
        Specifies a name in addition to a user's given name and surname, such as the user's middle name. This parameter
        sets the OtherName property of a user object (ldapDisplayName 'middleName').

    .PARAMETER Enabled
        Specifies if the account is enabled. Default value is $true.

    .PARAMETER CannotChangePassword
        Specifies whether the account password can be changed.

    .PARAMETER ChangePasswordAtLogon
        Specifies whether the account password must be changed during the next logon attempt. This will only be enabled
        when the user is initially created. This parameter cannot be set to $true if the parameter PasswordNeverExpires
        is also set to $true.

    .PARAMETER PasswordNeverExpires
        Specifies whether the password of an account can expire.

    .PARAMETER TrustedForDelegation
        Specifies whether an account is trusted for Kerberos delegation. Default value is $false.

    .PARAMETER AccountNotDelegated
        Indicates whether the security context of the user is delegated to a service.  When this parameter is set to
        true, the security context of the account is not delegated to a service even when the service account is set as
        trusted for Kerberos delegation. This parameter sets the AccountNotDelegated property for an Active Directory
        account. This parameter also sets the ADS_UF_NOT_DELEGATED flag of the Active Directory User Account Control
        (UAC) attribute.

    .PARAMETER AllowReversiblePasswordEncryption
        Indicates whether reversible password encryption is allowed for the account. This parameter sets the
        AllowReversiblePasswordEncryption property of the account. This parameter also sets the
        ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED flag of the Active Directory User Account Control (UAC) attribute.

    .PARAMETER CompoundIdentitySupported
        Specifies whether an account supports Kerberos service tickets which includes the authorization data for the
        user's device. This value sets the compound identity supported flag of the Active Directory
        msDS-SupportedEncryptionTypes attribute.

    .PARAMETER PasswordNotRequired
        Specifies whether the account requires a password. A password is not required for a new account. This parameter
        sets the PasswordNotRequired property of an account object.

    .PARAMETER SmartcardLogonRequired
        Specifies whether a smart card is required to logon. This parameter sets the SmartCardLoginRequired property
        for a user object. This parameter also sets the ADS_UF_SMARTCARD_REQUIRED flag of the Active Directory
        User Account Control attribute.

    .PARAMETER DomainController
        Specifies the Active Directory Domain Services instance to use to perform the task.

    .PARAMETER Credential
        Specifies the user account credentials to use to perform this task.

    .PARAMETER PasswordAuthentication
        Specifies the authentication context type used when testing passwords. Default value is 'Default'.

    .PARAMETER PasswordNeverResets
        Specifies whether existing user's password should be reset. Default value is $false.

    .PARAMETER RestoreFromRecycleBin
        Try to restore the user object from the recycle bin before creating a new one.

    .PARAMETER ServicePrincipalNames
        Specifies the service principal names for the user account.

    .PARAMETER ProxyAddresses
        Specifies the proxy addresses for the user account.

    .PARAMETER ThumbnailPhoto
        Specifies the thumbnail photo to be used for the user object. Can be set either to a path pointing to a
        .jpg-file, or to a Base64-encoded jpeg image. If set to an empty string ('') the current thumbnail photo will
        be removed. The property ThumbnailPhoto will always return the image as a Base64-encoded string even if the
        configuration specified a file path.

    .NOTES
        Used Functions:
            Name                   | Module
            -----------------------|--------------------------
            Assert-Parameters      | MSFT_ADUser
            Test-Password          | ActiveDirectoryDsc.Common
            Compare-ThumbnailPhoto | MSFT_ADUser
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Password,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $CommonName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $UserPrincipalName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $SamAccountName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $GivenName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Initials,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Surname,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $StreetAddress,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $POBox,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $City,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $State,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $PostalCode,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Country,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Department,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Division,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Company,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Office,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $JobTitle,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $EmailAddress,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $EmployeeID,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $EmployeeNumber,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $HomeDirectory,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $HomeDrive,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $HomePage,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $ProfilePath,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $LogonScript,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Notes,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $OfficePhone,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $MobilePhone,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Fax,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $HomePhone,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Pager,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $IPPhone,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Manager,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $LogonWorkstations,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Organization,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $OtherName,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $CannotChangePassword,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $ChangePasswordAtLogon,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $PasswordNeverExpires,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $TrustedForDelegation,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $AccountNotDelegated,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $AllowReversiblePasswordEncryption,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $CompoundIdentitySupported,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $PasswordNotRequired,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $SmartcardLogonRequired,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateSet('Default', 'Negotiate')]
        [System.String]
        $PasswordAuthentication = 'Default',

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $PasswordNeverResets = $false,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $RestoreFromRecycleBin,

        [Parameter()]
        [ValidateNotNull()]
        [System.String[]]
        $ServicePrincipalNames,

        [Parameter()]
        [ValidateNotNull()]
        [System.String[]]
        $ProxyAddresses,

        [Parameter()]
        [System.String]
        $ThumbnailPhoto
    )

    <#
        This is a workaround to set the CommonName default to UserName to make the resource able to enter debug mode.
        For more information see issue https://github.com/PowerShell/ActiveDirectoryDsc/issues/427.
    #>
    if (-not $PSBoundParameters.ContainsKey('CommonName'))
    {
        $CommonName = $UserName
    }
    Assert-Parameters @PSBoundParameters

    $parameters = @{} + $PSBoundParameters
    $parameters.Remove('DomainName')
    $parameters.Remove('UserName')
    $parameters.Remove('RestoreFromRecycleBin')
    $parameters.Remove('PasswordNeverResets')
    $parameters.Remove('PasswordAuthentication')
    $parameters.Remove('DomainController')
    $parameters.Remove('Credential')
    $parameters.Remove('Ensure')
    $parameters.Remove('Verbose')
    $parameters.Remove('Debug')

    # Add parameters with default values as they may not be explicitly passed
    $parameters['Enabled'] = $Enabled

    $getParameters = @{
        DomainName = $DomainName
        UserName   = $UserName
    }

    if ($PSBoundParameters.ContainsKey('DomainController'))
    {
        $getParameters['DomainController'] = $DomainController
    }

    if ($PSBoundParameters.ContainsKey('Credential'))
    {
        $getParameters['Credential'] = $Credential
    }

    $targetResource = Get-TargetResource @getParameters

    $inDesiredState = $true

    if ($targetResource.Ensure -eq 'Present')
    {
        if ($Ensure -eq 'Present')
        {
            foreach ($parameter in $parameters.Keys)
            {
                if ($parameter -eq 'Password')
                {
                    # Only process the Password parameter if the PasswordNeverResets parameter is false
                    if ($PasswordNeverResets -eq $false)
                    {
                        $testPasswordParams = @{
                            Username               = $UserName
                            Password               = $Password
                            DomainName             = $DomainName
                            PasswordAuthentication = $PasswordAuthentication
                        }

                        if ($Credential)
                        {
                            $testPasswordParams['Credential'] = $Credential
                        }

                        if (-not (Test-Password @testPasswordParams))
                        {
                            Write-Verbose -Message ($script:localizedData.ADUserNotDesiredPropertyState -f
                                'Password', '<Password>', '<Password>')

                            $inDesiredState = $false
                        }
                    }
                }
                elseif ($parameter -eq 'ChangePasswordAtLogon' -and $parameters.$parameter -eq $true)
                {
                    # Only process the 'ChangePasswordAtLogon = $true' parameter during new user creation
                    continue
                }
                elseif ($parameter -eq 'ThumbnailPhoto')
                {
                    <#
                        Compare thumbnail hash, if they are the same the function
                        Compare-ThumbnailPhoto returns $null if they are the same.
                    #>
                    $compareThumbnailPhotoResult = Compare-ThumbnailPhoto -DesiredThumbnailPhoto $ThumbnailPhoto `
                        -CurrentThumbnailPhotoHash $targetResource.ThumbnailPhotoHash

                    if ($compareThumbnailPhotoResult)
                    {
                        Write-Verbose -Message ($script:localizedData.ADUserNotDesiredPropertyState -f
                            $parameter, ('Hash: ' + $compareThumbnailPhotoResult.DesiredThumbnailPhotoHash),
                            ('Hash: ' + $compareThumbnailPhotoResult.CurrentThumbnailPhotoHash))

                        $inDesiredState = $false
                    }
                }

                # This check is required to be able to explicitly remove values with an empty string, if required
                elseif (([System.String]::IsNullOrEmpty($parameters.$parameter)) -and `
                    ([System.String]::IsNullOrEmpty($targetResource.$parameter)))
                {
                    <#
                        Both values are null/empty and therefore we are compliant
                        Must catch this scenario separately, as Compare-Object can't compare Null objects
                    #>
                    continue
                }
                elseif (($null -ne $parameters.$parameter -and $null -eq $targetResource.$parameter) -or
                    ($null -eq $parameters.$parameter -and $null -ne $targetResource.$parameter) -or
                    (Compare-Object -ReferenceObject $parameters.$parameter `
                            -DifferenceObject $targetResource.$parameter))
                {
                    Write-Verbose -Message ($script:localizedData.ADUserNotDesiredPropertyState -f
                        $parameter, ($parameters.$parameter -join '; '), ($targetResource.$parameter -join '; '))

                    $inDesiredState = $false
                }
            } #end foreach PSBoundParameter

            if ($inDesiredState)
            {
                # Resource is in desired state
                Write-Verbose -Message ($script:localizedData.ADUserInDesiredState -f $UserName)
            }
            else
            {
                # Resource is not in the desired state
                Write-Verbose -Message ($script:localizedData.ADUserNotInDesiredState -f $UserName)
            }
        }
        else
        {
            # Resource should be Absent
            Write-Verbose -Message ($script:localizedData.ADUserIsPresentButShouldBeAbsent -f $UserName)

            $inDesiredState = $false
        }
    }
    else
    {
        # Resource is Absent
        if ($Ensure -eq 'Present')
        {
            # Resource should be Present
            Write-Verbose -Message ($script:localizedData.ADUserIsAbsentButShouldBePresent -f $UserName)

            $inDesiredState = $false
        }
        else
        {
            # Resource should be Absent
            Write-Verbose ($script:localizedData.ADUserInDesiredState -f $UserName)

            $inDesiredState = $true
        }
    }

    return $inDesiredState
} # end function Test-TargetResource

<#
    .SYNOPSIS
        Sets the properties of the Active Directory user account.

    .PARAMETER DomainName
        Name of the domain where the user account is located (only used if password is managed).

    .PARAMETER UserName
        Specifies the account name of the user. (You can identify a user by its distinguished
    name (DN), GUID, security identifier (SID), or Security Accounts Manager (SAM) account name.)

    .PARAMETER Password
        Specifies a new password value for the account.

    .PARAMETER Ensure
        Specifies whether the user account should be present or absent. Default value is 'Present'.

    .PARAMETER CommonName
        Specifies the common name assigned to the user account (ldapDisplayName 'cn'). If not specified the default
        value will be the same value provided in parameter UserName.

    .PARAMETER UserPrincipalName
        Specifies the User Principal Name (UPN) assigned to the user account (ldapDisplayName 'userPrincipalName').

    .PARAMETER DisplayName
        Specifies the display name of the object (ldapDisplayName 'displayName').

    .PARAMETER SamAccountName
        Specifies the SamAccountName of the object (ldapDisplayName 'SamAccountName').

    .PARAMETER Path
        Specifies the X.500 path of the Organizational Unit (OU) or container where the new object is created.

    .PARAMETER GivenName
        Specifies the user's given name (ldapDisplayName 'givenName').

    .PARAMETER Initials
        Specifies the initials that represent part of a user's name (ldapDisplayName 'initials').

    .PARAMETER Surname
        Specifies the user's last name or surname (ldapDisplayName 'sn').

    .PARAMETER Description
        Specifies a description of the object (ldapDisplayName 'description').

    .PARAMETER StreetAddress
        Specifies the user's street address (ldapDisplayName 'streetAddress').

    .PARAMETER POBox
        Specifies the user's post office box number (ldapDisplayName 'postOfficeBox').

    .PARAMETER City
        Specifies the user's town or city (ldapDisplayName 'l').

    .PARAMETER State
        Specifies the user's or Organizational Unit's state or province (ldapDisplayName 'st').

    .PARAMETER PostalCode
        Specifies the user's postal code or zip code (ldapDisplayName 'postalCode').

    .PARAMETER Country
        Specifies the country or region code for the user's language of choice (ldapDisplayName 'c').

    .PARAMETER Department
        Specifies the user's department (ldapDisplayName 'department').

    .PARAMETER Division
        Specifies the user's division (ldapDisplayName 'division').

    .PARAMETER Company
        Specifies the user's company (ldapDisplayName 'company').

    .PARAMETER Office
        Specifies the location of the user's office or place of business (ldapDisplayName 'physicalDeliveryOfficeName').

    .PARAMETER JobTitle
        Specifies the user's title (ldapDisplayName 'title').

    .PARAMETER EmailAddress
        Specifies the user's e-mail address (ldapDisplayName 'mail').

    .PARAMETER EmployeeID
        Specifies the user's employee ID (ldapDisplayName 'employeeID').

    .PARAMETER EmployeeNumber
        Specifies the user's employee number (ldapDisplayName 'employeeNumber').

    .PARAMETER HomeDirectory
        Specifies a user's home directory path (ldapDisplayName 'homeDirectory').

    .PARAMETER HomeDrive
        Specifies a drive that is associated with the UNC path defined by the HomeDirectory property (ldapDisplayName
        'homeDrive').

    .PARAMETER HomePage
        Specifies the URL of the home page of the object (ldapDisplayName 'wWWHomePage').

    .PARAMETER ProfilePath
        Specifies a path to the user's profile (ldapDisplayName 'profilePath').

    .PARAMETER LogonScript
        Specifies a path to the user's log on script (ldapDisplayName 'scriptPath').

    .PARAMETER Notes
        Specifies the notes attached to the user's account (ldapDisplayName 'info').

    .PARAMETER OfficePhone
        Specifies the user's office telephone number (ldapDisplayName 'telephoneNumber').

    .PARAMETER MobilePhone
        Specifies the user's mobile phone number (ldapDisplayName 'mobile').

    .PARAMETER Fax
        Specifies the user's fax phone number (ldapDisplayName 'facsimileTelephoneNumber').

    .PARAMETER HomePhone
        Specifies the user's home telephone number (ldapDisplayName 'homePhone').

    .PARAMETER Pager
        Specifies the user's pager number (ldapDisplayName 'pager').

    .PARAMETER IPPhone
        Specifies the user's IP telephony phone number (ldapDisplayName 'ipPhone').

    .PARAMETER Manager
        Specifies the user's manager specified as a Distinguished Name (ldapDisplayName 'manager').

    .PARAMETER LogonWorkstations
        Specifies the computers that the user can access. To specify more than one computer, create a single
        comma-separated list. You can identify a computer by using the Security Account Manager (SAM) account name
        (SamAccountName) or the DNS host name of the computer. The SAM account name is the same as the NetBIOS name of
        the computer (ldapDisplayName 'userWorkStations').

    .PARAMETER Organization
        Specifies the user's organization. This parameter sets the Organization property of a user object
        (ldapDisplayName 'o').

    .PARAMETER OtherName
        Specifies a name in addition to a user's given name and surname, such as the user's middle name. This parameter
        sets the OtherName property of a user object (ldapDisplayName 'middleName').

    .PARAMETER Enabled
        Specifies if the account is enabled. Default value is $true.

    .PARAMETER CannotChangePassword
        Specifies whether the account password can be changed.

    .PARAMETER ChangePasswordAtLogon
        Specifies whether the account password must be changed during the next logon attempt. This will only be enabled
        when the user is initially created. This parameter cannot be set to $true if the parameter PasswordNeverExpires
        is also set to $true.

    .PARAMETER PasswordNeverExpires
        Specifies whether the password of an account can expire.

    .PARAMETER TrustedForDelegation
        Specifies whether an account is trusted for Kerberos delegation. Default value is $false.

    .PARAMETER AccountNotDelegated
        Indicates whether the security context of the user is delegated to a service.  When this parameter is set to
        true, the security context of the account is not delegated to a service even when the service account is set as
        trusted for Kerberos delegation. This parameter sets the AccountNotDelegated property for an Active Directory
        account. This parameter also sets the ADS_UF_NOT_DELEGATED flag of the Active Directory User Account Control
        (UAC) attribute.

    .PARAMETER AllowReversiblePasswordEncryption
        Indicates whether reversible password encryption is allowed for the account. This parameter sets the
        AllowReversiblePasswordEncryption property of the account. This parameter also sets the
        ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED flag of the Active Directory User Account Control (UAC) attribute.

    .PARAMETER CompoundIdentitySupported
        Specifies whether an account supports Kerberos service tickets which includes the authorization data for the
        user's device. This value sets the compound identity supported flag of the Active Directory
        msDS-SupportedEncryptionTypes attribute.

    .PARAMETER PasswordNotRequired
        Specifies whether the account requires a password. A password is not required for a new account. This parameter
        sets the PasswordNotRequired property of an account object.

    .PARAMETER SmartcardLogonRequired
        Specifies whether a smart card is required to logon. This parameter sets the SmartCardLoginRequired property
        for a user object. This parameter also sets the ADS_UF_SMARTCARD_REQUIRED flag of the Active Directory
        User Account Control attribute.

    .PARAMETER DomainController
        Specifies the Active Directory Domain Services instance to use to perform the task.

    .PARAMETER Credential
        Specifies the user account credentials to use to perform this task.

    .PARAMETER PasswordAuthentication
        Specifies the authentication context type used when testing passwords. Default value is 'Default'.

    .PARAMETER PasswordNeverResets
        Specifies whether existing user's password should be reset. Default value is $false.

    .PARAMETER RestoreFromRecycleBin
        Try to restore the user object from the recycle bin before creating a new one.

    .PARAMETER ServicePrincipalNames
        Specifies the service principal names for the user account.

    .PARAMETER ProxyAddresses
        Specifies the proxy addresses for the user account.

    .PARAMETER ThumbnailPhoto
        Specifies the thumbnail photo to be used for the user object. Can be set either to a path pointing to a
        .jpg-file, or to a Base64-encoded jpeg image. If set to an empty string ('') the current thumbnail photo will
        be removed. The property ThumbnailPhoto will always return the image as a Base64-encoded string even if the
        configuration specified a file path.

    .NOTES
        Used Functions:
            Name                   | Module
            -----------------------|--------------------------
            Assert-Parameters      | MSFT_ADUser
            Compare-ThumbnailPhoto | MSFT_ADUser
            Get-ThumbnailByteArray | MSFT_ADUser
            Get-MD5HashString      | MSFT_ADUser
            Get-ADCommonParameters | ActiveDirectoryDsc.Common
            Restore-ADCommonObject | ActiveDirectoryDsc.Common
            Test-Password          | ActiveDirectoryDsc.Common
            New-ADUser             | ActiveDirectory
            Set-ADAccountPassword  | ActiveDirectory
            Set-ADUser             | ActiveDirectory
            Move-ADObject          | ActiveDirectory
            Rename-ADObject        | ActiveDirectory
            Remove-ADUser          | ActiveDirectory
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Password,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $CommonName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $UserPrincipalName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $SamAccountName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $GivenName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Initials,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Surname,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $StreetAddress,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $POBox,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $City,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $State,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $PostalCode,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Country,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Department,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Division,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Company,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Office,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $JobTitle,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $EmailAddress,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $EmployeeID,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $EmployeeNumber,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $HomeDirectory,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $HomeDrive,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $HomePage,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $ProfilePath,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $LogonScript,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Notes,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $OfficePhone,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $MobilePhone,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Fax,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $HomePhone,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Pager,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $IPPhone,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Manager,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $LogonWorkstations,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $Organization,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $OtherName,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $CannotChangePassword,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $ChangePasswordAtLogon,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $PasswordNeverExpires,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $TrustedForDelegation,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $AccountNotDelegated,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $AllowReversiblePasswordEncryption,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $CompoundIdentitySupported,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $PasswordNotRequired,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $SmartcardLogonRequired,

        [Parameter()]
        [ValidateNotNull()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateSet('Default', 'Negotiate')]
        [System.String]
        $PasswordAuthentication = 'Default',

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $PasswordNeverResets = $false,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $RestoreFromRecycleBin,

        [Parameter()]
        [ValidateNotNull()]
        [System.String[]]
        $ServicePrincipalNames,

        [Parameter()]
        [ValidateNotNull()]
        [System.String[]]
        $ProxyAddresses,

        [Parameter()]
        [System.String]
        $ThumbnailPhoto
    )

    <#
        This is a workaround to set the CommonName default to UserName to make the resource able to enter debug mode.
        For more information see issue https://github.com/PowerShell/ActiveDirectoryDsc/issues/427.
    #>
    if (-not $PSBoundParameters.ContainsKey('CommonName'))
    {
        $CommonName = $UserName
    }

    Assert-Parameters @PSBoundParameters

    $parameters = @{} + $PSBoundParameters
    $parameters.Remove('DomainName')
    $parameters.Remove('UserName')
    $parameters.Remove('PasswordNeverResets')
    $parameters.Remove('PasswordAuthentication')
    $parameters.Remove('RestoreFromRecycleBin')
    $parameters.Remove('DomainController')
    $parameters.Remove('Credential')
    $parameters.Remove('Ensure')
    $parameters.Remove('Verbose')
    $parameters.Remove('Debug')

    # Add parameters with default values as they may not be explicitly passed
    $parameters['Enabled'] = $Enabled

    $getParameters = @{
        DomainName = $DomainName
        UserName   = $UserName
    }

    if ($PSBoundParameters.ContainsKey('DomainController'))
    {
        $getParameters['DomainController'] = $DomainController
    }

    if ($PSBoundParameters.ContainsKey('Credential'))
    {
        $getParameters['Credential'] = $Credential
    }

    $targetResource = Get-TargetResource @getParameters

    $restorationSuccessful = $false

    if ($Ensure -eq 'Present')
    {
        # Resource should be Present
        if ($targetResource.Ensure -eq 'Absent')
        {
            # Resource is Absent
            if ($RestoreFromRecycleBin)
            {
                # Try to restore account if it exists
                Write-Verbose -Message ($script:localizedData.RestoringUser -f $UserName)

                $restoreParams = Get-ADCommonParameters @PSBoundParameters
                $restorationSuccessful = Restore-ADCommonObject @restoreParams -ObjectClass User -ErrorAction Stop
            }

            if (-not $RestoreFromRecycleBin -or ($RestoreFromRecycleBin -and -not $restorationSuccessful))
            {
                # User does not exist and needs creating
                $newADUserParams = Get-ADCommonParameters @PSBoundParameters -UseNameParameter

                $otherUserAttributes = @{}
                $updateCnRequired = $false

                foreach ($parameter in $parameters.keys)
                {
                    $adProperty = $adPropertyMap |
                        Where-Object -FilterScript { $_.Parameter -eq $parameter }

                    if ($parameter -eq 'Password')
                    {
                        $newADUserParams['AccountPassword'] = $Password.Password
                    }
                    elseif ($parameter -eq 'CommonName')
                    {
                        if ($CommonName -ne $UserName)
                        {
                            # Need to set different CN using Rename after user creation
                            $updateCnRequired = $true
                        }
                    }
                    elseif ($parameter -eq 'ThumbnailPhoto')
                    {
                        [System.Byte[]] $thumbnailPhotoBytes = Get-ThumbnailByteArray `
                            -ThumbnailPhoto $ThumbnailPhoto -Verbose:$false

                        $otherUserAttributes[$adProperty.ADProperty] = $thumbnailPhotoBytes
                    }
                    else
                    {
                        if ($adProperty.UseCmdletParameter -eq $true)
                        {
                            # We need to pass the parameter explicitly to New-ADUser, not via -OtherAttributes
                            $newADUserParams[$adProperty.Parameter] = $parameters.$parameter
                        }
                        else
                        {
                            $otherUserAttributes[$adProperty.ADProperty] = $parameters.$parameter
                        }
                    }
                }

                if ($otherUserAttributes.Keys.Count -gt 0)
                {
                    $newADUserParams['OtherAttributes'] = $otherUserAttributes
                }

                Write-Verbose -Message ($script:localizedData.AddingADUser -f $UserName, $DomainName)

                Write-Debug -Message ('New-ADUser Parameters:' + ($newADUserParams | Out-String))

                $newADUser = New-ADUser @newADUserParams -Name $UserName -Passthru

                if ($updateCnRequired)
                {
                    $renameAdObjectParameters = Get-ADCommonParameters @PSBoundParameters

                    # Using the SamAccountName for identity with Rename-ADObject does not work, use the DN instead
                    $renameAdObjectParameters['Identity'] = $newADUser.DistinguishedName

                    Rename-ADObject @renameAdObjectParameters -NewName $CommonName
                }
            }
        }
        if ($targetResource.Ensure -eq 'Present' -or $restorationSuccessful)
        {
            # Resource is Present or has just been restored from the recycle bin
            $setADUserParams = @{}
            $replaceUserProperties = @{}
            $clearUserProperties = @()
            $moveUserRequired = $false
            $updateCnRequired = $false

            foreach ($parameter in $parameters.Keys)
            {
                # Find the associated AD property
                $adProperty = $adPropertyMap |
                    Where-Object -FilterScript { $_.Parameter -eq $parameter }

                if ($parameter -eq 'Path')
                {
                    if ($parameters.Path -ne $targetResource.Path)
                    {
                        # Move user after any property changes
                        $moveUserRequired = $true
                    }
                }
                elseif ($parameter -eq 'CommonName')
                {
                    if ($parameters.CommonName -ne $targetResource.CommonName)
                    {
                        # Update CN after any property changes
                        $updateCnRequired = $true
                    }
                }
                elseif ($parameter -eq 'Password')
                {
                    # Only process the Password parameter if the PasswordNeverResets parameter is false
                    if ($PasswordNeverResets -eq $false)
                    {
                        $adCommonParameters = Get-ADCommonParameters @PSBoundParameters
                        $testPasswordParams = @{
                            Username               = $UserName
                            Password               = $Password
                            DomainName             = $DomainName
                            PasswordAuthentication = $PasswordAuthentication
                        }

                        if ($Credential)
                        {
                            $testPasswordParams['Credential'] = $Credential
                        }
                        if (-not (Test-Password @testPasswordParams))
                        {
                            Write-Verbose -Message ($script:localizedData.SettingADUserPassword -f $UserName)

                            Set-ADAccountPassword @adCommonParameters -Reset -NewPassword $Password.Password
                        }
                    }
                }
                elseif ($parameter -eq 'ChangePasswordAtLogon')
                {
                    # Only process the 'ChangePasswordAtLogon = $true' parameter during new user creation
                    continue
                }
                elseif ($parameter -eq 'ThumbnailPhoto')
                {
                    # Compare thumbnail hash, if they are the same the function Compare-ThumbnailPhoto returns $null.
                    if (Compare-ThumbnailPhoto -DesiredThumbnailPhoto $ThumbnailPhoto `
                            -CurrentThumbnailPhotoHash $targetResource.ThumbnailPhotoHash)
                    {
                        if ($ThumbnailPhoto -eq [System.String]::Empty)
                        {
                            $clearUserProperties += $adProperty.ADProperty

                            Write-Verbose -Message ($script:localizedData.ClearingADUserProperty -f
                                $adProperty.ADProperty)
                            }
                        else
                        {
                            [System.Byte[]] $thumbnailPhotoBytes = Get-ThumbnailByteArray `
                                -ThumbnailPhoto $ThumbnailPhoto -Verbose:$false

                            $thumbnailPhotoHash = Get-MD5HashString -Bytes $thumbnailPhotoBytes

                            Write-Verbose -Message ($script:localizedData.UpdatingThumbnailPhotoProperty -f
                                $adProperty.ADProperty, $thumbnailPhotoHash)

                            $replaceUserProperties[$adProperty.ADProperty] = $thumbnailPhotoBytes
                        }
                    }
                }
                elseif (([System.String]::IsNullOrEmpty($parameters.$parameter)) -and `
                    ([System.String]::IsNullOrEmpty($targetResource.$parameter)))
                {
                    <#
                        Both values are null/empty and therefore we are compliant
                        Must catch this scenario separately, as Compare-Object can't compare Null objects
                    #>
                    continue
                }
                # Use Compare-Object to allow comparison of string and array parameters
                elseif (($null -ne $parameters.$parameter -and $null -eq $targetResource.$parameter) -or
                    ($null -eq $parameters.$parameter -and $null -ne $targetResource.$parameter) -or
                    (Compare-Object -ReferenceObject $parameters.$parameter `
                            -DifferenceObject $targetResource.$parameter))
                {
                    if ([System.String]::IsNullOrEmpty($parameters.$parameter) -and `
                        (-not ([System.String]::IsNullOrEmpty($targetResource.$parameter))))
                    {
                        # We are clearing the existing value
                        Write-Verbose -Message ($script:localizedData.ClearingADUserProperty -f $parameter)

                        $clearUserProperties += $adProperty.ADProperty
                    } #end if clear existing value
                    else
                    {
                        # We are replacing the existing value
                        Write-Verbose -Message ($script:localizedData.UpdatingADUserProperty -f
                            $parameter, ($parameters.$parameter -join ','))

                        if ($adProperty.UseCmdletParameter -eq $true)
                        {
                            # We need to pass the parameter explicitly to Set-ADUser, not via -Replace
                            $setADUserParams[$adProperty.ADProperty] = $parameters.$parameter
                        }
                        else
                        {
                            $replaceUserProperties[$adProperty.ADProperty] = $parameters.$parameter
                        }
                    }
                }
            }

            # Only pass -Clear and/or -Replace if we have something to set/change
            if ($replaceUserProperties.Count -gt 0)
            {
                $setADUserParams['Replace'] = $replaceUserProperties
            }

            if ($clearUserProperties.Count -gt 0)
            {
                $setADUserParams['Clear'] = $clearUserProperties;
            }

            # Only call Set-ADUser if there are properties to change
            if ($setADUserParams.Keys.Count -gt 0)
            {
                $setADUserParams += Get-ADCommonParameters @PSBoundParameters

                Write-Verbose -Message ($script:localizedData.UpdatingADUser -f $UserName, $DomainName)

                Write-Debug ('Set-ADUser Parameters: ' + ($setADUserParams | Out-String))

                Set-ADUser @setADUserParams | Out-Null
            }

            if ($moveUserRequired)
            {
                # Cannot move users by updating the DistinguishedName property
                $moveAdObjectParameters = Get-ADCommonParameters @PSBoundParameters

                # Using the SamAccountName for identity with Move-ADObject does not work, use the DN instead
                $moveAdObjectParameters['Identity'] = $targetResource.DistinguishedName

                Write-Verbose -Message ($script:localizedData.MovingADUser -f
                    $targetResource.Path, $parameters.Path)

                Move-ADObject @moveAdObjectParameters -TargetPath $parameters.Path

                # Set new target resource DN in case a rename is also required
                $targetResource.DistinguishedName = "cn=$($targetResource.CommonName),$($parameters.Path)"
            }

            if ($updateCnRequired)
            {
                # Cannot update the CN property directly. Must use Rename-ADObject
                $renameAdObjectParameters = Get-ADCommonParameters @PSBoundParameters

                # Using the SamAccountName for identity with Rename-ADObject does not work, use the DN instead
                $renameAdObjectParameters['Identity'] = $targetResource.DistinguishedName

                Write-Verbose -Message ($script:localizedData.UpdatingADUserProperty -f
                    'CommonName', $parameters.CommonName)

                Rename-ADObject @renameAdObjectParameters -NewName $parameters.CommonName
            }
        }
    }
    elseif (($Ensure -eq 'Absent') -and ($targetResource.Ensure -eq 'Present'))
    {
        # User exists and needs removing
        Write-Verbose ($script:localizedData.RemovingADUser -f $UserName, $DomainName)

        $adCommonParameters = Get-ADCommonParameters @PSBoundParameters

        Remove-ADUser @adCommonParameters -Confirm:$false | Out-Null
    }

} # end function Set-TargetResource

<#
    .SYNOPSIS
        Internal function to validate unsupported options/configurations.

    .PARAMETER Password
        Specifies a new password value for the account.

    .PARAMETER Enabled
        Specifies if the account is enabled. Default value is $true.

    .PARAMETER ChangePasswordAtLogon
        Specifies whether the account password must be changed during the next
        logon attempt. This will only be enabled when the user is initially
        created. This parameter cannot be set to $true if the parameter
        PasswordNeverExpires is also set to $true.

    .PARAMETER PasswordNeverExpires
        Specifies whether the password of an account can expire.

    .PARAMETER IgnoredArguments
        Sets the rest of the arguments that are not passed into the this
        function.

    .NOTES
        Used Functions:
            Name                         | Module
            -----------------------------|--------------------------
            New-InvalidArgumentException | DscResource.Common
#>
function Assert-Parameters
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        $Password,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $ChangePasswordAtLogon,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $PasswordNeverExpires,

        [Parameter(ValueFromRemainingArguments)]
        $IgnoredArguments
    )

    # We cannot test/set passwords on disabled AD accounts
    if (($PSBoundParameters.ContainsKey('Password')) -and ($Enabled -eq $false))
    {
        $errorMessage = $script:localizedData.PasswordParameterConflictError -f 'Enabled', $false, 'Password'
        New-InvalidArgumentException -ArgumentName 'Password' -Message $errorMessage
    }

    # ChangePasswordAtLogon cannot be set for an account that also has PasswordNeverExpires set
    if ($PSBoundParameters.ContainsKey('ChangePasswordAtLogon') -and `
            $PSBoundParameters['ChangePasswordAtLogon'] -eq $true -and `
            $PSBoundParameters.ContainsKey('PasswordNeverExpires') -and `
            $PSBoundParameters['PasswordNeverExpires'] -eq $true)
    {
        $errorMessage = $script:localizedData.ChangePasswordParameterConflictError
        New-InvalidArgumentException -ArgumentName 'ChangePasswordAtLogon, PasswordNeverExpires' -Message $errorMessage
    }

} #end function Assert-Parameters

<#
    .SYNOPSIS
        Internal function to calculate the thumbnailPhoto hash.

    .PARAMETER Bytes
        A Byte array that will be hashed.

    .OUTPUTS
        Returns the MD5 hash of the bytes past in parameter Bytes, or $null if
        the value of parameter is $null.
#>
function Get-MD5HashString
{
    [CmdletBinding()]
    [OutputType([System.Byte[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Byte[]]
        $Bytes
    )

    $md5ReturnValue = $null

    if ($null -ne $Bytes)
    {
        $md5 = [System.Security.Cryptography.MD5]::Create()
        $hashBytes = $md5.ComputeHash($Bytes)

        $md5ReturnValue = [System.BitConverter]::ToString($hashBytes).Replace('-', '')
    }

    return $md5ReturnValue
} # end function Get-MD5HashString

<#
    .SYNOPSIS
        Internal function to convert either a .jpg-file or a Base64-encoded jpeg
        image to a Byte array.

    .PARAMETER ThumbnailPhoto
        A string of either a .jpg-file or the string of a Base64-encoded jpeg image.

    .OUTPUTS
        Returns a byte array of the image specified in the parameter ThumbnailPhoto.

    .NOTES
        Used Functions:
            Name                          | Module
            ------------------------------|--------------------------
            New-InvalidOperationException | DscResource.Common
#>
function Get-ThumbnailByteArray
{
    [CmdletBinding()]
    [OutputType([System.Byte[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ThumbnailPhoto
    )

    # If $ThumbnailPhoto contains '.' or '\' then we assume that we have a file path
    if ($ThumbnailPhoto -match '\.|\\')
    {
        if (Test-Path -Path $ThumbnailPhoto)
        {
            Write-Verbose -Message ($script:localizedData.LoadingThumbnailFromFile -f $ThumbnailPhoto)
            $thumbnailPhotoAsByteArray = Get-ByteContent -Path $ThumbnailPhoto
        }
        else
        {
            $errorMessage = $script:localizedData.ThumbnailPhotoNotAFile
            New-InvalidOperationException -Message $errorMessage
        }
    }
    else
    {
        $thumbnailPhotoAsByteArray = [System.Convert]::FromBase64String($ThumbnailPhoto)
    }

    return $thumbnailPhotoAsByteArray
} # end function Get-ThumbnailByteArray

<#
    .SYNOPSIS
        Internal function to compare two thumbnail photos.

    .PARAMETER DesiredThumbnailPhoto
        The desired thumbnail photo. Can be set to either a path to a .jpg-file,
        a Base64-encoded jpeg image, an empty string, or $null.

    .PARAMETER CurrentThumbnailPhotoHash
        The current thumbnail photo MD5 hash, or an empty string or $null if there
        is no current thumbnail photo.

    .OUTPUTS
        Returns $null if the thumbnail photos are the same, or a hashtable with
        the hashes if the thumbnail photos do not match.

    .NOTES
        Used Functions:
            Name                          | Module
            ------------------------------|--------------------------
            Get-MD5HashString             | MSFT_ADUser
            Get-ThumbnailByteArray        | MSFT_ADUser
#>
function Compare-ThumbnailPhoto
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $DesiredThumbnailPhoto,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $CurrentThumbnailPhotoHash
    )

    if ([System.String]::IsNullOrEmpty($DesiredThumbnailPhoto))
    {
        $desiredThumbnailPhotoHash = $null
    }
    else
    {
        $desiredThumbnailPhotoHash = Get-MD5HashString `
            -Bytes (Get-ThumbnailByteArray -ThumbnailPhoto $DesiredThumbnailPhoto)
    }

    <#
        Compare thumbnail hashes. Must [System.String]::IsNullOrEmpty() to
        compare empty values correctly.
    #>
    if ($desiredThumbnailPhotoHash -eq $CurrentThumbnailPhotoHash `
            -or (
            [System.String]::IsNullOrEmpty($desiredThumbnailPhotoHash) `
                -and [System.String]::IsNullOrEmpty($CurrentThumbnailPhotoHash)
        )
    )
    {
        $returnValue = $null
    }
    else
    {
        $returnValue = @{
            CurrentThumbnailPhotoHash = $CurrentThumbnailPhotoHash
            DesiredThumbnailPhotoHash = $desiredThumbnailPhotoHash
        }
    }

    return $returnValue
}

Export-ModuleMember -Function *-TargetResource
