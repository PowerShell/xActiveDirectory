$resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$modulesFolderPath = Join-Path -Path $resourceModulePath -ChildPath 'Modules'

$dscResourceCommonModulePath = Join-Path -Path $modulesFolderPath -ChildPath 'DscResource.Common'
Import-Module -Name $dscResourceCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        Starts a process with a timeout.

    .DESCRIPTION
        The Start-ProcessWithTimeout function is used to start a process with a timeout. An Int32 object is returned
        representing the exit code of the started process.

    .EXAMPLE
        Start-ProcessWithTimeout -FilePath 'djoin.exe' -ArgumentList '/PROVISION /DOMAIN contoso.com /MACHINE SRV1' -Timeout 300

    .PARAMETER FilePath
        Specifies the path to the executable to start.

    .PARAMETER ArgumentList
        Specifies he arguments that should be passed to the executable.

    .PARAMETER Timeout
        Specifies the timeout in seconds to wait for the process to finish.

    .INPUTS
        None

    .OUTPUTS
        System.Int32
#>
function Start-ProcessWithTimeout
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $FilePath,

        [Parameter()]
        [System.String[]]
        $ArgumentList,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $Timeout
    )

    $startProcessParameters = @{
        FilePath     = $FilePath
        ArgumentList = $ArgumentList
        PassThru     = $true
        NoNewWindow  = $true
        ErrorAction  = 'Stop'
    }

    $process = Start-Process @startProcessParameters

    Write-Verbose -Message ($script:localizedData.StartProcess -f $process.Id, $FilePath, $Timeout) -Verbose

    Wait-Process -InputObject $process -Timeout $Timeout -ErrorAction 'Stop'

    return $process.ExitCode
}

<#
    .SYNOPSIS
        Tests whether this computer is a member of a domain.

    .DESCRIPTION
        The Test-DomainMember function is used to test whether this computer is a member of a domain. A boolean is
        returned indicating the domain membership of the computer.

    .EXAMPLE
        Test-DomainMember

    .INPUTS
        None

    .OUTPUTS
        System.Boolean
#>
function Test-DomainMember
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    $isDomainMember = [System.Boolean] (Get-CimInstance -ClassName Win32_ComputerSystem -Verbose:$false).PartOfDomain

    return $isDomainMember
}


<#
    .SYNOPSIS
        Gets the domain name of this computer.

    .DESCRIPTION
        The Get-DomainName function is used to get the name of the Active Directory domain that the computer is a
        member of.

    .EXAMPLE
        Get-DomainName

    .INPUTS
        None

    .OUTPUTS
        System.String
#>
function Get-DomainName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $domainName = [System.String] (Get-CimInstance -ClassName Win32_ComputerSystem -Verbose:$false).Domain

    return $domainName
}

<#
    .SYNOPSIS
        Get an Active Directory object's parent distinguished name.

    .DESCRIPTION
        The Get-ADObjectParentDN function is used to get an Active Directory object parent's distinguished name.

    .EXAMPLE
        Get-ADObjectParentDN -DN CN=User1,CN=Users,DC=contoso,DC=com

        Returns CN=Users,DC=contoso,DC=com

    .PARAMETER DN
        Specifies the distinguished name of the object to return the parent from.

    .INPUTS
        None

    .OUTPUTS
        System.String
#>
function Get-ADObjectParentDN
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DN
    )

    # https://www.uvm.edu/~gcd/2012/07/listing-parent-of-ad-object-in-powershell/
    $distinguishedNameParts = $DN -split '(?<![\\]),'
    return $distinguishedNameParts[1..$($distinguishedNameParts.Count - 1)] -join ','
}

<#
    .SYNOPSIS
        Assert the Members, MembersToInclude and MembersToExclude combination is valid.

    .DESCRIPTION
        The Assert-MemberParameters function is used to assert the Members, MembersToInclude and MembersToExclude
        combination is valid. If the combination is invalid, an InvalidArgumentError is raised.

    .EXAMPLE
        Assert-MemberParameters -Members fred, bill

    .PARAMETER Members
        Specifies the Members to validate.

    .PARAMETER MembersToInclude
        Specifies the MembersToInclude to validate.

    .PARAMETER MembersToExclude
        Specifies the MembersToExclude to validate.

    .INPUTS
        None

    .OUTPUTS
        None
#>
function Assert-MemberParameters
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String[]]
        $Members,

        [Parameter()]
        [ValidateNotNull()]
        [System.String[]]
        $MembersToInclude,

        [Parameter()]
        [ValidateNotNull()]
        [System.String[]]
        $MembersToExclude
    )

    if ($PSBoundParameters.ContainsKey('Members'))
    {
        if ($PSBoundParameters.ContainsKey('MembersToInclude') -or $PSBoundParameters.ContainsKey('MembersToExclude'))
        {
            # If Members are provided, Include and Exclude are not allowed.
            $errorMessage = $script:localizedData.MembersAndIncludeExcludeError -f 'Members', 'MembersToInclude', 'MembersToExclude'
            New-InvalidArgumentException -ArgumentName 'Members' -Message $errorMessage
        }
    }

    $MembersToInclude = Remove-DuplicateMembers -Members $MembersToInclude
    $MembersToExclude = Remove-DuplicateMembers -Members $MembersToExclude

    # Check if MembersToInclude and MembersToExclude have common principals.
    foreach ($member in $MembersToInclude)
    {
        if ($member -in $MembersToExclude)
        {
            $errorMessage = $script:localizedData.IncludeAndExcludeConflictError -f $member, 'MembersToInclude', 'MembersToExclude'
            New-InvalidArgumentException -ArgumentName 'MembersToInclude, MembersToExclude' -Message $errorMessage
        }
    }

}

<#
    .SYNOPSIS
        Removes duplicate members from a string array.

    .DESCRIPTION
        The Remove-DuplicateMembers function is used to remove duplicate members from a string array. The comparison
        is case insensitive. A string array is returned containing the resultant members.

    .EXAMPLE
        Remove-DuplicateMembers -Members fred, bill, bill

    .PARAMETER Members
        Specifies the array of members to remove duplicates from.

    .INPUTS
        None

    .OUTPUTS
        System.String[]
#>
function Remove-DuplicateMembers
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [System.String[]]
        $Members
    )

    if ($null -eq $Members -or $Members.Count -eq 0)
    {
        $uniqueMembers = @()
    }
    else
    {
        $uniqueMembers = @($members | Sort-Object -Unique)
    }

    <#
        Comma makes sure we return the string array as the correct type,
        and also makes sure one entry is returned as a string array.
    #>
    return , $uniqueMembers
}

<#
    .SYNOPSIS
        Tests Members of an array.

    .DESCRIPTION
        The Test-Members function is used to test whether the existing array members match the defined explicit array
        and include/exclude the specified members. A boolean is returned that represents if the existing array members
        match.

    .EXAMPLE
        Test-Members -ExistingMembers fred, bill -Members fred, bill

    .PARAMETER ExistingMembers
        Specifies existing array members.

    .PARAMETER Members
        Specifies explicit array members.

    .PARAMETER MembersToInclude
      Specifies compulsory array members.

    .PARAMETER MembersToExclude
       Specifies excluded array members.

    .INPUTS
        None

    .OUTPUTS
        System.Boolean
