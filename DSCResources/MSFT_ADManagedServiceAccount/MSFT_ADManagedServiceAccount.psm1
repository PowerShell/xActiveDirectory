<#
.PARAMETER ServiceAccountName
    Specifies the Security Account Manager (SAM) account name of the managed service account (ldapDisplayName 'sAMAccountName').
    To be compatible with older operating systems, create a SAM account name that is 20 characters or less. Once created,
    the user's SamAccountName and CN cannot be changed.

.PARAMETER AccountType
    The type of managed service account. Standalone will create a Standalone Managed Service Account (sMSA) and Group will
    create a Group Managed Service Account (gMSA).

.PARAMETER Credential
    Specifies the user account credentials to use to perform this task.
    This is only required if not executing the task on a domain controller or using the -DomainController parameter.

.PARAMETER Description
    Specifies the description of the account (ldapDisplayName 'description').

.PARAMETER DisplayName
    Specifies the display name of the account (ldapDisplayName 'displayName').

.PARAMETER DomainController
    Specifies the Active Directory Domain Controller instance to use to perform the task.
    This is only required if not executing the task on a domain controller.

.PARAMETER Ensure
    Specifies whether the user account is created or deleted. If not specified, this value defaults to Present.

.PARAMETER KerberosEncryptionType
    Specifies which Kerberos encryption types the account supports when creating service tickets.
    This value sets the encryption types supported flags of the Active Directory msDS-SupportedEncryptionTypes attribute.

.PARAMETER ManagedPasswordPrincipals
    Specifies the membership policy for systems which can use a group managed service account. (ldapDisplayName 'msDS-GroupMSAMembership').
    Only used when 'Group' is selected for 'AccountType'.

.PARAMETER MembershipAttribute
    Active Directory attribute used to perform membership operations for Group Managed Service Accounts (gMSAs).
    If not specified, this value defaults to SamAccountName. Only used when 'Group' is selected for 'AccountType'.

.PARAMETER Path
    Specifies the X.500 path of the Organizational Unit (OU) or container where the new account is created.
    Specified as a Distinguished Name (DN).
#>

$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'ActiveDirectoryDsc.Common'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'ActiveDirectoryDsc.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_ADManagedServiceAccount'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServiceAccountName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Group', 'Standalone')]
        [System.String]
        $AccountType,

        [Parameter()]
        [ValidateSet('SamAccountName', 'DistinguishedName', 'ObjectSid', 'ObjectGUID')]
        [System.String]
        $MembershipAttribute = 'SamAccountName',

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    $adServiceAccountParameters = Get-ADCommonParameters @PSBoundParameters

    Write-Verbose -Message ($script:localizedData.RetrievingManagedServiceAccountMessage -f `
            $ServiceAccountName)

    try
    {
        $adServiceAccount = Get-ADServiceAccount @adServiceAccountParameters -Properties @(
            'DistinguishedName'
            'Description'
            'DisplayName'
            'ObjectClass'
            'Enabled'
            'PrincipalsAllowedToRetrieveManagedPassword'
            'KerberosEncryptionType'
        )
    }

    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        Write-Verbose -Message ($script:localizedData.ManagedServiceAccountNotFoundMessage -f `
                $AccountType, $ServiceAccountName)
    }
    catch
    {
        $errorMessage = $script:localizedData.RetrievingManagedServiceAccountError -f $ServiceAccountName
        New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
    }

    if ($adServiceAccount)
    {
        # Resource exists
        if ($adServiceAccount.ObjectClass -eq 'msDS-ManagedServiceAccount')
        {
            $accountType = 'Standalone'
        }
        else
        {
            $accountType = 'Group'

            Write-Verbose -Message ($script:localizedData.RetrievingManagedPasswordPrincipalsMessage -f $MembershipAttribute)
            $managedPasswordPrincipals = @()
            foreach ($identity in $adServiceAccount.PrincipalsAllowedToRetrieveManagedPassword)
            {
                try
                {
                    $principal = (Get-ADObject -Identity $identity -Properties $MembershipAttribute).$MembershipAttribute
                }
                catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
                {
                    $principal = $identity
                }
                catch
                {
                    $errorMessage = $script:localizedData.RetrievingManagedPasswordPrincipalsError -f $identity
                    New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
                }
                $managedPasswordPrincipals += $principal
            }
        }

        $targetResource = @{
            ServiceAccountName        = $ServiceAccountName
            AccountType               = $AccountType
            Path                      = Get-ADObjectParentDN -DN $adServiceAccount.DistinguishedName
            Description               = $adServiceAccount.Description
            DisplayName               = $adServiceAccount.DisplayName
            DistinguishedName         = $adServiceAccount.DistinguishedName
            Enabled                   = $adServiceAccount.Enabled
            KerberosEncryptionType    = $adServiceAccount.KerberosEncryptionType -split (', ')
            ManagedPasswordPrincipals = $managedPasswordPrincipals
            MembershipAttribute       = $MembershipAttribute
            Ensure                    = 'Present'
        }
    }
    else
    {
        # Resource does not exist
        $targetResource = @{
            ServiceAccountName        = $ServiceAccountName
            AccountType               = $AccountType
            Path                      = $null
            Description               = $null
            DisplayName               = $null
            DistinguishedName         = $null
            Enabled                   = $false
            KerberosEncryptionType    = @()
            ManagedPasswordPrincipals = @()
            MembershipAttribute       = $MembershipAttribute
            Ensure                    = 'Absent'
        }
    }

    return $targetResource
} #end function Get-TargetResource


