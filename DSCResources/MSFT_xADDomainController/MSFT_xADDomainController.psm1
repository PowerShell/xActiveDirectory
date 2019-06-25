[Diagnostics.CodeAnalysis.SuppressMessageAttribute("AvoidUsingPlainTextForPassword", "",
        Justification = 'RODC Creation support($AllowPasswordReplicationAccountName and DenyPasswordReplicationAccountName)')]
$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'xActiveDirectory.Common'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'xActiveDirectory.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xADDomainController'

<#
    .SYNOPSIS
        Returns the current state of the domain controller.

    .PARAMETER DomainName
        Provide the FQDN of the domain the Domain Controller is being added to.

    .PARAMETER DomainAdministrationCredential
        Specifies the credential for the account used to install the domain controller.
        This account must have permission to access the other domain controllers
        in the domain to be able replicate domain information.

    .PARAMETER SafemodeAdministratorPassword
        Provide a password that will be used to set the DSRM password. This is a PSCredential.

    .PARAMETER DatabasePath
        Provide the path where the NTDS.dit will be created and stored.

    .PARAMETER LogPath
        Provide the path where the logs for the NTDS will be created and stored.

    .PARAMETER SysvolPath
        Provide the path where the Sysvol will be created and stored.

    .PARAMETER SiteName
        Provide the name of the site you want the Domain Controller to be added to.
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
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorPassword,

        [Parameter()]
        [System.String]
        $DatabasePath,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.String]
        $SysvolPath,

        [Parameter()]
        [System.String]
        $SiteName
    )

    Assert-Module -ModuleName 'ActiveDirectory'

    $getTargetResourceResult = @{
        DomainName           = $DomainName
        Ensure               = $false
        IsGlobalCatalog      = $false
    }

    Write-Verbose -Message (
        $script:localizedData.ResolveDomainName -f $DomainName
    )

    try
    {
        $domain = Get-ADDomain -Identity $DomainName -Credential $DomainAdministratorCredential
    }
    catch
    {
        $errorMessage = $script:localizedData.MissingDomain -f $DomainName
        New-ObjectNotFoundException -Message $errorMessage -ErrorRecord $_
    }

    Write-Verbose -Message (
        $script:localizedData.DomainPresent -f $DomainName
    )

    $domainControllerObject = Get-DomainControllerObject -DomainName $DomainName -ComputerName $env:COMPUTERNAME -Credential $DomainAdministratorCredential
    if ($domainControllerObject)
    {
        Write-Verbose -Message (
            $script:localizedData.FoundDomainController -f $domainControllerObject.Name, $domainControllerObject.Domain
        )

        Write-Verbose -Message (
            $script:localizedData.AlreadyDomainController -f $domainControllerObject.Name, $domainControllerObject.Domain
        )

        $allowedPasswordReplicationAccountName = Get-ADDomainControllerPasswordReplicationPolicy -Allowed -Identity $domainControllerObject |ForEach-Object sAMAccountName
        $deniedPasswordReplicationAccountName = Get-ADDomainControllerPasswordReplicationPolicy -Denied -Identity $domainControllerObject | ForEach-Object sAMAccountName
        $serviceNTDS = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters'
        $serviceNETLOGON = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'

        $getTargetResourceResult.Ensure = $true
        $getTargetResourceResult.DatabasePath = $serviceNTDS.'DSA Working Directory'
        $getTargetResourceResult.LogPath = $serviceNTDS.'Database log files path'
        $getTargetResourceResult.SysvolPath = $serviceNETLOGON.SysVol -replace '\\sysvol$', ''
        $getTargetResourceResult.SiteName = $domainControllerObject.Site
        $getTargetResourceResult.IsGlobalCatalog = $domainControllerObject.IsGlobalCatalog
        $getTargetResourceResult.DomainName = $domainControllerObject.Domain
        $getTargetResourceResult.AllowPasswordReplicationAccountName = $allowedPasswordReplicationAccountName
        $getTargetResourceResult.DenyPasswordReplicationAccountName = $deniedPasswordReplicationAccountName
    }
    else
    {
        Write-Verbose -Message (
            $script:localizedData.NotDomainController -f $env:COMPUTERNAME
        )
    }

    return $getTargetResourceResult
}