#>
function Test-Members
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.String[]]
        $ExistingMembers,

        [Parameter()]
        [AllowNull()]
        [System.String[]]
        $Members,

        [Parameter()]
        [AllowNull()]
        [System.String[]]
        $MembersToInclude,

        [Parameter()]
        [AllowNull()]
        [System.String[]]
        $MembersToExclude
    )

    if ($PSBoundParameters.ContainsKey('Members'))
    {
        if ($null -eq $Members -or (($Members.Count -eq 1) -and ($Members[0].Length -eq 0)))
        {
            $Members = @()
        }

        Write-Verbose ($script:localizedData.CheckingMembers -f 'Explicit')

        $Members = Remove-DuplicateMembers -Members $Members

        if ($ExistingMembers.Count -ne $Members.Count)
        {
            Write-Verbose -Message ($script:localizedData.MembershipCountMismatch -f $Members.Count, $ExistingMembers.Count)
            return $false
        }

        $isInDesiredState = $true

        foreach ($member in $Members)
        {
            if ($member -notin $ExistingMembers)
            {
                Write-Verbose -Message ($script:localizedData.MemberNotInDesiredState -f $member)
                $isInDesiredState = $false
            }
        }

        if (-not $isInDesiredState)
        {
            Write-Verbose -Message ($script:localizedData.MembershipNotDesiredState -f $member)
            return $false
        }
    } #end if $Members

    if ($PSBoundParameters.ContainsKey('MembersToInclude'))
    {
        if ($null -eq $MembersToInclude -or (($MembersToInclude.Count -eq 1) -and ($MembersToInclude[0].Length -eq 0)))
        {
            $MembersToInclude = @()
        }

        Write-Verbose -Message ($script:localizedData.CheckingMembers -f 'Included')

        $MembersToInclude = Remove-DuplicateMembers -Members $MembersToInclude

        $isInDesiredState = $true

        foreach ($member in $MembersToInclude)
        {
            if ($member -notin $ExistingMembers)
            {
                Write-Verbose -Message ($script:localizedData.MemberNotInDesiredState -f $member)
                $isInDesiredState = $false
            }
        }

        if (-not $isInDesiredState)
        {
            Write-Verbose -Message ($script:localizedData.MembershipNotDesiredState -f $member)
            return $false
        }
    } #end if $MembersToInclude

    if ($PSBoundParameters.ContainsKey('MembersToExclude'))
    {
        if ($null -eq $MembersToExclude -or (($MembersToExclude.Count -eq 1) -and ($MembersToExclude[0].Length -eq 0)))
        {
            $MembersToExclude = @()
        }

        Write-Verbose -Message ($script:localizedData.CheckingMembers -f 'Excluded')

        $MembersToExclude = Remove-DuplicateMembers -Members $MembersToExclude

        $isInDesiredState = $true

        foreach ($member in $MembersToExclude)
        {
            if ($member -in $ExistingMembers)
            {
                Write-Verbose -Message ($script:localizedData.MemberNotInDesiredState -f $member)
                $isInDesiredState = $false
            }
        }

        if (-not $isInDesiredState)
        {
            Write-Verbose -Message ($script:localizedData.MembershipNotDesiredState -f $member)
            return $false
        }
    } #end if $MembersToExclude

    Write-Verbose -Message $script:localizedData.MembershipInDesiredState
    return $true
}

<#
    .SYNOPSIS
        Converts a specified time period into a TimeSpan object.

    .DESCRIPTION
        The ConvertTo-TimeSpan function is used to convert a specified time period in seconds, minutes, hours or days
        into a TimeSpan object.

    .EXAMPLE
        ConvertTo-TimeSpan -TimeSpan 60 -TimeSpanType Minutes

    .PARAMETER TimeSpan
        Specifies the length of time to use for the time span.

    .PARAMETER TimeSpanType
        Specifies the units of measure in the TimeSpan parameter.

    .INPUTS
        None

    .OUTPUTS
        System.TimeSpan
#>
function ConvertTo-TimeSpan
{
    [CmdletBinding()]
    [OutputType([System.TimeSpan])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.UInt32]
        $TimeSpan,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Seconds', 'Minutes', 'Hours', 'Days')]
        [System.String]
        $TimeSpanType
    )

    $newTimeSpanParams = @{}

    switch ($TimeSpanType)
    {
        'Seconds'
        {
            $newTimeSpanParams['Seconds'] = $TimeSpan
        }

        'Minutes'
        {
            $newTimeSpanParams['Minutes'] = $TimeSpan
        }

        'Hours'
        {
            $newTimeSpanParams['Hours'] = $TimeSpan
        }

        'Days'
        {
            $newTimeSpanParams['Days'] = $TimeSpan
        }
    }
    return (New-TimeSpan @newTimeSpanParams)
}

<#
    .SYNOPSIS
        Converts a TimeSpan object into the number of seconds, minutes, hours or days.

    .DESCRIPTION
        The ConvertFrom-TimeSpan function is used to Convert a TimeSpan object into an Integer containing the number of
        seconds, minutes, hours or days within the timespan.

    .EXAMPLE
        ConvertFrom-TimeSpan -TimeSpan (New-TimeSpan -Days 15) -TimeSpanType Seconds

        Returns the number of seconds in 15 days.

    .PARAMETER TimeSpan
        Specifies the TimeSpan object to convert into an integer.

    .PARAMETER TimeSpanType
        Specifies the unit of measure to be used in the conversion.

    .INPUTS
        None

    .OUTPUTS
        System.Int32
#>
function ConvertFrom-TimeSpan
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.TimeSpan]
        $TimeSpan,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Seconds', 'Minutes', 'Hours', 'Days')]
        [System.String]
        $TimeSpanType
    )

    switch ($TimeSpanType)
    {
        'Seconds'
        {
            return $TimeSpan.TotalSeconds -as [System.UInt32]
        }
        'Minutes'
        {
            return $TimeSpan.TotalMinutes -as [System.UInt32]
        }
        'Hours'
        {
            return $TimeSpan.TotalHours -as [System.UInt32]
        }
        'Days'
        {
            return $TimeSpan.TotalDays -as [System.UInt32]
        }
    }
} #end function ConvertFrom-TimeSpan

<#
    .SYNOPSIS
        Gets a common AD cmdlet connection parameter for splatting.

    .DESCRIPTION
        The Get-ADCommonParameters function is used to get a common AD cmdlet connection parameter for splatting. A
        hashtable is returned containing the derived connection parameters.

    .PARAMETER Identity
        Specifies the identity to use as the Identity or Name connection parameter. Aliases are 'UserName',
        'GroupName', 'ComputerName' and 'ServiceAccountName'.

    .PARAMETER CommonName
        When specified, a CommonName overrides the Identity used as the Name key. For example, the Get-ADUser,
        Set-ADUser and Remove-ADUser cmdlets take an Identity parameter, but the New-ADUser cmdlet uses the Name
        parameter.

    .PARAMETER Credential
        Specifies the credentials to use when accessing the domain, or use the current user if not specified.

    .PARAMETER Server
        Specifies the name of the domain controller to use when accessing the domain. If not specified, a domain
        controller is discovered using the standard Active Directory discovery process.

    .PARAMETER UseNameParameter
        Specifies to return the Identity as the Name key. For example, the Get-ADUser, Set-ADUser and Remove-ADUser
        cmdlets take an Identity parameter, but the New-ADUser cmdlet uses the Name parameter.

    .PARAMETER PreferCommonName
        If specified along with a CommonName parameter, The CommonName will be used as the Identity or Name connection
        parameter instead of the Identity parameter.

    .EXAMPLE
        Get-CommonADParameters @PSBoundParameters

        Returns connection parameters suitable for Get-ADUser using the splatted cmdlet parameters.

    .EXAMPLE
        Get-CommonADParameters @PSBoundParameters -UseNameParameter

        Returns connection parameters suitable for New-ADUser using the splatted cmdlet parameters.

    .INPUTS
        None

    .OUTPUTS
        System.Collections.Hashtable
#>
function Get-ADCommonParameters
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('UserName', 'GroupName', 'ComputerName', 'ServiceAccountName', 'Name')]
        [System.String]
        $Identity,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CommonName,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('DomainController')]
        [System.String]
        $Server,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $UseNameParameter,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PreferCommonName,

        # Catch all to enable splatted $PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )

    if ($UseNameParameter)
    {
        if ($PreferCommonName -and ($PSBoundParameters.ContainsKey('CommonName')))
        {
            $adConnectionParameters = @{
                Name = $CommonName
            }
        }
        else
        {
            $adConnectionParameters = @{
                Name = $Identity
            }
        }
    }
    else
    {
        if ($PreferCommonName -and ($PSBoundParameters.ContainsKey('CommonName')))
        {
            $adConnectionParameters = @{
                Identity = $CommonName
            }
        }
        else
        {
            $adConnectionParameters = @{
                Identity = $Identity
            }
        }
    }

    if ($Credential)
    {
        $adConnectionParameters['Credential'] = $Credential
    }

    if ($Server)
    {
        $adConnectionParameters['Server'] = $Server
    }

    return $adConnectionParameters
}

<#
    .SYNOPSIS
        Tests Active Directory replication site availablity.

    .DESCRIPTION
        The Test-ADReplicationSite function is used to test Active Directory replication site availablity. A boolean is
        returned that represents the replication site availability.

    .EXAMPLE
        Test-ADReplicationSite -SiteName Default -DomainName contoso.com

    .PARAMETER SiteName
        Specifies the replication site name to test the availability of.

    .PARAMETER DomainName
        Specifies the domain name containing the replication site.

    .PARAMETER Credential
        Specifies the credentials to use when accessing the domain, or use the current user if not specified.

    .INPUTS
        None

    .OUTPUTS
        System.Boolean
#>
function Test-ADReplicationSite
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SiteName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Write-Verbose -Message ($script:localizedData.CheckingSite -f $SiteName)

    $existingDC = "$((Get-ADDomainController -Discover -DomainName $DomainName -ForceDiscover).HostName)"

    try
    {
        $site = Get-ADReplicationSite -Identity $SiteName -Server $existingDC -Credential $Credential
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        return $false
    }

    return ($null -ne $site)
}