function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', "",
        Justification = 'False positive on ManagedPasswordPrincipals')]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServiceAccountName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Group', 'Standalone')]
        [System.String]
        $AccountType,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateSet('None', 'RC4', 'AES128', 'AES256')]
        [System.String[]]
        $KerberosEncryptionType,

        [Parameter()]
        [System.String[]]
        $ManagedPasswordPrincipals,

        [Parameter()]
        [ValidateSet('SamAccountName', 'DistinguishedName', 'ObjectSid', 'ObjectGUID')]
        [System.String]
        $MembershipAttribute = 'SamAccountName',

        [Parameter()]
        [System.String]
        $Path
    )

    # Need to set these parameters to compare if users are using the default parameter values
    $PSBoundParameters['MembershipAttribute'] = $MembershipAttribute

    $getTargetResourceParameters = @{
        ServiceAccountName  = $ServiceAccountName
        AccountType         = $AccountType
        DomainController    = $DomainController
        MembershipAttribute = $MembershipAttribute
    }

    @($getTargetResourceParameters.Keys) |
        ForEach-Object {
            if (-not $PSBoundParameters.ContainsKey($_))
            {
                $getTargetResourceParameters.Remove($_)
            }
        }
    $targetResource = Get-TargetResource @getTargetResourceParameters

    if ($targetResource.Ensure -eq 'Present')
    {
        # Resource exists
        if ($Ensure -eq 'Present')
        {
            # Resource should exist
            $propertiesNotInDesiredState = Compare-ResourcePropertyState `
                -CurrentValues $targetResource -DesiredValues $PSBoundParameters -Verbose:$false | `
                    Where-Object -Property InDesiredState -eq $false

            if ($propertiesNotInDesiredState)
            {
                # Resource is not in desired state
                foreach ($property in $propertiesNotInDesiredState)
                {
                    Write-Verbose -Message ($script:localizedData.ResourcePropertyNotInDesiredStateMessage -f `
                            $AccountType, $ServiceAccountName, $property.ParameterName, ($property.Expected -join ', '), `
                        ($property.Actual -join ', '))
                }
                $inDesiredState = $false
            }
            else
            {
                # Resource is in desired state
                Write-Verbose -Message ($script:localizedData.ManagedServiceAccountInDesiredStateMessage -f `
                        $AccountType, $ServiceAccountName)
                $inDesiredState = $true
            }
        }
        else
        {
            # Resource should not exist
            Write-Verbose -Message ($script:localizedData.ResourceExistsButShouldNotMessage -f `
                    $AccountType, $ServiceAccountName)
            $inDesiredState = $false
        }
    }
    else
    {
        # Resource does not exist
        if ($Ensure -eq 'Present')
        {
            # Resource should exist
            Write-Verbose -Message ($script:localizedData.ResourceDoesNotExistButShouldMessage -f `
                    $AccountType, $ServiceAccountName)
            $inDesiredState = $false
        }
        else
        {
            # Resource should not exist
            Write-Verbose -Message ($script:localizedData.ManagedServiceAccountInDesiredStateMessage -f `
                    $AccountType, $ServiceAccountName)
            $inDesiredState = $true
        }
    }

    $inDesiredState
} #end function Test-TargetResource