<#
    .SYNOPSIS
        Installs, or change properties on, a domain controller.

    .PARAMETER DomainName
        Provide the FQDN of the domain the Domain Controller is being added to.

    .PARAMETER DomainAdministrationCredential
        Specifies the credential for the account used to install the domain controller.
        This account must have permission to access the other domain controllers
        in the domain to be able replicate domain information.

    .PARAMETER SafemodeAdministratorPassword
        Provide a password that will be used to set the DSRM password. This is a PSCredential.

    .PARAMETER DatabasePath
        Provide the path where the NTDS.dit will be created and stored.

    .PARAMETER LogPath
        Provide the path where the logs for the NTDS will be created and stored.

    .PARAMETER SysvolPath
        Provide the path where the Sysvol will be created and stored.

    .PARAMETER SiteName
        Provide the name of the site you want the Domain Controller to be added to.

    .PARAMETER InstallationMediaPath
        Provide the path for the IFM folder that was created with ntdsutil.
        This should not be on a share but locally to the Domain Controller being promoted.

    .PARAMETER IsGlobalCatalog
        Specifies if the domain controller will be a Global Catalog (GC).

    .PARAMETER ReadOnlyReplica
        Specifies if the domain controller should be provisioned as read-only domain controller

    .PARAMETER AllowPasswordReplicationAccountName
        Provides a list of the users, computers, and groups to add to the password replication allowed list.

    .PARAMETER AllowPasswordReplicationAccountName
        Provides a list of the users, computers, and groups to add to the password replication denied list.