<#
    .SYNOPSIS
        Converts a ModeId or ADForestMode object to a ForestMode object.

    .DESCRIPTION
        The ConvertTo-DeploymentForestMode function is used to convert a
        Microsoft.ActiveDirectory.Management.ADForestMode object or a ModeId to a
        Microsoft.DirectoryServices.Deployment.Types.ForestMode object.

    .EXAMPLE
        ConvertTo-DeploymentForestMode -Mode $adForestMode

    .PARAMETER ModeId
        Specifies the ModeId value to convert to a Microsoft.DirectoryServices.Deployment.Types.ForestMode type.

    .PARAMETER Mode
        Specifies the Microsoft.ActiveDirectory.Management.ADForestMode value to convert to a
        Microsoft.DirectoryServices.Deployment.Types.ForestMode type.

    .INPUTS
        None

    .OUTPUTS
        Microsoft.DirectoryServices.Deployment.Types.ForestMode
#>
function ConvertTo-DeploymentForestMode
{
    [CmdletBinding()]
    [OutputType([Microsoft.DirectoryServices.Deployment.Types.ForestMode])]
    param
    (
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ById')]
        [System.UInt16]
        $ModeId,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ByName')]
        [AllowNull()]
        [System.Nullable``1[Microsoft.ActiveDirectory.Management.ADForestMode]]
        $Mode
    )

    $convertedMode = $null

    if ($PSCmdlet.ParameterSetName -eq 'ByName' -and $Mode)
    {
        $convertedMode = $Mode -as [Microsoft.DirectoryServices.Deployment.Types.ForestMode]
    }

    if ($PSCmdlet.ParameterSetName -eq 'ById')
    {
        $convertedMode = $ModeId -as [Microsoft.DirectoryServices.Deployment.Types.ForestMode]
    }

    if ([enum]::GetValues([Microsoft.DirectoryServices.Deployment.Types.ForestMode]) -notcontains $convertedMode)
    {
        return $null
    }

    return $convertedMode
}

<#
    .SYNOPSIS
        Converts a ModeId or ADDomainMode object to a DomainMode object.

    .DESCRIPTION
        The ConvertTo-DeploymentDomainMode function is used to convert a
        Microsoft.ActiveDirectory.Management.ADDomainMode object or a ModeId to a
        Microsoft.DirectoryServices.Deployment.Types.DomainMode object.

    .EXAMPLE
        ConvertTo-DeploymentDomainMode -Mode $adDomainMode

    .PARAMETER ModeId
        Specifies the ModeId value to convert to a Microsoft.DirectoryServices.Deployment.Types.DomainMode type.

    .PARAMETER Mode
        Specifies the Microsoft.ActiveDirectory.Management.ADDomainMode value to convert to a
        Microsoft.DirectoryServices.Deployment.Types.DomainMode type.

    .INPUTS
        None

    .OUTPUTS
        Microsoft.DirectoryServices.Deployment.Types.DomainMode
#>
function ConvertTo-DeploymentDomainMode
{
    [CmdletBinding()]
    [OutputType([Microsoft.DirectoryServices.Deployment.Types.DomainMode])]
    param
    (
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ById')]
        [System.UInt16]
        $ModeId,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ByName')]
        [AllowNull()]
        [System.Nullable``1[Microsoft.ActiveDirectory.Management.ADDomainMode]]
        $Mode
    )

    $convertedMode = $null

    if ($PSCmdlet.ParameterSetName -eq 'ByName' -and $Mode)
    {
        $convertedMode = $Mode -as [Microsoft.DirectoryServices.Deployment.Types.DomainMode]
    }

    if ($PSCmdlet.ParameterSetName -eq 'ById')
    {
        $convertedMode = $ModeId -as [Microsoft.DirectoryServices.Deployment.Types.DomainMode]
    }

    if ([enum]::GetValues([Microsoft.DirectoryServices.Deployment.Types.DomainMode]) -notcontains $convertedMode)
    {
        return $null
    }

    return $convertedMode
}

<#
    .SYNOPSIS
        Restores an AD object from the AD recyle bin.

    .DESCRIPTION
        The Restore-ADCommonObject function is used to Restore an AD object from the AD recyle bin. An ADObject is
        returned that represents the restored object.

    .EXAMPLE
        Restore-ADCommonObject -Identity User1 -ObjectClass User

    .PARAMETER Identity
        Specifies the identity of the object to restore.

    .PARAMETER ObjectClass
        Specifies the type of the AD object to restore.

    .PARAMETER Credential
        Specifies the credentials to use when accessing the domain, or use the current user if not specified.

    .PARAMETER Server
        Specifies the name of the domain controller to use when accessing the domain. If not specified, a domain
        controller is discovered using the standard Active Directory discovery process.

    .INPUTS
        None

    .OUTPUTS
        Microsoft.ActiveDirectory.Management.ADObject
#>
function Restore-ADCommonObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('UserName', 'GroupName', 'ComputerName', 'ServiceAccountName')]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Computer', 'OrganizationalUnit', 'User', 'Group')]
        [System.String]
        $ObjectClass,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('DomainController')]
        [System.String]
        $Server
    )

    $restoreFilter = 'msDS-LastKnownRDN -eq "{0}" -and objectClass -eq "{1}" -and isDeleted -eq $true' -f
    $Identity, $ObjectClass
    Write-Verbose -Message ($script:localizedData.FindInRecycleBin -f $restoreFilter) -Verbose

    <#
        Using IsDeleted and IncludeDeletedObjects will mean that the cmdlet does not throw
        any more, and simply returns $null instead
    #>
    $commonParams = Get-ADCommonParameters @PSBoundParameters
    $getAdObjectParams = $commonParams.Clone()
    $getAdObjectParams.Remove('Identity')
    $getAdObjectParams['Filter'] = $restoreFilter
    $getAdObjectParams['IncludeDeletedObjects'] = $true
    $getAdObjectParams['Properties'] = @('whenChanged')

    # If more than one object is returned, we pick the one that was changed last.
    $restorableObject = Get-ADObject @getAdObjectParams |
        Sort-Object -Descending -Property 'whenChanged' |
            Select-Object -First 1

    $restoredObject = $null

    if ($restorableObject)
    {
        Write-Verbose -Message ($script:localizedData.FoundRestoreTargetInRecycleBin -f
            $Identity, $ObjectClass, $restorableObject.DistinguishedName) -Verbose

        try
        {
            $restoreParams = $commonParams.Clone()
            $restoreParams['PassThru'] = $true
            $restoreParams['ErrorAction'] = 'Stop'
            $restoreParams['Identity'] = $restorableObject.DistinguishedName
            $restoredObject = Restore-ADObject @restoreParams

            Write-Verbose -Message ($script:localizedData.RecycleBinRestoreSuccessful -f
                $Identity, $ObjectClass) -Verbose
        }
        catch [Microsoft.ActiveDirectory.Management.ADException]
        {
            # After Get-TargetResource is through, only one error can occur here: Object parent does not exist
            $errorMessage = $script:localizedData.RecycleBinRestoreFailed -f $Identity, $ObjectClass
            New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
        }
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.NoObjectFoundInRecycleBin) -Verbose
    }

    return $restoredObject
}

<#
    .SYNOPSIS
        Converts an Active Directory distinguished name into a fully qualified domain name.

    .DESCRIPTION
        The Get-ADDomainNameFromDistinguishedName function is used to convert an Active Directory distinguished name
        into a fully qualified domain name.

    .EXAMPLE
        Get-ADDomainNameFromDistinguishedName -DistinguishedName 'CN=ExampleObject,OU=ExampleOU,DC=example,DC=com'

    .PARAMETER DistinguishedName
        Specifies the distinguished name to convert into the FQDN.

    .INPUTS
        None

    .OUTPUTS
        System.String

    .NOTES
        Author: Robert D. Biddle (https://github.com/RobBiddle)
#>
function Get-ADDomainNameFromDistinguishedName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.String]
        $DistinguishedName
    )

    if ($DistinguishedName -notlike '*DC=*')
    {
        return
    }

    $splitDistinguishedName = ($DistinguishedName -split 'DC=')
    $splitDistinguishedNameParts = $splitDistinguishedName[1..$splitDistinguishedName.Length]
    $domainFqdn = ''

    foreach ($part in $splitDistinguishedNameParts)
    {
        $domainFqdn += "DC=$part"
    }

    $domainName = $domainFqdn -replace 'DC=', '' -replace ',', '.'

    return $domainName

}