function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', "",
        Justification = 'False positive on ManagedPasswordPrincipals')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServiceAccountName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Group', 'Standalone')]
        [System.String]
        $AccountType,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateSet('None', 'RC4', 'AES128', 'AES256')]
        [System.String[]]
        $KerberosEncryptionType,

        [Parameter()]
        [System.String[]]
        $ManagedPasswordPrincipals,

        [Parameter()]
        [ValidateSet('SamAccountName', 'DistinguishedName', 'ObjectSid', 'ObjectGUID')]
        [System.String]
        $MembershipAttribute = 'SamAccountName',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path
    )

    # Need to set these to compare if not specified since user is using defaults
    $PSBoundParameters['MembershipAttribute'] = $MembershipAttribute
    $PSBoundParameters.Remove('Ensure') | Out-Null

    $adServiceAccountParameters = Get-ADCommonParameters @PSBoundParameters

    $getTargetResourceParameters = @{
        ServiceAccountName  = $ServiceAccountName
        AccountType         = $AccountType
        DomainController    = $DomainController
        MembershipAttribute = $MembershipAttribute
    }
    @($getTargetResourceParameters.Keys) |
        ForEach-Object {
            if (-not $PSBoundParameters.ContainsKey($_))
            {
                $getTargetResourceParameters.Remove($_)
            }
        }
    $targetResource = Get-TargetResource @GetTargetResourceParameters

    if ($Ensure -eq 'Present')
    {
        # Resource should be present
        if ($targetResource.Ensure -eq 'Present')
        {
            # Resource is present
            $CreateNewAdServiceAccount = $false
            $propertiesNotInDesiredState = (
                Compare-ResourcePropertyState -CurrentValues $targetResource -DesiredValues $PSBoundParameters |
                    Where-Object -Property InDesiredState -eq $false)
            if ($propertiesNotInDesiredState)
            {
                if ($propertiesNotInDesiredState.ParameterName -contains 'AccountType')
                {
                    # AccountType has changed, so the account needs recreating
                    Write-Verbose -Message ($script:localizedData.RecreatingManagedServiceAccountMessage -f `
                            $AccountType, $ServiceAccountName)
                    try
                    {
                        Remove-ADServiceAccount @adServiceAccountParameters -Confirm:$false
                    }
                    catch
                    {
                        $errorMessage = $script:localizedData.RemovingManagedServiceAccountError -f `
                            $AccountType, $ServiceAccountName
                        New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
                    }

                    $CreateNewAdServiceAccount = $true
                }
                else
                {
                    $PSBoundParameters.Remove('AccountType')
                    $setServiceAccountParameters = $adServiceAccountParameters.Clone()
                    $setAdServiceAccountRequired = $false
                    $moveAdServiceAccountRequired = $false

                    foreach ($property in $propertiesNotInDesiredState)
                    {
                        if ($property.ParameterName -eq 'Path')
                        {
                            # The path has changed, so the account needs moving, but not until after any other changes
                            $moveAdServiceAccountRequired = $true
                        }
                        else
                        {
                            $setAdServiceAccountRequired = $true
                            Write-Verbose -Message ($script:localizedData.UpdatingManagedServiceAccountPropertyMessage -f `
                                    $AccountType, $ServiceAccountName, $property.ParameterName, ($property.Expected -join ', '))
                            if ($property.ParameterName -eq 'ManagedPasswordPrincipals' -and $AccountType -eq 'Group')
                            {
                                $setServiceAccountParameters.add('PrincipalsAllowedToRetrieveManagedPassword', `
                                        $ManagedPasswordPrincipals)
                            }
                            else
                            {
                                $SetServiceAccountParameters.add($property.ParameterName, $property.Expected)
                            }
                        }
                    }

                    if ($setAdServiceAccountRequired)
                    {
                        try
                        {
                            Set-ADServiceAccount @setServiceAccountParameters
                        }
                        catch
                        {
                            $errorMessage = $script:localizedData.SettingManagedServiceAccountError -f `
                                $AccountType, $ServiceAccountName
                            New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
                        }
                    }

                    if ($moveAdServiceAccountRequired)
                    {
                        Write-Verbose -Message ($script:localizedData.MovingManagedServiceAccountMessage -f `
                                $AccountType, $ServiceAccountName, $targetResource.Path, $Path)
                        $moveADObjectParameters = $adServiceAccountParameters.Clone()
                        $moveADObjectParameters.Identity = $targetResource.DistinguishedName
                        try
                        {
                            Move-ADObject @moveADObjectParameters -TargetPath $Path
                        }
                        catch
                        {
                            $errorMessage = $script:localizedData.MovingManagedServiceAccountError -f `
                                $AccountType, $ServiceAccountName, $targetResource.Path, $Path
                            New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
                        }
                    }
                }
            }
        }
        else
        {
            # Resource is absent
            $CreateNewAdServiceAccount = $true
        }

        if ($CreateNewAdServiceAccount)
        {
            Write-Verbose -Message ($script:localizedData.AddingManagedServiceAccountMessage -f `
                    $AccountType, $ServiceAccountName, $Path)

            $newAdServiceAccountParameters = Get-ADCommonParameters @PSBoundParameters -UseNameParameter

            if ($PSBoundParameters.ContainsKey('Description'))
            {
                $newAdServiceAccountParameters.Description = $Description
            }

            if ($PSBoundParameters.ContainsKey('DisplayName'))
            {
                $newAdServiceAccountParameters.DisplayName = $DisplayName
            }

            if ($PSBoundParameters.ContainsKey('Path'))
            {
                $newAdServiceAccountParameters.Path = $Path
            }

            if ( $AccountType -eq 'Standalone' )
            {
                # Create standalone managed service account
                $newAdServiceAccountParameters.RestrictToSingleComputer = $true
            }
            else
            {
                # Create group managed service account
                $newAdServiceAccountParameters.DNSHostName = "$ServiceAccountName.$(Get-DomainName)"

                if ($PSBoundParameters.ContainsKey('ManagedPasswordPrincipals'))
                {
                    $newAdServiceAccountParameters.PrincipalsAllowedToRetrieveManagedPassword = `
                        $ManagedPasswordPrincipals
                }
            }
            try
            {
                New-ADServiceAccount @newAdServiceAccountParameters
            }
            catch
            {
                if (-not $PSBoundParameters.ContainsKey('Path'))
                {
                    # Get default MSA path as one has not been specified
                    try
                    {
                        $DomainDN = (Get-ADDomain).DistinguishedName
                    }
                    catch
                    {
                        $errorMessage = $script:localizedData.GettingADDomainError
                        New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
                    }

                    $Path = "CN=Managed Service Accounts,$DomainDN"
                }

                $errorMessage = $script:localizedData.AddingManagedServiceAccountError -f `
                    $AccountType, $ServiceAccountName, $Path
                New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
            }
        }
    }
    else
    {
        # Resource should be absent
        if ($targetResource.Ensure -eq 'Present')
        {
            # Resource is present
            Write-Verbose -Message ($script:localizedData.RemovingManagedServiceAccountMessage -f `
                    $AccountType, $ServiceAccountName)
            try
            {
                Remove-ADServiceAccount @adServiceAccountParameters -Confirm:$false
            }
            catch
            {
                $errorMessage = $script:localizedData.RemovingManagedServiceAccountError -f `
                    $AccountType, $ServiceAccountName
                New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
            }
        }
        else
        {
            # Resource is absent
            Write-Verbose -Message ($script:localizedData.ManagedServiceAccountInDesiredStateMessage -f `
                    $AccountType, $ServiceAccountName)
        }
    }
} #end function Set-TargetResource

Export-ModuleMember -Function *-TargetResource
