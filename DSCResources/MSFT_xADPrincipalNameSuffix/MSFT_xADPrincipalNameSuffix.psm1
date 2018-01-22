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
$adCommonFunctions = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath '\MSFT_xADCommon\MSFT_xADCommon.ps1';
. $adCommonFunctions

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Forest
Parameter description

.PARAMETER UserPrincipalNameSuffix
Parameter description

.PARAMETER ServicePrincipalNameSuffix
Parameter description

.PARAMETER Credential
Parameter description

.PARAMETER Ensure
Parameter description

.EXAMPLE
An example

.NOTES
General notes
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
        $ServicePrincipalNameSuffix,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [String]
        $Ensure = "Present"
    )

    Assert-Module -ModuleName 'ActiveDirectory';
    Import-Module -Name 'ActiveDirectory' -Verbose:$false;

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

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1


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

    Assert-Module -ModuleName 'ActiveDirectory';
    Import-Module -Name 'ActiveDirectory' -Verbose:$false;

    $forest = Get-ADForest -Identity $ForestName
    $inDesiredState = $true

    if($UserPrincipalNameSuffix)
    {
        if($Ensure -eq 'Present')
        {
            $compare = Compare-Object -ReferenceObject $UserPrincipalNameSuffix -DifferenceObject $forest.UPNSuffixes
            if($compare)
            {
                Write-Verbose -Message ($LocalizedData.ForestUpnSuffixNotInDesiredState -f $ForestName)
                $inDesiredState = $false
            }
        }

        foreach ($suffix in $UserPrincipalNameSuffix)
        {
            if($Ensure -eq 'Present')
            {
                if ($suffix -notin $forest.UPNSuffixes)
                {
                    Write-Verbose -Message ($LocalizedData.UpnSuffixNotInDesiredState -f $suffix)
                    $inDesiredState = $false
                }
            }
            else #absent
            {
                if ($suffix -in $forest.UPNSuffixes)
                {
                    Write-Verbose -Message ($LocalizedData.UpnSuffixNotInDesiredState -f $suffix)
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
                Write-Verbose -Message ($LocalizedData.ForestSPNSuffixNotInDesiredState -f $ForestName)
                $inDesiredState = $false
            }
        }

        foreach ($suffix in $ServicePrincipalNameSuffix)
        {
            if($Ensure -eq 'Present')
            {
                if ($suffix -notin $forest.SPNSuffixes)
                {
                    Write-Verbose -Message ($LocalizedData.SPNSuffixNotInDesiredState -f $suffix)
                    $inDesiredState = $false
                }
            }
            else #absent
            {
                if ($suffix -in $forest.SPNSuffixes)
                {
                    Write-Verbose -Message ($LocalizedData.SPNSuffixNotInDesiredState -f $suffix)
                    $inDesiredState = $false
                }
            }
        }
    }

    return $inDesiredState
}