<#
    .SYNOPSIS
        Sets a member of an AD group by adding or removing its membership.

    .DESCRIPTION
        The Set-ADCommonGroupMember function is used to add a member from the current or a different domain to or remove
        it from an AD group.

    .EXAMPLE
        Set-ADCommonGroupMember -Members 'cn=user1,cn=users,dc=contoso,dc=com' -MembershipAttribute 'DistinguishedName' -Parameters @{Identity='cn=group1,cn=users,dc=contoso,dc=com'}

    .PARAMETER Members
        Specifies the members to add to or remove from the group. These may be in the same domain as the group or in
        alternate domains.

    .PARAMETER MembershipAttribute
        Specifies the Active Directory attribute for the values of the Members parameter.
        Default value is 'SamAccountName'.

    .PARAMETER Parameters
        Specifies the parameters to pass to the Resolve-MembersSecurityIdentifier and Set-ADGroup cmdlets when adding
        the members to the group. This should include the group Identity as well as Server and/or Credential.

    .PARAMETER Action
        Specifies what group membership action to take. Valid options are 'Add' and 'Remove'.
        Default value is 'Add'.

    .INPUTS
        None

    .OUTPUTS
        None

    .NOTES
        Author original code: Robert D. Biddle (https://github.com/RobBiddle)
        Author refactored code: Jan-Hendrik Peters (https://github.com/nyanhp)
        Author refactored code: Jeremy Ciak (https://github.com/jeremyciak)
#>
function Set-ADCommonGroupMember
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String[]]
        $Members,

        [Parameter()]
        [ValidateSet('SamAccountName', 'DistinguishedName', 'SID', 'ObjectGUID')]
        [System.String]
        $MembershipAttribute = 'SamAccountName',

        [Parameter()]
        [System.Collections.Hashtable]
        $Parameters,

        [Parameter()]
        [ValidateSet('Add', 'Remove')]
        [System.String]
        $Action = 'Add'
    )

    Write-Debug 'Entering Set-ADCommonGroupMember'

    Assert-Module -ModuleName ActiveDirectory

    $setADGroupParameters = $Parameters.Clone()

    $resolveMembersSecurityIdentifierParms = @{
        MembershipAttribute  = $MembershipAttribute
        Parameters           = $Parameters
        PrepareForMembership = $true
        ErrorAction          = 'Stop'
    }

    $setADGroupParameters[$Action] = @{
        member = $Members | Resolve-MembersSecurityIdentifier @resolveMembersSecurityIdentifierParms
    }

    try
    {
        Set-ADGroup @setADGroupParameters -ErrorAction 'Stop'
    }
    catch
    {
        $errorMessage = $script:localizedData.FailedToSetADGroupMembership -f $Parameters['Identity']
        New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
    }
}

<#
    .SYNOPSIS
        Gets the domain controller object if the node is a domain controller.

    .DESCRIPTION
        The Get-DomainControllerObject function is used to get the domain controller object if the node is a domain
        controller, otherwise it returns $null.

    .EXAMPLE
        Get-DomainControllerObject -DomainName contoso.com

    .PARAMETER DomainName
        Specifies the name of the domain that should contain the domain controller.

    .PARAMETER ComputerName
        Specifies the name of the node to return the domain controller object for.

    .PARAMETER Credential
        Specifies the credentials to use when accessing the domain, or use the current user if not specified.

    .INPUTS
        None

    .OUTPUTS
        Microsoft.ActiveDirectory.Management.ADDomainController

    .NOTES
        Throws an exception of Microsoft.ActiveDirectory.Management.ADServerDownException if the domain cannot be
        contacted.
#>
function Get-DomainControllerObject
{
    [CmdletBinding()]
    [OutputType([Microsoft.ActiveDirectory.Management.ADDomainController])]

    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter()]
        [System.String]
        $ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    <#
        It is not possible to use `-ErrorAction 'SilentlyContinue` on the
        cmdlet Get-ADDomainController, it will throw an error regardless.
    #>
    try
    {
        $getADDomainControllerParameters = @{
            Filter = 'Name -eq "{0}"' -f $ComputerName
            Server = $DomainName
        }

        if ($PSBoundParameters.ContainsKey('Credential'))
        {
            $getADDomainControllerParameters['Credential'] = $Credential
        }

        $domainControllerObject = Get-ADDomainController @getADDomainControllerParameters

        if (-not $domainControllerObject -and (Test-IsDomainController) -eq $true)
        {
            $errorMessage = $script:localizedData.WasExpectingDomainController
            New-InvalidResultException -Message $errorMessage
        }
    }
    catch
    {
        $errorMessage = $script:localizedData.FailedEvaluatingDomainController
        New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
    }

    return $domainControllerObject
}

<#
    .SYNOPSIS
        Tests if the computer is a domain controller.

    .DESCRIPTION
        The Test-IsDomainController function tests if the computer is a domain controller. A boolean is returned that
        represents whether the computer is a domain controller.

    .EXAMPLE
        Test-IsDomainController

    .INPUTS
        None

    .OUTPUTS
        System.Boolean
#>
function Test-IsDomainController
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    $operatingSystemInformation = Get-CimInstance -ClassName 'Win32_OperatingSystem'

    return $operatingSystemInformation.ProductType -eq 2
}

<#
    .SYNOPSIS
        Converts a hashtable containing the parameter to property mappings to an array of properties.

    .DESCRIPTION
        The Convert-PropertyMapToObjectProperties function is used to convert a hashtable containing the parameter to
        property mappings to an array of properties that can be used to call cmdlets that supports the parameter
        Properties.

    .EXAMPLE
        Convert-PropertyMapToObjectProperties -PropertyMap $computerObjectPropertyMap

    .PARAMETER PropertyMap
        Specifies the property map, as an array of hashtables, to convert to a properties array.

    .INPUTS
        None

    .OUTPUTS
        System.Array
#>
function Convert-PropertyMapToObjectProperties
{
    [CmdletBinding()]
    [OutputType([System.Array])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Array]
        $PropertyMap
    )

    $objectProperties = @()

    # Create an array of the AD property names to retrieve from the property map
    foreach ($property in $PropertyMap)
    {
        if ($property -isnot [System.Collections.Hashtable])
        {
            $errorMessage = $script:localizedData.PropertyMapArrayIsWrongType
            New-InvalidOperationException -Message $errorMessage
        }

        if ($property.ContainsKey('PropertyName'))
        {
            $objectProperties += @($property.PropertyName)
        }
        else
        {
            $objectProperties += $property.ParameterName
        }
    }

    return $objectProperties
}

<#
    .SYNOPSIS
        Compares current and desired values for any DSC resource.

    .DESCRIPTION
        The Compare-ResourcePropertyState function is used to compare current and desired values for any DSC resource,
        and return a hashtable with the result of the comparison. An array of hashtables is returned containing the
        results of the comparison with the following properties:

        - ParameterName - The name of the parameter
        - Expected - The expected value of the parameter
        - Actual - The actual value of the parameter

    .EXAMPLE
        Compare-ResourcePropertyState -CurrentValues $targetResource -DesiredValues $PSBoundParameters

    .PARAMETER CurrentValues
        Specifies the current values that should be compared to to desired values. Normally the values returned from
        Get-TargetResource.

    .PARAMETER DesiredValues
        Specifies the values set in the configuration and is provided in the call to the functions *-TargetResource,
        and that will be compared against current values. Normally set to $PSBoundParameters.

    .PARAMETER Properties
        Specifies an array of property names, from the keys provided in DesiredValues, that will be compared. If this
        parameter is not set, all the keys in the DesiredValues will be compared.

    .PARAMETER IgnoreProperties
        Specifies an array of property names to ignore in the comparison.

    .INPUTS
        None

    .OUTPUTS
        System.Collections.Hashtable[]
