$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'ActiveDirectoryDsc.Common'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'ActiveDirectoryDsc.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_ADGroup'

<#
    .SYNOPSIS
        Returns the current state of the Active Directory group.

    .PARAMETER GroupName
         Name of the Active Directory group.

    .PARAMETER GroupScope
        Active Directory group scope. Default value is 'Global'.

    .PARAMETER Category
        Active Directory group category. Default value is 'Security'.

    .PARAMETER Path
        Location of the group within Active Directory expressed as a Distinguished Name.

    .PARAMETER Ensure
        Specifies if this Active Directory group should be present or absent.
        Default value is 'Present'.

    .PARAMETER Description
        Description of the Active Directory group.

    .PARAMETER DisplayName
        Display name of the Active Directory group.

    .PARAMETER Credential
        Credentials used to enact the change upon.

    .PARAMETER DomainController
        Active Directory domain controller to enact the change upon.

    .PARAMETER Members
        Active Directory group membership should match membership exactly.

    .PARAMETER MembersToInclude
        Active Directory group should include these members.

    .PARAMETER MembersToExclude
        Active Directory group should NOT include these members.

    .PARAMETER MembershipAttribute
        Active Directory attribute used to perform membership operations.
        Default value is 'SamAccountName'.

    .PARAMETER ManagedBy
        Active Directory managed by attribute specified as a DistinguishedName.

    .PARAMETER Notes
        Active Directory group notes field.

    .PARAMETER RestoreFromRecycleBin
        Try to restore the group from the recycle bin before creating a new one.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $GroupName,

        [Parameter()]
        [ValidateSet('DomainLocal', 'Global', 'Universal')]
        [System.String]
        $GroupScope = 'Global',

        [Parameter()]
        [ValidateSet('Security', 'Distribution')]
        [System.String]
        $Category = 'Security',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $Members,

        [Parameter()]
        [System.String[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [ValidateSet('SamAccountName', 'DistinguishedName', 'SID', 'ObjectGUID')]
        [System.String]
        $MembershipAttribute = 'SamAccountName',

        # This must be the user's DN
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ManagedBy,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Notes,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $RestoreFromRecycleBin
    )

    Assert-Module -ModuleName 'ActiveDirectory'

    $adGroupParams = Get-ADCommonParameters @PSBoundParameters

    try
    {
        $adGroup = Get-ADGroup @adGroupParams -Property Name, GroupScope, GroupCategory, DistinguishedName, Description, DisplayName, ManagedBy, Info

        Write-Verbose -Message ($script:localizedData.RetrievingGroupMembers -f $MembershipAttribute)

        # Retrieve the current list of members, returning the specified membership attribute
        [System.Array] $adGroupMembers = (Get-ADGroupMember @adGroupParams).$MembershipAttribute

        $targetResource = @{
            GroupName           = $adGroup.Name
            GroupScope          = $adGroup.GroupScope
            Category            = $adGroup.GroupCategory
            Path                = Get-ADObjectParentDN -DN $adGroup.DistinguishedName
            Description         = $adGroup.Description
            DisplayName         = $adGroup.DisplayName
            Members             = $adGroupMembers
            MembersToInclude    = $MembersToInclude
            MembersToExclude    = $MembersToExclude
            MembershipAttribute = $MembershipAttribute
            ManagedBy           = $adGroup.ManagedBy
            Notes               = $adGroup.Info
            Ensure              = 'Absent'
        }

        if ($adGroup)
        {
            $targetResource['Ensure'] = 'Present'
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        Write-Verbose -Message ($script:localizedData.GroupNotFound -f $GroupName)

        $targetResource = @{
            GroupName           = $GroupName
            GroupScope          = $GroupScope
            Category            = $Category
            Path                = $Path
            Description         = $Description
            DisplayName         = $DisplayName
            Members             = @()
            MembersToInclude    = $MembersToInclude
            MembersToExclude    = $MembersToExclude
            MembershipAttribute = $MembershipAttribute
            ManagedBy           = $ManagedBy
            Notes               = $Notes
            Ensure              = 'Absent'
        }
    }

    return $targetResource
} #end function Get-TargetResource

<#
    .SYNOPSIS
        Determines if the Active Directory group is in the desired state.

    .PARAMETER GroupName
         Name of the Active Directory group.

    .PARAMETER GroupScope
        Active Directory group scope. Default value is 'Global'.

    .PARAMETER Category
        Active Directory group category. Default value is 'Security'.

    .PARAMETER Path
        Location of the group within Active Directory expressed as a Distinguished Name.

    .PARAMETER Ensure
        Specifies if this Active Directory group should be present or absent.
        Default value is 'Present'.

    .PARAMETER Description
        Description of the Active Directory group.

    .PARAMETER DisplayName
        Display name of the Active Directory group.

    .PARAMETER Credential
        Credentials used to enact the change upon.

    .PARAMETER DomainController
        Active Directory domain controller to enact the change upon.

    .PARAMETER Members
        Active Directory group membership should match membership exactly.

    .PARAMETER MembersToInclude
        Active Directory group should include these members.

    .PARAMETER MembersToExclude
        Active Directory group should NOT include these members.

    .PARAMETER MembershipAttribute
        Active Directory attribute used to perform membership operations.
        Default value is 'SamAccountName'.

    .PARAMETER ManagedBy
        Active Directory managed by attribute specified as a DistinguishedName.

    .PARAMETER Notes
        Active Directory group notes field.

    .PARAMETER RestoreFromRecycleBin
        Try to restore the group from the recycle bin before creating a new one.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $GroupName,

        [Parameter()]
        [ValidateSet('DomainLocal', 'Global', 'Universal')]
        [System.String]
        $GroupScope = 'Global',

        [Parameter()]
        [ValidateSet('Security', 'Distribution')]
        [System.String]
        $Category = 'Security',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $Members,

        [Parameter()]
        [System.String[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [ValidateSet('SamAccountName', 'DistinguishedName', 'SID', 'ObjectGUID')]
        [System.String]
        $MembershipAttribute = 'SamAccountName',

        # This must be the user's DN
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ManagedBy,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Notes,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $RestoreFromRecycleBin
    )

    # Validate parameters before we even attempt to retrieve anything
    $assertMemberParameters = @{ }

    if ($PSBoundParameters.ContainsKey('Members') -and -not [system.string]::IsNullOrEmpty($Members))
    {
        $assertMemberParameters['Members'] = $Members
    }

    if ($PSBoundParameters.ContainsKey('MembersToInclude') -and -not [system.string]::IsNullOrEmpty($MembersToInclude))
    {
        $assertMemberParameters['MembersToInclude'] = $MembersToInclude
    }

    if ($PSBoundParameters.ContainsKey('MembersToExclude') -and -not [system.string]::IsNullOrEmpty($MembersToExclude))
    {
        $assertMemberParameters['MembersToExclude'] = $MembersToExclude
    }

    Assert-MemberParameters @assertMemberParameters -ErrorAction Stop

    $targetResource = Get-TargetResource @PSBoundParameters

    $targetResourceInCompliance = $true

    if ($PSBoundParameters.ContainsKey('GroupScope') -and $targetResource.GroupScope -ne $GroupScope)
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyState -f 'GroupScope', $GroupScope, $targetResource.GroupScope)
        $targetResourceInCompliance = $false
    }

    if ($PSBoundParameters.ContainsKey('Category') -and $targetResource.Category -ne $Category)
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyState -f 'Category', $Category, $targetResource.Category)
        $targetResourceInCompliance = $false
    }

    if ($Path -and ($targetResource.Path -ne $Path))
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyState -f 'Path', $Path, $targetResource.Path)
        $targetResourceInCompliance = $false
    }

    if ($Description -and ($targetResource.Description -ne $Description))
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyState -f 'Description', $Description, $targetResource.Description)
        $targetResourceInCompliance = $false
    }

    if ($DisplayName -and ($targetResource.DisplayName -ne $DisplayName))
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyState -f 'DisplayName', $DisplayName, $targetResource.DisplayName)
        $targetResourceInCompliance = $false
    }

    if ($ManagedBy -and ($targetResource.ManagedBy -ne $ManagedBy))
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyState -f 'ManagedBy', $ManagedBy, $targetResource.ManagedBy)
        $targetResourceInCompliance = $false
    }

    if ($Notes -and ($targetResource.Notes -ne $Notes))
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyState -f 'Notes', $Notes, $targetResource.Notes)
        $targetResourceInCompliance = $false
    }

    # Test group members match passed membership parameters
    if (-not (Test-Members @assertMemberParameters -ExistingMembers $targetResource.Members))
    {
        Write-Verbose -Message $script:localizedData.GroupMembershipNotDesiredState
        $targetResourceInCompliance = $false
    }

    if ($targetResource.Ensure -ne $Ensure)
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyState -f 'Ensure', $Ensure, $targetResource.Ensure)
        $targetResourceInCompliance = $false
    }

    return $targetResourceInCompliance
} #end function Test-TargetResource

