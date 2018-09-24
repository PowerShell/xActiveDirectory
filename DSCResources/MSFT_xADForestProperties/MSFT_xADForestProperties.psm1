$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
#region LocalizedData
$culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture))
{
    $culture = $PSUICulture
}
$importLocalizedDataParams = @{
    BindingVariable = 'LocalizedData'
    Filename        = 'MSFT_xADForestProperties.strings.psd1'
    BaseDirectory   = $moduleRoot
    UICulture       = $culture
}
Import-LocalizedData @importLocalizedDataParams
#endregion

## Import the common AD functions
$adCommonResourcePath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'MSFT_xADCommon'
$adCommonFunctions = Join-Path -Path $adCommonResourcePath -ChildPath 'MSFT_xADCommon.ps1'
. $adCommonFunctions

<#
.SYNOPSIS
    Gets the current state of user principal name and service principal name suffixes in the forest.

.PARAMETER Credential
    The user account credentials to use to perform this task.

.PARAMETER ForestName
    The target Active Directory forest for the change.

.PARAMETER ServicePrincipalNameSuffix
    The Service Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER ServicePrincipalNameSuffixToExclude
    The Service Principal Name Suffix(es) to exclude in the forest.

.PARAMETER ServicePrincipalNameSuffixToInclude
    The Service Principal Name Suffix(es) to include in the forest.

.PARAMETER UserPrincipalNameSuffix
    The User Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER UserPrincipalNameSuffixToExclude
    The User Principal Name Suffix(es) to exclude in the forest.

.PARAMETER UserPrincipalNameSuffixToInclude
    The User Principal Name Suffix(es) to include in the forest.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [String]
        $ForestName,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffix,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffixToExclude,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffixToInclude,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffix,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffixToExclude,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffixToInclude
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    Import-Module -Name 'ActiveDirectory' -Verbose:$false

    $getADForestParameters = @{
        Identity = $ForestName
    }

    if ($Credential)
    {
        $getADForestParameters['Credential'] = $Credential
    }

    Write-Verbose -Message ($localizedData.GetForest -f $ForestName)
    $forest = Get-ADForest -Identity $ForestName

    $targetResource = @{
        ForestName                          = $forest.Name
        UserPrincipalNameSuffix             = [Array]$forest.UpnSuffixes
        UserPrincipalNameSuffixToInclude    = [Array]$UserPrincipalNameSuffixToInclude
        UserPrincipalNameSuffixToExclude    = [Array]$UserPrincipalNameSuffixToExclude
        ServicePrincipalNameSuffix          = [Array]$forest.SpnSuffixes
        ServicePrincipalNameSuffixToInclude = [Array]$ServicePrincipalNameSuffixToInclude
        ServicePrincipalNameSuffixToExclude = [Array]$ServicePrincipalNameSuffixToExclude
        Credential                          = ''
    }

    return $targetResource
}

<#
.SYNOPSIS
    Tests the current state of user principal name and service principal name suffixes in the forest.

.PARAMETER Credential
    The user account credentials to use to perform this task.

.PARAMETER ForestName
    The target Active Directory forest for the change.

.PARAMETER ServicePrincipalNameSuffix
    The Service Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER ServicePrincipalNameSuffixToExclude
    The Service Principal Name Suffix(es) to exclude in the forest.

.PARAMETER ServicePrincipalNameSuffixToInclude
    The Service Principal Name Suffix(es) to include in the forest.

.PARAMETER UserPrincipalNameSuffix
    The User Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER UserPrincipalNameSuffixToExclude
    The User Principal Name Suffix(es) to exclude in the forest.