#>
function Compare-ResourcePropertyState
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $CurrentValues,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DesiredValues,

        [Parameter()]
        [System.String[]]
        $Properties,

        [Parameter()]
        [System.String[]]
        $IgnoreProperties
    )

    if ($PSBoundParameters.ContainsKey('Properties'))
    {
        # Filter out the parameters (keys) not specified in Properties
        $desiredValuesToRemove = $DesiredValues.Keys |
            Where-Object -FilterScript {
                $_ -notin $Properties
            }

        $desiredValuesToRemove |
            ForEach-Object -Process {
                $DesiredValues.Remove($_)
            }
    }
    else
    {
        <#
            Remove any common parameters that might be part of DesiredValues,
            if it $PSBoundParameters was used to pass the desired values.
        #>
        $commonParametersToRemove = $DesiredValues.Keys |
            Where-Object -FilterScript {
                $_ -in [System.Management.Automation.PSCmdlet]::CommonParameters `
                    -or $_ -in [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
            }

        $commonParametersToRemove |
            ForEach-Object -Process {
                $DesiredValues.Remove($_)
            }
    }

    # Remove any properties that should be ignored.
    if ($PSBoundParameters.ContainsKey('IgnoreProperties'))
    {
        $IgnoreProperties |
            ForEach-Object -Process {
                if ($DesiredValues.ContainsKey($_))
                {
                    $DesiredValues.Remove($_)
                }
            }
    }

    $compareTargetResourceStateReturnValue = @()

    foreach ($parameterName in $DesiredValues.Keys)
    {
        Write-Verbose -Message ($script:localizedData.EvaluatePropertyState -f $parameterName) -Verbose

        $parameterState = @{
            ParameterName = $parameterName
            Expected      = $DesiredValues.$parameterName
            Actual        = $CurrentValues.$parameterName
        }

        # Check if the parameter is in compliance.
        $isPropertyInDesiredState = Test-DscPropertyState -Values @{
            CurrentValue = $CurrentValues.$parameterName
            DesiredValue = $DesiredValues.$parameterName
        }

        if ($isPropertyInDesiredState)
        {
            Write-Verbose -Message ($script:localizedData.PropertyInDesiredState -f $parameterName) -Verbose

            $parameterState['InDesiredState'] = $true
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.PropertyNotInDesiredState -f $parameterName) -Verbose

            $parameterState['InDesiredState'] = $false
        }

        $compareTargetResourceStateReturnValue += $parameterState
    }

    return $compareTargetResourceStateReturnValue
}

<#
    .SYNOPSIS
        Compares the current and the desired value of a property.

    .DESCRIPTION
        The Test-DscPropertyState function is used to compare the current and the desired value of a property. A
        boolean is returned that represents the result of the comparison.

    .EXAMPLE
        Test-DscPropertyState -Values @{CurrentValue = 'John'; DesiredValue = 'Alice'}

    .EXAMPLE
        Test-DscPropertyState -Values @{CurrentValue = 1; DesiredValue = 2}

    .PARAMETER Values
        Specifies a hash table with the current value (the CurrentValue key) and desired value (the DesiredValue key).

    .INPUTS
        None

    .OUTPUTS
        System.Boolean
#>
function Test-DscPropertyState
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Values
    )

    if ($null -eq $Values.CurrentValue -and $null -eq $Values.DesiredValue)
    {
        # Both values are $null so return $true
        $returnValue = $true
    }
    elseif ($null -eq $Values.CurrentValue -or $null -eq $Values.DesiredValue)
    {
        # Either CurrentValue or DesiredValue are $null so return $false
        $returnValue = $false
    }
    elseif ($Values.DesiredValue.GetType().IsArray -or $Values.CurrentValue.GetType().IsArray)
    {
        $compareObjectParameters = @{
            ReferenceObject  = $Values.CurrentValue
            DifferenceObject = $Values.DesiredValue
        }

        $arrayCompare = Compare-Object @compareObjectParameters

        if ($null -ne $arrayCompare)
        {
            Write-Verbose -Message $script:localizedData.ArrayDoesNotMatch -Verbose

            $arrayCompare |
                ForEach-Object -Process {
                    Write-Verbose -Message ($script:localizedData.ArrayValueThatDoesNotMatch -f `
                            $_.InputObject, $_.SideIndicator) -Verbose
                }

            $returnValue = $false
        }
        else
        {
            $returnValue = $true
        }
    }
    elseif ($Values.CurrentValue -ne $Values.DesiredValue)
    {
        $desiredType = $Values.DesiredValue.GetType()

        $returnValue = $false

        $supportedTypes = @(
            'String'
            'Int32'
            'UInt32'
            'Int16'
            'UInt16'
            'Single'
            'Boolean'
        )

        if ($desiredType.Name -notin $supportedTypes)
        {
            Write-Warning -Message ($script:localizedData.UnableToCompareType -f $desiredType.Name)
        }
        else
        {
            Write-Verbose -Message (
                $script:localizedData.PropertyValueOfTypeDoesNotMatch `
                    -f $desiredType.Name, $Values.CurrentValue, $Values.DesiredValue
            ) -Verbose
        }
    }
    else
    {
        $returnValue = $true
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Asserts if the AD PS Provider has been installed.

    .DESCRIPTION
        The Assert-ADPSProvider function is used to assert if the AD PS Provider has been installed.

    .Example
        Assert-ADPSProvider

    .INPUTS
        None

    .OUTPUTS
        None

    .NOTES
        Attempts to force import the ActiveDirectory module if the AD PS Provider has not been installed and throws an
        exception if the AD PS Provider cannot be installed.
#>

function Assert-ADPSProvider
{
    [CmdletBinding()]
    param ()

    $activeDirectoryPSProvider = Get-PSProvider -PSProvider 'ActiveDirectory' -ErrorAction SilentlyContinue

    if ($null -eq $activeDirectoryPSProvider)
    {
        Write-Verbose -Message $script:localizedData.AdPsProviderNotFound -Verbose
        Import-Module -Name 'ActiveDirectory' -Force
        try
        {
            $activeDirectoryPSProvider = Get-PSProvider -PSProvider 'ActiveDirectory'
        }
        catch
        {
            $errorMessage = $script:localizedData.AdPsProviderInstallFailureError
            New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
        }
    }
}

<#
    .SYNOPSIS
        Asserts if the AD PS Drive has been created, and creates one if not.

    .DESCRIPTION
        The Assert-ADPSDrive function is used to assert if the AD PS Drive has been created, and creates one if not.

    .EXAMPLE
        Assert-ADPSDrive

    .PARAMETER Root
        Specifies the AD path to which the drive is mapped.

    .INPUTS
        None

    .OUTPUTS
        None

    .NOTES
        Throws an exception if the PS Drive cannot be created.
#>
function Assert-ADPSDrive
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Root = '//RootDSE/'
    )

    Assert-Module -ModuleName 'ActiveDirectory'

    Assert-ADPSProvider

    $activeDirectoryPSDrive = Get-PSDrive -Name AD -ErrorAction SilentlyContinue

    if ($null -eq $activeDirectoryPSDrive)
    {
        Write-Verbose -Message $script:localizedData.CreatingNewADPSDrive -Verbose

        try
        {
            New-PSDrive -Name AD -PSProvider 'ActiveDirectory' -Root $Root -Scope Global -ErrorAction 'Stop' |
                Out-Null
        }
        catch
        {
            $errorMessage = $script:localizedData.CreatingNewADPSDriveError
            New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
        }
    }
}

<#
    .SYNOPSIS
        Creates a new MSFT_Credential CIM instance credential object.

    .Description
        The New-CimCredentialInstance function is used to create a new MSFT_Credential CIM instance credential object
        to be used when returning credential objects from Get-TargetResource. This creates a credential object without
        the password.

    .EXAMPLE
        New-CimCredentialInstance -Credential $Cred

    .PARAMETER Credential
        Specifies the PSCredential object to return as a MSFT_Credential CIM instance credential object.

    .INPUTS
        None

    .OUTPUTS
        Microsoft.Management.Infrastructure.CimInstance

    .NOTES
        When returning a PSCredential object from Get-TargetResource, the credential object does not contain the
        username. The object is empty.

        | Password | UserName | PSComputerName |
        | -------- | -------- | -------------- |
        |          |          | localhost      |

        When the MSFT_Credential CIM instance credential object is returned by the Get-TargetResource then the
        credential object contains the values provided in the object.

        | Password | UserName           | PSComputerName |
        | -------- | ------------------ | -------------- |
        |          |COMPANY\TestAccount | localhost      |
#>
function New-CimCredentialInstance
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    $newCimInstanceParameters = @{
        ClassName  = 'MSFT_Credential'
        ClientOnly = $true
        Namespace  = 'root/microsoft/windows/desiredstateconfiguration'
        Property   = @{
            UserName = [System.String] $Credential.UserName
            Password = [System.String] $null
        }
    }

    return New-CimInstance @newCimInstanceParameters
}

<#
    .SYNOPSIS
        Adds the assembly to the PowerShell session.

    .DESCRIPTION
        The Add-TypeAssembly function is used to Add the assembly to the PowerShell session, optionally after a check
        if the type is missing.

    .EXAMPLE
        Add-TypeAssembly -AssemblyName 'System.DirectoryServices.AccountManagement' -TypeName 'System.DirectoryServices.AccountManagement.PrincipalContext'

    .PARAMETER AssemblyName
        Specifies the assembly to load into the PowerShell session.

    .PARAMETER TypeName
        Specifies an optional parameter to check if the type exist, if it exist then the assembly is not loaded again.

    .INPUTS
        None

    .OUTPUTS
        None
#>
function Add-TypeAssembly
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $AssemblyName,

        [Parameter()]
        [System.String]
        $TypeName
    )

    if ($PSBoundParameters.ContainsKey('TypeName'))
    {
        if ($TypeName -as [Type])
        {
            Write-Verbose -Message ($script:localizedData.TypeAlreadyExistInSession -f $TypeName) -Verbose

            # The type already exists so no need to load the type again.
            return
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.TypeDoesNotExistInSession -f $TypeName) -Verbose
        }
    }

    try
    {
        Write-Verbose -Message ($script:localizedData.AddingAssemblyToSession -f $AssemblyName) -Verbose

        Add-Type -AssemblyName $AssemblyName
    }
    catch
    {
        $missingRoleMessage = $script:localizedData.CouldNotLoadAssembly -f $AssemblyName
        New-ObjectNotFoundException -Message $missingRoleMessage -ErrorRecord $_
    }
}

<#
    .SYNOPSIS
        Gets an Active Directory DirectoryContext object.

    .Description
        The Get-ADDirectoryContext function is used to get an Active Directory DirectoryContext object that represents
        the desired context.

    .EXAMPLE
        Get-ADDirectoryContext -DirectoryContextType 'Forest' -Name contoso.com

    .PARAMETER DirectoryContextType
        Specifies the context type of the object to return. Valid values are 'Domain', 'Forest',
        'ApplicationPartition', 'ConfigurationSet' or 'DirectoryServer'.

    .PARAMETER Name
        An optional parameter for the target of the directory context. For the correct format for this parameter
        depending on context type, see the article
        https://docs.microsoft.com/en-us/dotnet/api/system.directoryservices.activedirectory.directorycontext?view=netframework-4.8

    .PARAMETER Credential
        Specifies the credentials to use when accessing the domain, or use the current user if not specified.

    .INPUTS
        None

    .OUTPUTS
        System.DirectoryServices.ActiveDirectory.DirectoryContext
#>
function Get-ADDirectoryContext
{
    [CmdletBinding()]
    [OutputType([System.DirectoryServices.ActiveDirectory.DirectoryContext])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Domain', 'Forest', 'ApplicationPartition', 'ConfigurationSet', 'DirectoryServer')]
        [System.String]
        $DirectoryContextType,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    $typeName = 'System.DirectoryServices.ActiveDirectory.DirectoryContext'

    Add-TypeAssembly -AssemblyName 'System.DirectoryServices' -TypeName $typeName

    Write-Verbose -Message ($script:localizedData.NewDirectoryContext -f $DirectoryContextType) -Verbose

    $newObjectArgumentList = @(
        $DirectoryContextType
    )

    if ($PSBoundParameters.ContainsKey('Name'))
    {
        Write-Verbose -Message ($script:localizedData.NewDirectoryContextTarget -f $Name) -Verbose

        $newObjectArgumentList += @(
            $Name
        )
    }

    if ($PSBoundParameters.ContainsKey('Credential'))
    {
        Write-Verbose -Message ($script:localizedData.NewDirectoryContextCredential -f $Credential.UserName) -Verbose

        $newObjectArgumentList += @(
            $Credential.UserName
            $Credential.GetNetworkCredential().Password
        )
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.NewDirectoryContextCredential -f (Get-CurrentUser).Name) -Verbose
    }

    $newObjectParameters = @{
        TypeName     = $typeName
        ArgumentList = $newObjectArgumentList
    }

    return New-Object @newObjectParameters
}

<#
    .SYNOPSIS
        Finds an Active Directory domain controller.

    .DESCRIPTION
        The Find-DomainController function is used to find an Active Directory domain controller. It returns a
        DomainController object that represents the found domain controller.

    .EXAMPLE
        Find-DomainController -DomainName contoso.com -SiteName Default -WaitForValidCredentials

    .PARAMETER DomainName
        Specifies the fully qualified domain name.

    .PARAMETER SiteName
        Specifies the site in the domain where to look for a domain controller.

    .PARAMETER Credential
        Specifies the credentials to use when accessing the domain, or use the current user if not specified.

    .PARAMETER WaitForValidCredentials
        Specifies if authentication exceptions should be ignored.

    .INPUTS
        None

    .OUTPUTS
        System.DirectoryServices.ActiveDirectory.DomainController

    .NOTES
        This function is designed so that it can run on any computer without having the ActiveDirectory module
        installed.
#>
function Find-DomainController
{
    [OutputType([System.DirectoryServices.ActiveDirectory.DomainController])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter()]
        [System.String]
        $SiteName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $WaitForValidCredentials
    )

    if ($PSBoundParameters.ContainsKey('SiteName'))
    {
        Write-Verbose -Message ($script:localizedData.SearchingForDomainControllerInSite -f
            $SiteName, $DomainName) -Verbose
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.SearchingForDomainController -f $DomainName) -Verbose
    }

    if ($PSBoundParameters.ContainsKey('Credential'))
    {
        $adDirectoryContext = Get-ADDirectoryContext -DirectoryContextType 'Domain' -Name $DomainName `
            -Credential $Credential
    }
    else
    {
        $adDirectoryContext = Get-ADDirectoryContext -DirectoryContextType 'Domain' -Name $DomainName
    }

    $domainControllerObject = $null

    try
    {
        if ($PSBoundParameters.ContainsKey('SiteName'))
        {
            $domainControllerObject = Find-DomainControllerFindOneInSiteWrapper -DirectoryContext $adDirectoryContext `
                -SiteName $SiteName

            Write-Verbose -Message ($script:localizedData.FoundDomainControllerInSite -f
                $SiteName, $DomainName) -Verbose
        }
        else
        {
            $domainControllerObject = Find-DomainControllerFindOneWrapper -DirectoryContext $adDirectoryContext

            Write-Verbose -Message ($script:localizedData.FoundDomainController -f $DomainName) -Verbose
        }
    }
    catch [System.DirectoryServices.ActiveDirectory.ActiveDirectoryObjectNotFoundException]
    {
        Write-Verbose -Message ($script:localizedData.FailedToFindDomainController -f $DomainName) -Verbose
    }
    catch [System.Management.Automation.MethodInvocationException]
    {
        $isTypeNameToSuppress = $_.Exception.InnerException -is `
            [System.Security.Authentication.AuthenticationException]

        if ($WaitForValidCredentials.IsPresent -and $isTypeNameToSuppress)
        {
            Write-Warning -Message (
                $script:localizedData.IgnoreCredentialError -f $_.FullyQualifiedErrorId, $_.Exception.Message
            )
        }
        elseif ($_.Exception.InnerException -is `
                [System.DirectoryServices.ActiveDirectory.ActiveDirectoryObjectNotFoundException])
        {
            Write-Verbose -Message ($script:localizedData.FailedToFindDomainController -f $DomainName) -Verbose
        }
        else
        {
            throw $_
        }
    }
    catch
    {
        throw $_
    }

    return $domainControllerObject
}

<#
    .SYNOPSIS
        Returns a System.DirectoryServices.ActiveDirectory.DomainController object.

    .DESCRIPTION
        The Find-DomainControllerFindOneWrapper function is used to return a
        System.DirectoryServices.ActiveDirectory.DomainController object which is a class that represents an Active
        Directory Domain Controller.

    .EXAMPLE
        Find-DomainControllerFindOneWrapper -DirectoryContext $directoryContext

    .PARAMETER DirectoryContext
        Specifies the Active Directory context from which the donmain controller object is returned. Calling the
        Get-ADDirectoryContext gets a value that can be provided in this parameter.

    .INPUTS
        None

    .OUTPUTS
        System.DirectoryServices.ActiveDirectory.DomainController

    .NOTES
        This is a wrapper to enable unit testing of the function Find-DomainController. It is not possible to make a
        stub class to mock these, since these classes are loaded into the PowerShell session when it starts.

        This function is not exported.
#>
function Find-DomainControllerFindOneWrapper
{
    [CmdletBinding()]
    [OutputType([System.DirectoryServices.ActiveDirectory.DomainController])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.DirectoryServices.ActiveDirectory.DirectoryContext]
        $DirectoryContext
    )

    return [System.DirectoryServices.ActiveDirectory.DomainController]::FindOne($DirectoryContext)
}

<#
    .SYNOPSIS
        Returns a System.DirectoryServices.ActiveDirectory.DomainController object for a particular site.

    .DESCRIPTION
        The Find-DomainControllerFindOneWrapper function is used to return a
        System.DirectoryServices.ActiveDirectory.DomainController object for a particular site which is a class that
        represents an Active Directory Domain Controller.

    .EXAMPLE
        Find-DomainControllerFindOneWrapper -DirectoryContext $directoryContext -SiteName 'Default'

    .PARAMETER DirectoryContext
        Specifies the Active Directory context from which the donmain controller object is returned. Calling the
        Get-ADDirectoryContext gets a value that can be provided in this parameter.

    .INPUTS
        None

    .OUTPUTS
        System.DirectoryServices.ActiveDirectory.DomainController

    .NOTES
        This is a wrapper to enable unit testing of the function Find-DomainController. It is not possible to make a
        stub class to mock these, since these classes are loaded into the PowerShell session when it starts.

        This function is not exported.
#>
function Find-DomainControllerFindOneInSiteWrapper
{
    [CmdletBinding()]
    [OutputType([System.DirectoryServices.ActiveDirectory.DomainController])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.DirectoryServices.ActiveDirectory.DirectoryContext]
        $DirectoryContext,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SiteName
    )

    return [System.DirectoryServices.ActiveDirectory.DomainController]::FindOne($DirectoryContext, $SiteName)
}

<#
    .SYNOPSIS
        Gets the current user identity.

    .DESCRIPTION
        The Get-CurrentUser function is used to get the current user identity. A WindowsIdentity object is returned
        that represents the current user.

    .EXAMPLE
        Get-CurrentUser

    .INPUTS
        None

    .OUTPUTS
        System.Security.Principal.WindowsIdentity

    .NOTES
        This is a wrapper to allow test mocking of the calling function.
#>
function Get-CurrentUser
{
    [CmdletBinding()]
    [OutputType([System.Security.Principal.WindowsIdentity])]
    param ()

    return [System.Security.Principal.WindowsIdentity]::GetCurrent()
}

<#
    .SYNOPSIS
        Tests the validity of a user's password.

    .DESCRIPTION
        The Test-Password funtion is used to test the validity of a user's password. A boolean is returned that
        represents the validity of the password.

    .EXAMPLE
        Test-Password -DomainName contoso.com -UserName 'user1' -Password $cred

    .PARAMETER DomainName
        Specifies the name of the domain where the user account is located (only used if password is managed).

    .PARAMETER UserName
        Specifies the Security Account Manager (SAM) account name of the user (ldapDisplayName 'sAMAccountName').

    .PARAMETER Password
        Specifies a new password value for the account.

    .PARAMETER Credential
        Specifies the credentials to use when accessing the domain, or use the current user if not specified.

    .PARAMETER PasswordAuthentication
        Specifies the authentication context type used when testing passwords.

    .INPUTS
        None

    .OUTPUTS
        System.Boolean
#>
function Test-Password
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

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Password,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        # Specifies the authentication context type when testing user passwords #61
        [Parameter(Mandatory = $true)]
        [ValidateSet('Default', 'Negotiate')]
        [System.String]
        $PasswordAuthentication
    )

    Write-Verbose -Message ($script:localizedData.CreatingADDomainConnection -f $DomainName)

    $principalContextTypeName = 'System.DirectoryServices.AccountManagement.PrincipalContext'

    Add-TypeAssembly -AssemblyName 'System.DirectoryServices.AccountManagement' -TypeName $principalContextTypeName

    <#
        If the domain name contains a distinguished name, set it to the fully
        qualified domain name (FQDN) instead.
        If the $DomainName does not contain a distinguished name the function
        Get-ADDomainNameFromDistinguishedName returns $null.
    #>
    $ADDomainName = Get-ADDomainNameFromDistinguishedName -DistinguishedName $DomainName
    if ($ADDomainName)
    {
        $DomainName = $ADDomainName
    }

    if ($Credential)
    {
        Write-Verbose -Message (
            $script:localizedData.TestPasswordUsingImpersonation -f $Credential.UserName, $UserName
        )

        $principalContext = New-Object -TypeName $principalContextTypeName -ArgumentList @(
            [System.DirectoryServices.AccountManagement.ContextType]::Domain,
            $DomainName,
            $Credential.UserName,
            $Credential.GetNetworkCredential().Password
        )
    }
    else
    {
        $principalContext = New-Object -TypeName $principalContextTypeName -ArgumentList @(
            [System.DirectoryServices.AccountManagement.ContextType]::Domain,
            $DomainName,
            $null,
            $null
        )
    }

    Write-Verbose -Message ($script:localizedData.CheckingADUserPassword -f $UserName)

    $getPrincipalContextCredentials = @{
        UserName               = $UserName
        Password               = $Password
        PrincipalContext       = $principalContext
        PasswordAuthentication = $PasswordAuthentication
    }
    return Test-PrincipalContextCredentials @getPrincipalContextCredentials
}

<#
    .SYNOPSIS
        Tests the validity of credentials using a PrincipalContext.

    .DESCRIPTION
        The Test-PrincipalContextCredentials function is used to test the validity of credentials using a
        PrincipalContext. A boolean is returned that represents the validity of the password.

    .EXAMPLE
        Test-PrincipalContextCredentials -UserName 'user1' -Password $cred -PrincipalContext $context

    .PARAMETER UserName
        Specifies the Security Account Manager (SAM) account name of the user (ldapDisplayName 'sAMAccountName').

    .PARAMETER Password
        Specifies a new password value for the account.

    .PARAMETER PrincipalContext
        Specifies the PrincipalContext object that the credential test will be performed using.

    .PARAMETER PasswordAuthentication
        Specifies the authentication context type to be used when testing the password.

    .INPUTS
        None

    .OUTPUTS
        System.Boolean

    .NOTES
        This is a internal wrapper function to allow test mocking of the calling function.
#>
function Test-PrincipalContextCredentials
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Password,

        [Parameter(Mandatory = $true)]
        [System.DirectoryServices.AccountManagement.PrincipalContext]
        $PrincipalContext,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Default', 'Negotiate')]
        [System.String]
        $PasswordAuthentication
    )

    if ($PasswordAuthentication -eq 'Negotiate')
    {
        $result = $principalContext.ValidateCredentials(
            $UserName,
            $Password.GetNetworkCredential().Password,
            [System.DirectoryServices.AccountManagement.ContextOptions]::Negotiate -bor
            [System.DirectoryServices.AccountManagement.ContextOptions]::Signing -bor
            [System.DirectoryServices.AccountManagement.ContextOptions]::Sealing
        )
    }
    else
    {
        # Use default authentication context
        $result = $principalContext.ValidateCredentials(
            $UserName,
            $Password.GetNetworkCredential().Password
        )
    }

    return $result
}

<#
    .SYNOPSIS
        Gets the contents of a file as a byte array.

    .DESCRIPTION
        The Get-ByteContent function is used to get the contents of a file as a byte array.

    .EXAMPLE
        Get-ByteContent -Path $path

    .PARAMETER Path
        Specifies the path to an item.

    .INPUTS
        none

    .OUTPUTS
        System.Byte[]
#>
function Get-ByteContent
{
    [CmdletBinding()]
    [OutputType([System.Byte[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    if ($PSVersionTable.PSEdition -eq 'Core')
    {
        $content = Get-Content -Path $Path -AsByteStream
    }
    else
    {
        $content = Get-Content -Path $Path -Encoding 'Byte'
    }

    return $content
}

<#
    .SYNOPSIS
        Gets a Domain object for the specified context.

    .DESCRIPTION
        The Get-ActiveDirectoryDomain function is used to get a System.DirectoryServices.ActiveDirectory.Domain object
        for the specified context, which is a class that represents an Active Directory Domain Services domain.

    .EXAMPLE
        Get-ActiveDirectoryDomain -DirectoryContext $context

    .PARAMETER DirectoryContext
        Specifies the Active Directory context from which the domain object is returned. Calling the
        Get-ADDirectoryContext gets a value that can be provided in this parameter.

    .INPUTS
        None

    .OUTPUTS
        System.DirectoryServices.ActiveDirectory.Domain

    .NOTES
        This is a wrapper to allow test mocking of the calling function.
        See issue https://github.com/PowerShell/ActiveDirectoryDsc/issues/324 for more information.
#>
function Get-ActiveDirectoryDomain
{
    [CmdletBinding()]
    [OutputType([System.DirectoryServices.ActiveDirectory.Domain])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.DirectoryServices.ActiveDirectory.DirectoryContext]
        $DirectoryContext
    )

    return [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($DirectoryContext)
}

<#
    .SYNOPSIS
        Gets a Forest object for the specified context.

    .DESCRIPTION
        The Get-ActiveDirectoryForest function is used to get a System.DirectoryServices.ActiveDirectory.Forest object
        for the specified context. which is a class that represents an Active Directory Domain Services forest.

    .EXAMPLE
        Get-ActiveDirectoryForest -DirectoryContext $context

    .PARAMETER DirectoryContext
        Specifies the Active Directory context from which the forest object is returned. Calling the
        Get-ADDirectoryContext gets a value that can be provided in this parameter.

    .INPUTS
        None

    .OUTPUTS
        System.DirectoryServices.ActiveDirectory.Forest

    .NOTES
        This is a wrapper to allow test mocking of the calling function.
        See issue https://github.com/PowerShell/ActiveDirectoryDsc/issues/324 for more information.
#>
function Get-ActiveDirectoryForest
{
    [CmdletBinding()]
    [OutputType([System.DirectoryServices.ActiveDirectory.Forest])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.DirectoryServices.ActiveDirectory.DirectoryContext]
        $DirectoryContext
    )

    return [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($DirectoryContext)
}

<#
    .SYNOPSIS
        Resolves the SamAccountName of an Active Directory object based on a supplied ObjectSid.

    .DESCRIPTION
        The Resolve-SamAccountName function is used to get a System.String object representing the SamAccountName
        translated from the specified ObjectSid. If a System.Security.Principal.IdentityNotMappedException exception
        is thrown, then we assume it is an orphaned ForeignSecurityPrincipal and the ObjectSid value is returned back.

    .EXAMPLE
        Resolve-SamAccountName -ObjectSid $adObject.objectSid

    .PARAMETER ObjectSid
        Specifies the Active Directory object security identifier to use for translation to a SamAccountName.

    .INPUTS
        None

    .OUTPUTS
        System.String

    .NOTES
        This is a wrapper to allow test mocking of the calling function.
        See issue https://github.com/dsccommunity/ActiveDirectoryDsc/issues/616 for more information.
#>
function Resolve-SamAccountName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ObjectSid
    )

    try
    {
        $sidObject = [System.Security.Principal.SecurityIdentifier]::new($ObjectSid)
        $sidObject.Translate([System.Security.Principal.NTAccount]).Value
    }
    catch [System.Security.Principal.IdentityNotMappedException]
    {
        Write-Warning -Message ($script:localizedData.IdentityNotMappedExceptionError -f
            'SamAccountName', 'ObjectSID', $ObjectSid)
        $ObjectSid
    }
    catch
    {
        $errorMessage = ($script:localizedData.UnableToResolveMembershipAttribute -f
            'SamAccountName', 'ObjectSID', $ObjectSid)
        New-InvalidResultException -Message $errorMessage -ErrorRecord $_
    }
}

<#
    .SYNOPSIS
        Resolves the Security Identifier (SID) of an Active Directory object based on a supplied SamAccountName.

    .DESCRIPTION
        The Resolve-SecurityIdentifier function is used to get a System.String object representing the Security Identifier
        (SID) translated from the specified SamAccountName.

    .EXAMPLE
        Resolve-SecurityIdentifier -SamAccountName $adObject.SamAccountName

    .PARAMETER SamAccountName
        Specifies the Active Directory object SamAccountName to use for translation to a Security Identifier (SID).

    .INPUTS
        None

    .OUTPUTS
        System.String

    .NOTES
        This is a wrapper to allow test mocking of the calling function.
        See issue https://github.com/dsccommunity/ActiveDirectoryDsc/issues/619 for more information.
#>
function Resolve-SecurityIdentifier
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SamAccountName
    )

    try
    {
        $ntAccount = [System.Security.Principal.NTAccount]::new($SamAccountName)
        $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
    }
    catch
    {
        $errorMessage = ($script:localizedData.IdentityNotMappedExceptionError -f
            'SID', 'SamAccountName', $SamAccountName)
        New-InvalidResultException -Message $errorMessage -ErrorRecord $_
    }
}

<#
    .SYNOPSIS
        Resolves the Security Identifier (SID) of a list of Members of the same type defined by the MembershipAttribute.

    .DESCRIPTION
        The Resolve-MembersSecurityIdentifier function is used to get an array of System.String objects representing
        the Security Identifier (SID) translated from the specified list of Members with a type defined by the
        MembershipAttribute. Custom logic is used for Foreign Security Principals to translate from a SamAccountName
        or DistinguishedName, otherwise the value is sent to Get-ADObject as a filter to return the ObjectSID.

    .EXAMPLE
        Get-ADGroup -Identity 'GroupName' -Properties 'Members' | Resolve-MembersSecurityIdentifier -MembershipAttribute 'DistinguishedName'
        -----------
        Description
        This will translate all of the DistinguishedName values for the Members of 'GroupName' into SID values.

    .PARAMETER Members
        Specifies the MembershipAttribute type values representing the Members to resolve into a Security Identifier.

    .PARAMETER MembershipAttribute
        Specifies the Active Directory attribute for the values of the Members parameter.
        Default value is 'SamAccountName'.

    .PARAMETER Parameters
        Specifies the parameters to pass to the Resolve-MembersSecurityIdentifier cmdlet for usage with the internal
        Get-ADObject call. This is an optional parameter which can have Keys and Values for Server and Credential.

    .PARAMETER PrepareForMembership
        Specifies whether to wrap each resulting value 'VALUE' as '<SID=VALUE>' so that it can be passed directly to
        Set-ADGroup under the 'member' key in the hash object.

    .INPUTS
        None

    .OUTPUTS
        System.String[]

    .NOTES
        This is a helper function to allow for easier one-way trust AD group membership management based on SID.
        See issue https://github.com/dsccommunity/ActiveDirectoryDsc/issues/619 for more information.
#>
function Resolve-MembersSecurityIdentifier
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String[]]
        $Members,

        [Parameter()]
        [ValidateSet('SamAccountName', 'DistinguishedName', 'SID', 'ObjectGUID')]
        [System.String]
        $MembershipAttribute = 'SamAccountName',

        [Parameter()]
        [System.Collections.Hashtable]
        $Parameters,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PrepareForMembership
    )

    begin
    {
        Write-Debug 'Entering Resolve-MembersSecurityIdentifier'

        Assert-Module -ModuleName ActiveDirectory

        $property = 'ObjectSID'
        $fspADContainer = 'CN=ForeignSecurityPrincipals'

        Write-Debug -Message ($script:localizedData.ResolvingMembershipAttributeValues -f
            $property, $MembershipAttribute)

        $getADObjectParms = @{}

        if ($PSBoundParameters.Keys -contains 'Parameters')
        {
            if (-not ([string]::IsNullOrEmpty($Parameters['Server'])))
            {
                $getADObjectParms['Server'] = $Parameters['Server']
            }
            if ($Parameters['Credential'])
            {
                $getADObjectParms['Credential'] = $Parameters['Credential']
            }
        }

        $getADObjectParms['Properties'] = @($property)
        $getADObjectParms['ErrorAction'] = 'Stop'
    }

    process
    {
        if ($MembershipAttribute -eq 'SID')
        {
            if ($PrepareForMembership.IsPresent)
            {
                return $Members | ForEach-Object -Process { "<SID=$($_)>" }
            }
            else
            {
                return $Members
            }
        }

        foreach ($member in $Members)
        {
            if ($MembershipAttribute -eq 'SamAccountName' -and $member -match '\\')
            {
                $memberDomainName = $member.split('\')[0]
                $memberSamAccountName = $member.split('\')[1]
                try
                {
                    $memberDomainDetails = Get-ADDomain -Identity $memberDomainName
                }
                catch [System.Security.Authentication.AuthenticationException]
                {
                    Write-Debug -Message ($script:localizedData.TranslatingMembershipAttribute -f
                    $MembershipAttribute, $member, $property)

                    $securityIdentifier = Resolve-SecurityIdentifier -SamAccountName $member
                    $sid = $true
                    $memberDomainDetails = $null
                }

                if ($memberDomainDetails)
                {
                    $securityIdentifier = (Get-ADObject -SearchBase $memberDomainDetails.DistinguishedName -Filter "SamAccountName -eq '$memberSamAccountName'" -Server :3268).DistinguishedName
                    $sid = $false
                }
            }
            elseif ($MembershipAttribute -eq 'DistinguishedName' -and ($member -split ',')[1] -eq $fspADContainer)
            {
                Write-Debug -Message ($script:localizedData.ParsingCommonNameFromDN -f $member)

                $securityIdentifier = ($member -split ',')[0] -replace '^CN[=]'
                $sid=$true
            }
            else
            {
                Write-Debug -Message ($script:localizedData.ADObjectPropertyLookup -f
                    $property, $MembershipAttribute, $member)

                #$getADObjectParms['Filter'] = "$($MembershipAttribute) -eq '$($member)'"
                $getADObjectParms['Identity'] = $member

                #$securityIdentifier = [string](Get-ADObject @getADObjectParms -Server :3268).$property
                $securityIdentifier = $member
                $sid=$false
            }

            if (-not ([string]::IsNullOrEmpty($securityIdentifier)))
            {
                if ($PrepareForMembership.IsPresent -and $sid -eq $true)
                {
                    "<SID=$($securityIdentifier)>"
                }
                else
                {
                    $securityIdentifier
                }
            }
            else
            {
                $errorMessage = ($script:localizedData.UnableToResolveMembershipAttribute -f
                    $property, $MembershipAttribute, $member)
                New-InvalidOperationException -Message $errorMessage
            }
        }
    }
}