<#
    .SYNOPSIS
        Creates, removes or modifies the Active Directory group.

    .PARAMETER GroupName
         Name of the Active Directory group.

    .PARAMETER GroupScope
        Active Directory group scope. Default value is 'Global'.

    .PARAMETER Category
        Active Directory group category. Default value is 'Security'.

    .PARAMETER Path
        Location of the group within Active Directory expressed as a Distinguished Name.

    .PARAMETER Ensure
        Specifies if this Active Directory group should be present or absent.
        Default value is 'Present'.

    .PARAMETER Description
        Description of the Active Directory group.

    .PARAMETER DisplayName
        Display name of the Active Directory group.

    .PARAMETER Credential
        Credentials used to enact the change upon.

    .PARAMETER DomainController
        Active Directory domain controller to enact the change upon.

    .PARAMETER Members
        Active Directory group membership should match membership exactly.

    .PARAMETER MembersToInclude
        Active Directory group should include these members.

    .PARAMETER MembersToExclude
        Active Directory group should NOT include these members.

    .PARAMETER MembershipAttribute
        Active Directory attribute used to perform membership operations.
        Default value is 'SamAccountName'.

    .PARAMETER ManagedBy
        Active Directory managed by attribute specified as a DistinguishedName.

    .PARAMETER Notes
        Active Directory group notes field.

    .PARAMETER RestoreFromRecycleBin
        Try to restore the group from the recycle bin before creating a new one.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $GroupName,

        [Parameter()]
        [ValidateSet('DomainLocal', 'Global', 'Universal')]
        [System.String]
        $GroupScope = 'Global',

        [Parameter()]
        [ValidateSet('Security', 'Distribution')]
        [System.String]
        $Category = 'Security',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $Members,

        [Parameter()]
        [System.String[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [ValidateSet('SamAccountName', 'DistinguishedName', 'SID', 'ObjectGUID')]
        [System.String]
        $MembershipAttribute = 'SamAccountName',

        # This must be the user's DN
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ManagedBy,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Notes,

        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean]
        $RestoreFromRecycleBin

    )

    Assert-Module -ModuleName 'ActiveDirectory'

    $adGroupParams = Get-ADCommonParameters @PSBoundParameters

    try
    {
        if ($MembershipAttribute -eq 'DistinguishedName')
        {
            $allMembers = $Members + $MembersToInclude + $MembersToExclude

            $groupMemberDomains = @()

            foreach ($member in $allMembers)
            {
                $groupMemberDomains += Get-ADDomainNameFromDistinguishedName -DistinguishedName $member
            }

            $uniqueGroupMemberDomainCount = $groupMemberDomains |
                Select-Object -Unique

            $GroupMemberDomainCount = $uniqueGroupMemberDomainCount.count

            if ($GroupMemberDomainCount -gt 1 -or ($groupMemberDomains -ine (Get-DomainName)).Count -gt 0)
            {
                Write-Verbose -Message ($script:localizedData.GroupMembershipMultipleDomains -f $GroupMemberDomainCount)
                $MembersInMultipleDomains = $true
            }
        }

        $adGroup = Get-ADGroup @adGroupParams -Property Name, GroupScope, GroupCategory, DistinguishedName, Description, DisplayName, ManagedBy, Info

        if ($Ensure -eq 'Present')
        {
            $setADGroupParams = $adGroupParams.Clone()
            $setADGroupParams['Identity'] = $adGroup.DistinguishedName

            # Update existing group properties
            if ($PSBoundParameters.ContainsKey('Category') -and $Category -ne $adGroup.GroupCategory)
            {
                Write-Verbose -Message ($script:localizedData.UpdatingGroupProperty -f 'Category', $Category)
                $setADGroupParams['GroupCategory'] = $Category
            }

            if ($PSBoundParameters.ContainsKey('GroupScope') -and $GroupScope -ne $adGroup.GroupScope)
            {
                # Cannot change DomainLocal to Global or vice versa directly. Need to change them to a Universal group first!
                Set-ADGroup -Identity $adGroup.DistinguishedName -GroupScope Universal
                Write-Verbose -Message ($script:localizedData.UpdatingGroupProperty -f 'GroupScope', $GroupScope)
                $setADGroupParams['GroupScope'] = $GroupScope
            }

            if ($Description -and ($Description -ne $adGroup.Description))
            {
                Write-Verbose -Message ($script:localizedData.UpdatingGroupProperty -f 'Description', $Description)
                $setADGroupParams['Description'] = $Description
            }

            if ($DisplayName -and ($DisplayName -ne $adGroup.DisplayName))
            {
                Write-Verbose -Message ($script:localizedData.UpdatingGroupProperty -f 'DisplayName', $DisplayName)
                $setADGroupParams['DisplayName'] = $DisplayName
            }

            if ($ManagedBy -and ($ManagedBy -ne $adGroup.ManagedBy))
            {
                Write-Verbose -Message ($script:localizedData.UpdatingGroupProperty -f 'ManagedBy', $ManagedBy)
                $setADGroupParams['ManagedBy'] = $ManagedBy
            }

            if ($Notes -and ($Notes -ne $adGroup.Info))
            {
                Write-Verbose -Message ($script:localizedData.UpdatingGroupProperty -f 'Notes', $Notes)
                $setADGroupParams['Replace'] = @{ Info = $Notes }
            }

            Write-Verbose -Message ($script:localizedData.UpdatingGroup -f $GroupName)

            Set-ADGroup @setADGroupParams

            # Move group if the path is not correct
            if ($Path -and ($Path -ne (Get-ADObjectParentDN -DN $adGroup.DistinguishedName)))
            {
                Write-Verbose -Message ($script:localizedData.MovingGroup -f $GroupName, $Path)

                $moveADObjectParams = $adGroupParams.Clone()
                $moveADObjectParams['Identity'] = $adGroup.DistinguishedName

                Move-ADObject @moveADObjectParams -TargetPath $Path
            }

            Write-Verbose -Message ($script:localizedData.RetrievingGroupMembers -f $MembershipAttribute)

            $adGroupMembers = (Get-ADGroupMember @adGroupParams).$MembershipAttribute

            if (-not (Test-Members -ExistingMembers $adGroupMembers -Members $Members -MembersToInclude $MembersToInclude -MembersToExclude $MembersToExclude))
            {
                <#
                    The fact that we're in the Set method, there is no need to
                    validate the parameter combination as this was performed in
                    the Test method.
                #>
                if ($PSBoundParameters.ContainsKey('Members') -and -not [system.string]::IsNullOrEmpty($Members))
                {
                    # Remove all existing first and add explicit members
                    $Members = Remove-DuplicateMembers -Members $Members

                    # We can only remove members if there are members already in the group!
                    if ($adGroupMembers.Count -gt 0)
                    {
                        Write-Verbose -Message ($script:localizedData.RemovingGroupMembers -f $adGroupMembers.Count, $GroupName)

                        Remove-ADGroupMember @adGroupParams -Members $adGroupMembers -Confirm:$false
                    }

                    Write-Verbose -Message ($script:localizedData.AddingGroupMembers -f $Members.Count, $GroupName)

                    Add-ADCommonGroupMember -Parameter $adGroupParams -Members $Members -MembersInMultipleDomains:$MembersInMultipleDomains
                }

                if ($PSBoundParameters.ContainsKey('MembersToInclude') -and -not [system.string]::IsNullOrEmpty($MembersToInclude))
                {
                    $MembersToInclude = Remove-DuplicateMembers -Members $MembersToInclude

                    Write-Verbose -Message ($script:localizedData.AddingGroupMembers -f $MembersToInclude.Count, $GroupName)

                    Add-ADCommonGroupMember -Parameter $adGroupParams -Members $MembersToInclude -MembersInMultipleDomains:$MembersInMultipleDomains
                }

                if ($PSBoundParameters.ContainsKey('MembersToExclude') -and -not [system.string]::IsNullOrEmpty($MembersToExclude))
                {
                    $MembersToExclude = Remove-DuplicateMembers -Members $MembersToExclude

                    Write-Verbose -Message ($script:localizedData.RemovingGroupMembers -f $MembersToExclude.Count, $GroupName)

                    Remove-ADGroupMember @adGroupParams -Members $MembersToExclude -Confirm:$false
                }
            }
        }
        elseif ($Ensure -eq 'Absent')
        {
            # Remove existing group
            Write-Verbose -Message ($script:localizedData.RemovingGroup -f $GroupName)

            Remove-ADGroup @adGroupParams -Confirm:$false
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        # The AD group doesn't exist
        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message ($script:localizedData.GroupNotFound -f $GroupName)

            $adGroupParams = Get-ADCommonParameters @PSBoundParameters -UseNameParameter

            if ($Description)
            {
                $adGroupParams['Description'] = $Description
            }

            if ($DisplayName)
            {
                $adGroupParams['DisplayName'] = $DisplayName
            }

            if ($ManagedBy)
            {
                $adGroupParams['ManagedBy'] = $ManagedBy
            }

            if ($Path)
            {
                $adGroupParams['Path'] = $Path
            }

            # Create group. Try to restore account first if it exists.
            if ($RestoreFromRecycleBin)
            {
                Write-Verbose -Message ($script:localizedData.RestoringGroup -f $GroupName)

                $restoreParams = Get-ADCommonParameters @PSBoundParameters

                $adGroup = Restore-ADCommonObject @restoreParams -ObjectClass Group -ErrorAction Stop
            }

            if (-not $adGroup)
            {
                Write-Verbose -Message ($script:localizedData.AddingGroup -f $GroupName)

                $adGroup = New-ADGroup @adGroupParams -GroupCategory $Category -GroupScope $GroupScope -PassThru
            }

            <#
                Only the New-ADGroup cmdlet takes a -Name parameter. Refresh
                the parameters with the -Identity parameter rather than -Name.
            #>
            $adGroupParams = Get-ADCommonParameters @PSBoundParameters

            if ($Notes)
            {
                # Can't set the Notes field when creating the group
                Write-Verbose -Message ($script:localizedData.UpdatingGroupProperty -f 'Notes', $Notes)

                $setADGroupParams = $adGroupParams.Clone()
                $setADGroupParams['Identity'] = $adGroup.DistinguishedName

                Set-ADGroup @setADGroupParams -Add @{ Info = $Notes }
            }

            # Add the required members
            if ($PSBoundParameters.ContainsKey('Members') -and -not [system.string]::IsNullOrEmpty($Members))
            {
                $Members = Remove-DuplicateMembers -Members $Members

                Write-Verbose -Message ($script:localizedData.AddingGroupMembers -f $Members.Count, $GroupName)

                Add-ADCommonGroupMember -Parameter $adGroupParams -Members $Members -MembersInMultipleDomains:$MembersInMultipleDomains
            }
            elseif ($PSBoundParameters.ContainsKey('MembersToInclude') -and -not [system.string]::IsNullOrEmpty($MembersToInclude))
            {
                $MembersToInclude = Remove-DuplicateMembers -Members $MembersToInclude

                Write-Verbose -Message ($script:localizedData.AddingGroupMembers -f $MembersToInclude.Count, $GroupName)

                Add-ADCommonGroupMember -Parameter $adGroupParams -Members $MembersToInclude -MembersInMultipleDomains:$MembersInMultipleDomains
            }
        }
    } #end catch
} #end function Set-TargetResource

Export-ModuleMember -Function *-TargetResource