#>
function Set-TargetResource
{
    <#
        Suppressing this rule because $global:DSCMachineStatus is used to
        trigger a reboot for the one that was suppressed when calling
        Install-ADDSDomainController.
    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    <#
        Suppressing this rule because $global:DSCMachineStatus is only set,
        never used (by design of Desired State Configuration).
    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope='Function', Target='DSCMachineStatus')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorPassword,

        [Parameter()]
        [System.String]
        $DatabasePath,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.String]
        $SysvolPath,

        [Parameter()]
        [System.String]
        $SiteName,

        [Parameter()]
        [System.String]
        $InstallationMediaPath,

        [Parameter()]
        [System.Boolean]
        $IsGlobalCatalog,

        [Parameter()]
        [System.Boolean]
        $ReadOnlyReplica,

        [Parameter()]
        [System.String[]]
        $AllowPasswordReplicationAccountName,

        [Parameter()]
        [System.String[]]
        $DenyPasswordReplicationAccountName
    )

    $getTargetResourceParameters = @{} + $PSBoundParameters
    $getTargetResourceParameters.Remove('InstallationMediaPath')
    $getTargetResourceParameters.Remove('IsGlobalCatalog')
    $getTargetResourceParameters.Remove('ReadOnlyReplica')
    $getTargetResourceParameters.Remove('AllowPasswordReplicationAccountName')
    $getTargetResourceParameters.Remove('DenyPasswordReplicationAccountName')
    $targetResource = Get-TargetResource @getTargetResourceParameters

    if ($targetResource.Ensure -eq $false)
    {
        Write-Verbose -Message (
            $script:localizedData.Promoting -f $env:COMPUTERNAME, $DomainName
        )

        # Node is not a domain controller so we promote it.
        $installADDSDomainControllerParameters = @{
            DomainName                    = $DomainName
            SafeModeAdministratorPassword = $SafemodeAdministratorPassword.Password
            Credential                    = $DomainAdministratorCredential
            NoRebootOnCompletion          = $true
            Force                         = $true
        }
        if($PSBoundParameters.ContainsKey('ReadOnlyReplica') -and $ReadOnlyReplica -eq $true)
        {
            if($PSBoundParameters.ContainsKey('SiteName') -eq $false)
            {
                New-InvalidOperationException -Message $script:localizedData.RODCMissingSite
            }
            $installADDSDomainControllerParameters.Add('ReadOnlyReplica', $true)
        }

        if($PSBoundParameters.ContainsKey('AllowPasswordReplicationAccountName'))
        {
            $installADDSDomainControllerParameters.Add('AllowPasswordReplicationAccountName', $AllowPasswordReplicationAccountName)
        }

        if($PSBoundParameters.ContainsKey('DenyPasswordReplicationAccountName'))
        {
            $installADDSDomainControllerParameters.Add('DenyPasswordReplicationAccountName', $DenyPasswordReplicationAccountName)
        }

        if ($PSBoundParameters.ContainsKey('DatabasePath'))
        {
            $installADDSDomainControllerParameters.Add('DatabasePath', $DatabasePath)
        }

        if ($PSBoundParameters.ContainsKey('LogPath'))
        {
            $installADDSDomainControllerParameters.Add('LogPath', $LogPath)
        }

        if ($PSBoundParameters.ContainsKey('SysvolPath'))
        {
            $installADDSDomainControllerParameters.Add('SysvolPath', $SysvolPath)
        }

        if ($PSBoundParameters.ContainsKey('SiteName') -and $SiteName)
        {
            $installADDSDomainControllerParameters.Add('SiteName', $SiteName)
        }

        if ($PSBoundParameters.ContainsKey('IsGlobalCatalog') -and $IsGlobalCatalog -eq $false)
        {
            $installADDSDomainControllerParameters.Add('NoGlobalCatalog', $true)
        }

        if (-not [System.String]::IsNullOrWhiteSpace($InstallationMediaPath))
        {
            $installADDSDomainControllerParameters.Add('InstallationMediaPath', $InstallationMediaPath)
        }

        Install-ADDSDomainController @installADDSDomainControllerParameters

        Write-Verbose -Message (
            $script:localizedData.Promoted -f $env:COMPUTERNAME, $DomainName
        )

        <#
            Signal to the LCM to reboot the node to compensate for the one we
            suppressed from Install-ADDSDomainController
        #>
        $global:DSCMachineStatus = 1
    }
    elseif ($targetResource.Ensure)
    {
        # Node is a domain controller. We check if other properties are in desired state

        Write-Verbose -Message (
            $script:localizedData.IsDomainController -f $env:COMPUTERNAME, $DomainName
        )

        $domainControllerObject = Get-DomainControllerObject -DomainName $DomainName -ComputerName $env:COMPUTERNAME -Credential $DomainAdministratorCredential

        # Check if Node Global Catalog state is correct
        if ($PSBoundParameters.ContainsKey('IsGlobalCatalog') -and $targetResource.IsGlobalCatalog -ne $IsGlobalCatalog)
        {
            # DC is not in the expected Global Catalog state
            if ($IsGlobalCatalog)
            {
                $globalCatalogOptionValue = 1

                Write-Verbose -Message $script:localizedData.AddGlobalCatalog
            }
            else
            {
                $globalCatalogOptionValue = 0

                Write-Verbose -Message $script:localizedData.RemoveGlobalCatalog
            }

            if ($domainControllerObject)
            {
                Set-ADObject -Identity $domainControllerObject.NTDSSettingsObjectDN -Replace @{
                    options = $globalCatalogOptionValue
                }
            }
            else
            {
                $errorMessage = $script:localizedData.ExpectedDomainController
                New-ObjectNotFoundException -Message $errorMessage
            }
        }

        if ($PSBoundParameters.ContainsKey('SiteName') -and $targetResource.SiteName -ne $SiteName)
        {
            Write-Verbose -Message (
                $script:localizedData.IsDomainController -f $targetResource.SiteName, $SiteName
            )

            # DC is not in correct site. Move it.
            Write-Verbose -Message ($script:localizedData.MovingDomainController -f $targetResource.SiteName, $SiteName)
            Move-ADDirectoryServer -Identity $env:COMPUTERNAME -Site $SiteName -Credential $DomainAdministratorCredential
        }

        if($PSBoundParameters.ContainsKey('AllowPasswordReplicationAccountName'))
        {
            $testMembersParams = @{
                ExistingMembers = $targetResource.AllowPasswordReplicationAccountName
                Members         = $AllowPasswordReplicationAccountName;
            }
            if (-not (Test-Members @testMembersParams))
            {
                $adPrincipalsToRemove = foreach ($accountName in $targetResource.AllowPasswordReplicationAccountName)
                {
                    New-Object -TypeName Microsoft.ActiveDirectory.Management.ADPrincipal -ArgumentList $accountName
                }
                $removeADPasswordPolicy = @{
                    Identity    = $domainControllerObject
                    AllowedList = $adPrincipalsToRemove
                }
                $adPrincipalsToAdd = foreach ($accountName in $AllowPasswordReplicationAccountName)
                {
                    New-Object -TypeName Microsoft.ActiveDirectory.Management.ADPrincipal -ArgumentList $accountName
                }
                $addADPasswordPolicy = @{
                    Identity    = $domainControllerObject
                    AllowedList = $adPrincipalsToAdd
                }
                Write-Verbose -Message (
                $script:localizedData.AllowedSyncAccountsMismatch -f
                ($targetResource.AllowPasswordReplicationAccountName -join ';'),
                ($AllowPasswordReplicationAccountName -join ';')
                )
                Remove-ADDomainControllerPasswordReplicationPolicy @removeADPasswordPolicy
                Add-ADDomainControllerPasswordReplicationPolicy @addADPasswordPolicy
            }
        }

        if($PSBoundParameters.ContainsKey('DenyPasswordReplicationAccountName'))
        {
            $testMembersParams = @{
                ExistingMembers = $targetResource.DenyPasswordReplicationAccountName
                Members         = $DenyPasswordReplicationAccountName;
            }
            if (-not (Test-Members @testMembersParams))
            {
                $adPrincipalsToRemove = foreach ($accountName in $targetResource.DenyPasswordReplicationAccountName)
                {
                    New-Object -TypeName Microsoft.ActiveDirectory.Management.ADPrincipal -ArgumentList $accountName
                }
                $removeADPasswordPolicy = @{
                    Identity    = $domainControllerObject
                    DeniedList  = $adPrincipalsToRemove
                }
                $adPrincipalsToAdd = foreach ($accountName in $DenyPasswordReplicationAccountName)
                {
                    New-Object -TypeName Microsoft.ActiveDirectory.Management.ADPrincipal -ArgumentList $accountName
                }
                $addADPasswordPolicy = @{
                    Identity    = $domainControllerObject
                    DeniedList  = $adPrincipalsToAdd
                }
                Write-Verbose -Message (
                    $script:localizedData.DenySyncAccountsMismatch -f
                ($existingResource.DenyPasswordReplicationAccountName -join ';'),
                ($DenyPasswordReplicationAccountName -join ';')
                )
                Remove-ADDomainControllerPasswordReplicationPolicy @removeADPasswordPolicy
                Add-ADDomainControllerPasswordReplicationPolicy @addADPasswordPolicy
            }
        }
    }
}

