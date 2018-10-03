Import-Module -Name (Join-Path -Path (Split-Path -Path $PSScriptRoot) -ChildPath CommonResourceHelper.psm1)

<#
    .SYNOPSIS
        Gets the current configuration on an AD Replication Site Link.
    .PARAMETER Name
        Specifies the name of the AD Replication Site Link.
    .PARAMETER Ensure
        Specifies if the site link is created or deleted.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String[]]
        $SitesExcluded
    )

    try
    {
        $siteLink = Get-ADReplicationSiteLink -Identity $Name -Properties Description -ErrorAction Stop
        $ensureResult = 'Present'
    }
    catch
    {
        $ensureResult = 'Absent'
        Write-Verbose -Message $PSItem
    }

    if ($siteLink.SitesIncluded)
    {
        $siteCommonNames = @()
        foreach ($siteDN in $siteLink.SitesIncluded)
        {
            $siteCommonNames += Resolve-SiteLinkName -SiteName $siteDn
        }
    }

    $returnValue = @{
        Name = $Name
        Cost = $siteLink.Cost
        Description = $siteLink.Description
        ReplicationFrequencyInMinutes = $siteLink.ReplicationFrequencyInMinutes
        SitesIncluded = $siteCommonNames
        SitesExcluded = $SitesExcluded
        Ensure = $ensureResult
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the desired configuration on an AD Replication Site Link.

    .PARAMETER Name
        Specifies the name of the AD Replication Site Link.

    .PARAMETER Cost
        Specifies the cost to be placed on the site link.

    .PARAMETER Description
        Specifies a description of the object.

    .PARAMETER ReplicationFrequencyInMinutes
        Specifies the frequency (in minutes) for which replication will occur where this site link is in use between sites.

    .PARAMETER SitesIncluded
        Specifies the list of sites included in the site link.

    .PARAMETER SitesExcluded
        Specifies the list of sites to remove from a site link.

    .PARAMETER Ensure
        Specifies if the site link is created or deleted.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.Int32]
        $Cost,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.Int32]
        $ReplicationFrequencyInMinutes,

        [Parameter()]
        [System.String[]]
        $SitesIncluded,

        [Parameter()]
        [System.String[]]
        $SitesExcluded,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    if ($Ensure -eq 'Present')
    {
        $desiredParameters = $PSBoundParameters
        $desiredParameters.Remove('Ensure')

        $currentADSiteLink = Get-TargetResource -Name $Name
        # since Set and New have different parameters we have to test if the site link exists to determine what cmdlet we need to use
        if ( $currentADSiteLink.Ensure -eq 'Absent' )
        {
            Write-Verbose -Message ($script:localizedData.NewSiteLink -f $Name)
            New-ADReplicationSiteLink @desiredParameters
        }
        else
        {
            # now we have to determine if we need to add or remove sites from SitesIncluded
            $setParameters = @{
                Identity = $Name
            }

            # build the SitesIncluded hashtable
            $sitesIncludedParameters = @{}
            if ($SitesExcluded)
            {
                Write-Verbose -Message ($script:localizedData.RemovingSites -f $($SiteExcluded -join ', '), $Name)
                $sitesIncludedParameters.Add('Remove', $($SitesExcluded))
            }

            if ($SitesIncluded)
            {
                Write-Verbose -Message ($script:localizedData.AddingSites -f $($SitesIncluded -join ', '), $Name)
                $sitesIncludedParameters.Add('Add', $($SitesIncluded))
            }

            if ($null -ne $($sitesIncludedParameters.Keys))
            {
                $setParameters.Add('SitesIncluded', $sitesIncludedParameters)
            }

            # add the rest of the parameteres
            foreach ($parameter in $PSBoundParameters.Keys)
            {
                if ($parameter -notmatch 'SitesIncluded|SitesExcluded|Name|Ensure')
                {
                    $setParameters.Add($parameter, $PSBoundParameters[$parameter])
                }
            }

            Set-ADReplicationSiteLink @setParameters
        }
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.RemoveSiteLink -f $Name)
        Remove-ADReplicationSiteLink -Identity $Name
    }
}

<#
    .SYNOPSIS
        Tests if the AD Replication Site Link is in a desired state.

    .PARAMETER Name
        Specifies the name of the AD Replication Site Link.

    .PARAMETER Cost
        Specifies the cost to be placed on the site link.

    .PARAMETER Description
        Specifies a description of the object.

    .PARAMETER ReplicationFrequencyInMinutes
        Specifies the frequency (in minutes) for which replication will occur where this site link is in use between sites.

    .PARAMETER SitesIncluded
        Specifies the list of sites included in the site link.

    .PARAMETER SitesExcluded
        Specifies the list of sites to remove from a site link.

    .PARAMETER Ensure
        Specifies if the site link is created or deleted.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.Int32]
        $Cost,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.Int32]
        $ReplicationFrequencyInMinutes,

        [Parameter()]
        [System.String[]]
        $SitesIncluded,

        [Parameter()]
        [System.String[]]
        $SitesExcluded,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $isCompliant = $true
    $currentSiteLink = Get-TargetResource -Name $Name
    # test for Ensure
    if ($Ensure -ne $currentSiteLink.Ensure)
    {
        return $false
    }

    # test for SitesIncluded
    foreach ($desiredIncludedSite in $SitesIncluded)
    {
        if ($desiredIncludedSite -notin $currentSiteLink.SitesIncluded)
        {
            Write-Verbose -Message ($script:localizedData.SiteNotFound -f $desiredIncludedSite, $($currentSiteLink.SitesIncluded -join ', '))
            $isCompliant = $false
        }
    }

    # test for SitesExcluded
    foreach ($desiredExcludedSite in $SitesExcluded)
    {
        if ($desiredExcludedSite -in $currentSiteLink.SitesIncluded)
        {
            Write-Verbose -Message ($script:localizedData.SiteFoundInExcluded -f $desiredExcludedSite, $($currentSiteLink.SitesIncluded -join ', '))
            $isCompliant = $false
        }
    }

    # test for Description|ReplicationFrequencyInMinutes|Cost
    foreach ($parameter in $PSBoundParameters.Keys)
    {
        if ($parameter -match 'Description|ReplicationFrequencyInMinutes|Cost')
        {
            if ($PSBoundParameters[$parameter] -ne $currentSiteLink[$parameter])
            {
                Write-Verbose -Message ($script:localizedData.PropertyNotInDesiredState -f $parameter,$($currentSiteLink[$parameter]),$($PSBoundParameters[$parameter]))
                $isCompliant = $false
            }
        }
    }

    return $isCompliant
}

<#
    .SYNOPSIS
        Resolves the AD replication site link distinguished names to short names

    .PARAMETER SiteName
        Specifies the distinguished name of a AD replication site link

    .EXAMPLE
        PS C:\> Resolve-SiteLinkName -SiteName 'CN=Site1,CN=Sites,CN=Configuration,DC=contoso,DC=com'
        Site1
#>
function Resolve-SiteLinkName
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCmdletCorrectly", "")]
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SiteName
    )

    $adSite = Get-ADReplicationSite -Identity $SiteName

    return $adSite.Name
}

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xADReplicationSiteLink'

Export-ModuleMember -Function *-TargetResource