.PARAMETER UserPrincipalNameSuffixToInclude
    The User Principal Name Suffix(es) to include in the forest.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [String]
        $ForestName,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffix,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffixToExclude,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffixToInclude,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffix,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffixToExclude,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffixToInclude
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    Import-Module -Name 'ActiveDirectory' -Verbose:$false

    $inDesiredState = $true

    $forest = Get-ADForest -Identity $ForestName

    ## Validate parameters before we even attempt to retrieve anything
    $assertMemberParameters = @{}
    if ($PSBoundParameters.ContainsKey('ServicePrincipalNameSuffix') -and -not [system.string]::IsNullOrEmpty($ServicePrincipalNameSuffix))
    {
        $assertMemberParameters['Members'] = $ServicePrincipalNameSuffix
    }
    if ($PSBoundParameters.ContainsKey('ServicePrincipalNameSuffixToInclude') -and -not [system.string]::IsNullOrEmpty($ServicePrincipalNameSuffixToInclude))
    {
        $assertMemberParameters['MembersToInclude'] = $ServicePrincipalNameSuffixToInclude
    }
    if ($PSBoundParameters.ContainsKey('ServicePrincipalNameSuffixToExclude') -and -not [system.string]::IsNullOrEmpty($ServicePrincipalNameSuffixToExclude))
    {
        $assertMemberParameters['MembersToExclude'] = $ServicePrincipalNameSuffixToExclude
    }

    Assert-MemberParameters @assertMemberParameters -ErrorAction Stop

    if (-not ( Test-Members @assertMemberParameters -ExistingMembers ($forest.SpnSuffixes -split ',') ))
    {
        Write-Verbose -Message $LocalizedData.ForestSpnSuffixNotInDesiredState
        $inDesiredState = $false
    }

    $assertMemberParameters = @{}
    if ($PSBoundParameters.ContainsKey('UserPrincipalNameSuffix') -and -not [system.string]::IsNullOrEmpty($UserPrincipalNameSuffix))
    {
        $assertMemberParameters['Members'] = $UserPrincipalNameSuffix
    }
    if ($PSBoundParameters.ContainsKey('UserPrincipalNameSuffixToInclude') -and -not [system.string]::IsNullOrEmpty($UserPrincipalNameSuffixToInclude))
    {
        $assertMemberParameters['MembersToInclude'] = $UserPrincipalNameSuffixToInclude
    }
    if ($PSBoundParameters.ContainsKey('UserPrincipalNameSuffixToExclude') -and -not [system.string]::IsNullOrEmpty($UserPrincipalNameSuffixToExclude))
    {
        $assertMemberParameters['MembersToExclude'] = $UserPrincipalNameSuffixToExclude
    }

    Assert-MemberParameters @assertMemberParameters -ErrorAction Stop

    if (-not ( Test-Members @assertMemberParameters -ExistingMembers ($forest.UpnSuffixes -split ',') ))
    {
        Write-Verbose -Message $LocalizedData.ForestUpnSuffixNotInDesiredState
        $inDesiredState = $false
    }

    return $inDesiredState
}

<#
.SYNOPSIS
    Sets the user principal name and service principal name suffixes in the forest.

.PARAMETER Credential
    The user account credentials to use to perform this task.

.PARAMETER ForestName
    The target Active Directory forest for the change.

.PARAMETER ServicePrincipalNameSuffix
    The Service Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER ServicePrincipalNameSuffixToExclude
    The Service Principal Name Suffix(es) to exclude in the forest.

.PARAMETER ServicePrincipalNameSuffixToInclude
    The Service Principal Name Suffix(es) to include in the forest.

.PARAMETER UserPrincipalNameSuffix
    The User Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER UserPrincipalNameSuffixToExclude
    The User Principal Name Suffix(es) to exclude in the forest.

