$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
#region LocalizedData
$culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture))
{
    $culture = $PSUICulture
}
$importLocalizedDataParams = @{
    BindingVariable = 'LocalizedData'
    Filename = 'MSFT_xADForestProperties.strings.psd1'
    BaseDirectory = $moduleRoot
    UICulture = $culture
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

.PARAMETER ForestName
    The target Active Directory forest for the change.

.PARAMETER UserPrincipalNameSuffix
    The User Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER UserPrincipalNameSuffixToInclude
    The User Principal Name Suffix(es) to include in the forest.

.PARAMETER UserPrincipalNameSuffixToExclude
    The User Principal Name Suffix(es) to exclude in the forest.

.PARAMETER ServicePrincipalNameSuffix
    The Service Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER ServicePrincipalNameSuffixToInclude
    The Service Principal Name Suffix(es) to include in the forest.

.PARAMETER ServicePrincipalNameSuffixToExclude
    The Service Principal Name Suffix(es) to exclude in the forest.

.PARAMETER Credential
    The user account credentials to use to perform this task.

.PARAMETER Ensure
    Whether the principal name suffixes are added or removed.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $ForestName,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffix,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffixToInclude,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffixToExclude,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffix,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffixToInclude,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffixToExclude,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    Import-Module -Name 'ActiveDirectory' -Verbose:$false

    Write-Verbose -Message ($localizedData.GetForest -f $ForestName)
    $forest = Get-ADForest -Identity $ForestName

    $targetResource = @{
        ForestName = $forest.Name
        UserPrincipalNameSuffix = @($forest.UpnSuffixes)
        UserPrincipalNameSuffixToInclude = $UserPrincipalNameSuffixToInclude
        UserPrincipalNameSuffixToExclude = $UserPrincipalNameSuffixToExclude
        ServicePrincipalNameSuffix = @($forest.SpnSuffixes)
        ServicePrincipalNameSuffixToInclude = $ServicePrincipalNameSuffixToInclude
        ServicePrincipalNameSuffixToExclude = $ServicePrincipalNameSuffixToExclude
        Credential = ''
        Ensure = $Ensure
    }

    return $targetResource
}

<#
.SYNOPSIS
    Tests the current state of user principal name and service principal name suffixes in the forest.

.PARAMETER ForestName
    The target Active Directory forest for the change.

.PARAMETER UserPrincipalNameSuffix
    The User Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER UserPrincipalNameSuffixToInclude
    The User Principal Name Suffix(es) to include in the forest.

.PARAMETER UserPrincipalNameSuffixToExclude
    The User Principal Name Suffix(es) to exclude in the forest.

.PARAMETER ServicePrincipalNameSuffix
    The Service Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER ServicePrincipalNameSuffixToInclude
    The Service Principal Name Suffix(es) to include in the forest.

.PARAMETER ServicePrincipalNameSuffixToExclude
    The Service Principal Name Suffix(es) to exclude in the forest.

.PARAMETER Credential
    The user account credentials to use to perform this task.

.PARAMETER Ensure
    Whether the principal name suffixes are added or removed.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $ForestName,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffix,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffix,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    Import-Module -Name 'ActiveDirectory' -Verbose:$false

    $forest = Get-ADForest -Identity $ForestName
    $inDesiredState = $true

    if ($UserPrincipalNameSuffix)
    {
        if ($Ensure -eq 'Present')
        {
            $compare = Compare-Object -ReferenceObject $UserPrincipalNameSuffix -DifferenceObject $forest.UpnSuffixes
            if ($compare)
            {
                Write-Verbose -Message ($localizedData.ForestUpnSuffixNotInDesiredState -f $ForestName)
                $inDesiredState = $false
            }
        }

        foreach ($suffix in $UserPrincipalNameSuffix)
        {
            if ($Ensure -eq 'Present')
            {
                if ($suffix -notin $forest.UpnSuffixes)
                {
                    Write-Verbose -Message ($localizedData.UpnSuffixNotInDesiredState -f $suffix)
                    $inDesiredState = $false
                }
            }
            else # Absent
            {
                if ($suffix -in $forest.UpnSuffixes)
                {
                    Write-Verbose -Message ($localizedData.UpnSuffixNotInDesiredState -f $suffix)
                    $inDesiredState = $false
                }
            }
        }
    }

    if ($ServicePrincipalNameSuffix)
    {
        if ($Ensure -eq 'Present')
        {
            $compare = Compare-Object -ReferenceObject $ServicePrincipalNameSuffix -DifferenceObject $forest.SpnSuffixes
            if ($compare)
            {
                Write-Verbose -Message ($localizedData.ForestSpnSuffixNotInDesiredState -f $ForestName)
                $inDesiredState = $false
            }
        }

        foreach ($suffix in $ServicePrincipalNameSuffix)
        {
            if ($Ensure -eq 'Present')
            {
                if ($suffix -notin $forest.SpnSuffixes)
                {
                    Write-Verbose -Message ($localizedData.SpnSuffixNotInDesiredState -f $suffix)
                    $inDesiredState = $false
                }
            }
            else # Absent
            {
                if ($suffix -in $forest.SpnSuffixes)
                {
                    Write-Verbose -Message ($localizedData.SpnSuffixNotInDesiredState -f $suffix)
                    $inDesiredState = $false
                }
            }
        }
    }

    return $inDesiredState
}

<#
.SYNOPSIS
    Sets the user principal name and service principal name suffixes in the forest.

.PARAMETER ForestName
    The target Active Directory forest for the change.

.PARAMETER UserPrincipalNameSuffix
    The User Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER UserPrincipalNameSuffixToInclude
    The User Principal Name Suffix(es) to include in the forest.

.PARAMETER UserPrincipalNameSuffixToExclude
    The User Principal Name Suffix(es) to exclude in the forest.

.PARAMETER ServicePrincipalNameSuffix
    The Service Principal Name Suffix(es) to be explicitly defined in the forest.

.PARAMETER ServicePrincipalNameSuffixToInclude
    The Service Principal Name Suffix(es) to include in the forest.

.PARAMETER ServicePrincipalNameSuffixToExclude
    The Service Principal Name Suffix(es) to exclude in the forest.

.PARAMETER Credential
    The user account credentials to use to perform this task.

.PARAMETER Ensure
    Whether the principal name suffixes are added or removed.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $ForestName,

        [Parameter()]
        [String[]]
        $UserPrincipalNameSuffix,

        [Parameter()]
        [String[]]
        $ServicePrincipalNameSuffix,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
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

    if ($Ensure -eq 'Present')
    {
        $action = 'Replace'
    }
    else #absent
    {
        $action = 'Remove'
    }

    if ($UserPrincipalNameSuffix)
    {
        $setADForestParameters['UpnSuffixes'] = @{ 
            $action = $UserPrincipalNameSuffix
        }
        Write-Verbose -Message ($localizedData.SetUpnSuffix -f $action)
    }

    if ($ServicePrincipalNameSuffix)
    {
        $setADForestParameters['SpnSuffixes'] = @{ 
            $action = $ServicePrincipalNameSuffix 
        }
        Write-Verbose -Message ($localizedData.SetSpnSuffix -f $action)
    }

    Set-ADForest @setADForestParameters
}
