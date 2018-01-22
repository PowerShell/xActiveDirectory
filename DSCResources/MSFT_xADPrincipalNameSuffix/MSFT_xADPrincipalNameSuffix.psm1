$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
#region LocalizedData
$culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture))
{
    $culture = $PSUICulture
}
$importLocalizedDataParams = @{
    BindingVariable = 'LocalizedData'
    Filename = 'MSFT_xADPrincipalNameSuffix.strings.psd1'
    BaseDirectory = $moduleRoot
    UICulture = $culture
}
Import-LocalizedData @importLocalizedDataParams
#endregion

## Import the common AD functions
$adCommonResourcePath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'MSFT_xADCommon'
$adCommonFunctions = Join-Path -Path $adCommonResourcePath -ChildPath 'MSFT_xADCommon.ps1'
. $adCommonFunctions

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
        $ServicePrincipalNameSuffix,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [String]
        $Ensure = "Present"
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    Import-Module -Name 'ActiveDirectory' -Verbose:$false

    Write-Verbose -Message ($localizedData.GetForest -f $ForestName)
    $forest = Get-ADForest -Identity $ForestName

    $targetResource = @{
        ForestName = $forest.Name
        UserPrincipalNameSuffix = @($forest.UPNSuffixes)
        ServicePrincipalNameSuffix = @($forest.SPNSuffixes)
        Credential = ""
        Ensure = $Ensure
    }

    return $targetResource
}

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
        [ValidateSet("Present","Absent")]
        [String]
        $Ensure = "Present"
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    Import-Module -Name 'ActiveDirectory' -Verbose:$false

    $forest = Get-ADForest -Identity $ForestName
    $inDesiredState = $true

    if($UserPrincipalNameSuffix)
    {
        if($Ensure -eq 'Present')
        {
            $compare = Compare-Object -ReferenceObject $UserPrincipalNameSuffix -DifferenceObject $forest.UPNSuffixes
            if($compare)
            {
                Write-Verbose -Message ($localizedData.ForestUpnSuffixNotInDesiredState -f $ForestName)
                $inDesiredState = $false
            }
        }

        foreach ($suffix in $UserPrincipalNameSuffix)
        {
            if($Ensure -eq 'Present')
            {
                if ($suffix -notin $forest.UPNSuffixes)
                {
                    Write-Verbose -Message ($localizedData.UpnSuffixNotInDesiredState -f $suffix)
                    $inDesiredState = $false
                }
            }
            else # Absent
            {
                if ($suffix -in $forest.UPNSuffixes)
                {
                    Write-Verbose -Message ($localizedData.UpnSuffixNotInDesiredState -f $suffix)
                    $inDesiredState = $false
                }
            }
        }
    }

    if($ServicePrincipalNameSuffix)
    {
        if($Ensure -eq 'Present')
        {
            $compare = Compare-Object -ReferenceObject $ServicePrincipalNameSuffix -DifferenceObject $forest.SPNSuffixes
            if($compare)
            {
                Write-Verbose -Message ($localizedData.ForestSPNSuffixNotInDesiredState -f $ForestName)
                $inDesiredState = $false
            }
        }

        foreach ($suffix in $ServicePrincipalNameSuffix)
        {
            if($Ensure -eq 'Present')
            {
                if ($suffix -notin $forest.SPNSuffixes)
                {
                    Write-Verbose -Message ($localizedData.SPNSuffixNotInDesiredState -f $suffix)
                    $inDesiredState = $false
                }
            }
            else # Absent
            {
                if ($suffix -in $forest.SPNSuffixes)
                {
                    Write-Verbose -Message ($localizedData.SPNSuffixNotInDesiredState -f $suffix)
                    $inDesiredState = $false
                }
            }
        }
    }

    return $inDesiredState
}

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
        [ValidateSet("Present","Absent")]
        [String]
        $Ensure = "Present"
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    Import-Module -Name 'ActiveDirectory' -Verbose:$false

    $setParams = @{Identity = $ForestName}
    if($Credential)
    {
        $setParams['Credential'] = $Credential
    }

    if($Ensure -eq 'Present')
    {
        $action = 'Replace'
    }
    else #absent
    {
        $action = 'Remove'
    }

    if($UserPrincipalNameSuffix)
    {
        $setParams['UPNSuffixes'] = ( @{ $action = $($UserPrincipalNameSuffix) } )
        Write-Verbose -Message ($localizedData.SetUpnSuffix -f $action)
    }

    if($ServicePrincipalNameSuffix)
    {
        $setParams['SPNSuffixes'] = ( @{ $action = $($ServicePrincipalNameSuffix) } )
        Write-Verbose -Message ($localizedData.SetSpnSuffix -f $action)
    }

    Set-ADForest @setParams
}