<#
    .SYNOPSIS
        Determines if the domain controller is in desired state.

    .PARAMETER DomainName
        Provide the FQDN of the domain the Domain Controller is being added to.

    .PARAMETER DomainAdministrationCredential
        Specifies the credential for the account used to install the domain controller.
        This account must have permission to access the other domain controllers
        in the domain to be able replicate domain information.

    .PARAMETER SafemodeAdministratorPassword
        Provide a password that will be used to set the DSRM password. This is a PSCredential.

    .PARAMETER DatabasePath
        Provide the path where the NTDS.dit will be created and stored.

    .PARAMETER LogPath
        Provide the path where the logs for the NTDS will be created and stored.

    .PARAMETER SysvolPath
        Provide the path where the Sysvol will be created and stored.

    .PARAMETER SiteName
        Provide the name of the site you want the Domain Controller to be added to.

    .PARAMETER InstallationMediaPath
        Provide the path for the IFM folder that was created with ntdsutil.
        This should not be on a share but locally to the Domain Controller being promoted.

    .PARAMETER IsGlobalCatalog
        Specifies if the domain controller will be a Global Catalog (GC).

    .PARAMETER ReadOnlyReplica
        Specifies if the domain controller should be provisioned as read-only domain controller

    .PARAMETER AllowPasswordReplicationAccountName
        Provides a list of the users, computers, and groups to add to the password replication allowed list.

    .PARAMETER AllowPasswordReplicationAccountName
        Provides a list of the users, computers, and groups to add to the password replication denied list.
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
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorPassword,

        [Parameter()]
        [System.String]
        $DatabasePath,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.String]
        $SysvolPath,

        [Parameter()]
        [System.String]
        $SiteName,

        [Parameter()]
        [System.String]
        $InstallationMediaPath,

        [Parameter()]
        [System.Boolean]
        $IsGlobalCatalog,

        [Parameter()]
        [System.Boolean]
        $ReadOnlyReplica,

        [Parameter()]
        [System.String[]]
        $AllowPasswordReplicationAccountName,

        [Parameter()]
        [System.String[]]
        $DenyPasswordReplicationAccountName
    )

    Write-Verbose -Message (
        $script:localizedData.TestingConfiguration -f $env:COMPUTERNAME, $DomainName
    )

    if ($PSBoundParameters.SiteName)
    {
        if (-not (Test-ADReplicationSite -SiteName $SiteName -DomainName $DomainName -Credential $DomainAdministratorCredential))
        {
            $errorMessage = $script:localizedData.FailedToFindSite -f $SiteName, $DomainName
            New-ObjectNotFoundException -Message $errorMessage
        }
    }

    $getTargetResourceParameters = @{} + $PSBoundParameters
    $getTargetResourceParameters.Remove('InstallationMediaPath')
    $getTargetResourceParameters.Remove('IsGlobalCatalog')
    $getTargetResourceParameters.Remove('ReadOnlyReplica')
    $getTargetResourceParameters.Remove('AllowPasswordReplicationAccountName')
    $getTargetResourceParameters.Remove('DenyPasswordReplicationAccountName')
    $existingResource = Get-TargetResource @getTargetResourceParameters

    $testTargetResourceReturnValue = $existingResource.Ensure

    if ($PSBoundParameters.ContainsKey('SiteName') -and $existingResource.SiteName -ne $SiteName)
    {
        Write-Verbose -Message (
            $script:localizedData.WrongSite -f $existingResource.SiteName, $SiteName
        )

        $testTargetResourceReturnValue = $false
    }

    # Check Global Catalog Config
    if ($PSBoundParameters.ContainsKey('IsGlobalCatalog') -and $existingResource.IsGlobalCatalog -ne $IsGlobalCatalog)
    {
        if ($IsGlobalCatalog)
        {
            Write-Verbose -Message (
                $script:localizedData.ExpectedGlobalCatalogEnabled -f $existingResource.SiteName, $SiteName
            )
        }
        else
        {
            Write-Verbose -Message (
                $script:localizedData.ExpectedGlobalCatalogDisabled -f $existingResource.SiteName, $SiteName
            )
        }

        $testTargetResourceReturnValue = $false
    }

    if($PSBoundParameters.ContainsKey('AllowPasswordReplicationAccountName') -and
    $null -ne $existingResource.AllowPasswordReplicationAccountName)
    {
        $testMembersParams = @{
            ExistingMembers = $existingResource.AllowPasswordReplicationAccountName
            Members         = $AllowPasswordReplicationAccountName;
        }
        if(-not (Test-Members @testMembersParams))
        {
            Write-Verbose -Message (
                $script:localizedData.AllowedSyncAccountsMismatch -f
                ($existingResource.AllowPasswordReplicationAccountName -join ';'),
                ($AllowPasswordReplicationAccountName -join ';')
            )
            $testTargetResourceReturnValue = $false
        }
    }

    if($PSBoundParameters.ContainsKey('DenyPasswordReplicationAccountName') -and
    $null -ne $existingResource.DenyPasswordReplicationAccountName)
    {
        $testMembersParams = @{
            ExistingMembers = $existingResource.DenyPasswordReplicationAccountName
            Members         = $DenyPasswordReplicationAccountName;
        }
        if(-not (Test-Members @testMembersParams))
        {
            Write-Verbose -Message (
                $script:localizedData.DenySyncAccountsMismatch -f
                ($existingResource.DenyPasswordReplicationAccountName -join ';'),
                ($DenyPasswordReplicationAccountName -join ';')
            )
            $testTargetResourceReturnValue = $false
        }
    }

    return $testTargetResourceReturnValue
}

Export-ModuleMember -Function *-TargetResource