.PARAMETER UserPrincipalNameSuffixToInclude
    The User Principal Name Suffix(es) to include in the forest.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [String]
        $ForestName,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffix,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffixToExclude,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffixToInclude,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffix,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffixToExclude,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffixToInclude
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    Import-Module -Name 'ActiveDirectory' -Verbose:$false

    $setADForestParameters = @{
        Identity = $ForestName
    }

    if ($Credential)
    {
        $setADForestParameters['Credential'] = $Credential
    }

    # add ServicePrincipalName parameter
    if ($PSBoundParameters.ContainsKey('ServicePrincipalNameSuffix') -and -not [system.string]::IsNullOrEmpty($ServicePrincipalNameSuffix))
    {
        $replaceServicePrincipalNameSuffix = $ServicePrincipalNameSuffix -join ','
        $setADForestParameters['SpnSuffixes'] = @{
            replace = $replaceServicePrincipalNameSuffix
        }

        Write-Verbose -Message ($localizedData.SetSpnSuffix -f 'replacing with', $replaceServicePrincipalNameSuffix)
    }
    if ($PSBoundParameters.ContainsKey('ServicePrincipalNameSuffixToInclude') -and -not [system.string]::IsNullOrEmpty($ServicePrincipalNameSuffixToInclude))
    {
        $addServicePrincipalNameSuffix = $ServicePrincipalNameSuffixToInclude -join ','
        $setADForestParameters['SpnSuffixes'] = @{
            add = $addServicePrincipalNameSuffix
        }

        Write-Verbose -Message ($localizedData.SetSpnSuffix -f 'adding', $addServicePrincipalNameSuffix)
    }
    if ($PSBoundParameters.ContainsKey('ServicePrincipalNameSuffixToExclude') -and -not [system.string]::IsNullOrEmpty($ServicePrincipalNameSuffixToExclude))
    {
        $removeServicePrincipalNameSuffix = $ServicePrincipalNameSuffixToExclude -join ','
        if ($setADForestParameters['SpnSuffixes'])
        {
            $setADForestParameters['SpnSuffixes']['remove'] = $removeServicePrincipalNameSuffix
        }
        else
        {
            $setADForestParameters['SpnSuffixes'] = @{
                remove = $removeServicePrincipalNameSuffix
            }
        }
        
        Write-Verbose -Message ($localizedData.SetSpnSuffix -f 'removing', $removeServicePrincipalNameSuffix)
    }

    # add UserPrincipalName parameter
    if ($PSBoundParameters.ContainsKey('UserPrincipalNameSuffix') -and -not [system.string]::IsNullOrEmpty($UserPrincipalNameSuffix))
    {
        $replaceUserPrincipalNameSuffix = $UserPrincipalNameSuffix -join ','
        $setADForestParameters['UpnSuffixes'] = @{
            replace = $replaceUserPrincipalNameSuffix
        }

        Write-Verbose -Message ($localizedData.SetUpnSuffix -f 'replacing with', $replaceUserPrincipalNameSuffix)
    }
    if ($PSBoundParameters.ContainsKey('UserPrincipalNameSuffixToInclude') -and -not [system.string]::IsNullOrEmpty($UserPrincipalNameSuffixToInclude))
    {
        $addUserPrincipalNameSuffix = $UserPrincipalNameSuffixToInclude -join ','
        $setADForestParameters['UpnSuffixes'] = @{
            add = $addUserPrincipalNameSuffix
        }

        Write-Verbose -Message ($localizedData.SetUpnSuffix -f 'adding', $addUserPrincipalNameSuffix)
    }
    if ($PSBoundParameters.ContainsKey('UserPrincipalNameSuffixToExclude') -and -not [system.string]::IsNullOrEmpty($UserPrincipalNameSuffixToExclude))
    {
        $removeUserPrincipalNameSuffix = $UserPrincipalNameSuffixToExclude -join ','
        if ($setADForestParameters['UpnSuffixes'])
        {
            $setADForestParameters['UpnSuffixes']['remove'] = $removeUserPrincipalNameSuffix
        }
        else
        {
            $setADForestParameters['UpnSuffixes'] = @{
                remove = $removeUserPrincipalNameSuffix
            }
        }
        
        Write-Verbose -Message ($localizedData.SetUpnSuffix -f 'removing', $removeUserPrincipalNameSuffix)
    }

    Set-ADForest @setADForestParameters
}
