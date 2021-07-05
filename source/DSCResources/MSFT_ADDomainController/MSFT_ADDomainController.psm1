$resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$modulesFolderPath = Join-Path -Path $resourceModulePath -ChildPath 'Modules'

$aDCommonModulePath = Join-Path -Path $modulesFolderPath -ChildPath 'ActiveDirectoryDsc.Common'
Import-Module -Name $aDCommonModulePath

$dscResourceCommonModulePath = Join-Path -Path $modulesFolderPath -ChildPath 'DscResource.Common'
Import-Module -Name $dscResourceCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        Returns the current state of the domain controller.

    .PARAMETER DomainName
        Provide the FQDN of the domain the Domain Controller is being added to.

    .PARAMETER Credential
        Specifies the credential for the account used to install the domain controller.
        This account must have permission to access the other domain controllers
        in the domain to be able replicate domain information.

    .PARAMETER SafemodeAdministratorPassword
        Provide a password that will be used to set the DSRM password. This is a PSCredential.

    .NOTES
        Used Functions:
            Name                                            | Module
            ------------------------------------------------|--------------------------
            Get-ADDomain                                    | ActiveDirectory
            Get-ADDomainControllerPasswordReplicationPolicy | ActiveDirectory
            Get-DomainControllerObject                      | ActiveDirectoryDsc.Common
            Assert-Module                                   | DscResource.Common
            New-ObjectNotFoundException                     | DscResource.Common
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
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorPassword
    )

    Assert-Module -ModuleName 'ActiveDirectory'

    Write-Verbose -Message ($script:localizedData.ResolveDomainName -f $DomainName)

    try
    {
        $domain = Get-ADDomain -Identity $DomainName -Credential $Credential
    }
    catch
    {
        $errorMessage = $script:localizedData.MissingDomain -f $DomainName
        New-ObjectNotFoundException -Message $errorMessage -ErrorRecord $_
    }

    Write-Verbose -Message ($script:localizedData.DomainPresent -f $DomainName)

    $domainControllerObject = Get-DomainControllerObject `
        -DomainName $DomainName -ComputerName $env:COMPUTERNAME -Credential $Credential

    if ($domainControllerObject)
    {
        Write-Verbose -Message ($script:localizedData.IsDomainController -f
            $domainControllerObject.Name, $domainControllerObject.Domain)

        $allowedPasswordReplicationAccountName = (
            Get-ADDomainControllerPasswordReplicationPolicy -Allowed -Identity $domainControllerObject |
                ForEach-Object -MemberName sAMAccountName)
        $deniedPasswordReplicationAccountName = (
            Get-ADDomainControllerPasswordReplicationPolicy -Denied -Identity $domainControllerObject |
                ForEach-Object -MemberName sAMAccountName)
        $serviceNTDS = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters'
        $serviceNETLOGON = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
        $installDns = [System.Boolean](Get-Service -Name dns -ErrorAction SilentlyContinue)

        $targetResource = @{
            AllowPasswordReplicationAccountName = @($allowedPasswordReplicationAccountName)
            Credential                          = $Credential
            DatabasePath                        = $serviceNTDS.'DSA Working Directory'
            DenyPasswordReplicationAccountName  = @($deniedPasswordReplicationAccountName)
            DomainName                          = $domainControllerObject.Domain
            Ensure                              = $true
            FlexibleSingleMasterOperationRole   = @($domainControllerObject.OperationMasterRoles)
            InstallationMediaPath               = $null
            InstallDns                          = $installDns
            IsGlobalCatalog                     = $domainControllerObject.IsGlobalCatalog
            LogPath                             = $serviceNTDS.'Database log files path'
            ReadOnlyReplica                     = $domainControllerObject.IsReadOnly
            SafemodeAdministratorPassword       = $SafemodeAdministratorPassword
            SiteName                            = $domainControllerObject.Site
            SysvolPath                          = $serviceNETLOGON.SysVol -replace '\\sysvol$', ''
        }
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.NotDomainController -f $env:COMPUTERNAME)

        $targetResource = @{
            AllowPasswordReplicationAccountName = $null
            Credential                          = $Credential
            DatabasePath                        = $null
            DenyPasswordReplicationAccountName  = $null
            DomainName                          = $DomainName
            Ensure                              = $false
            FlexibleSingleMasterOperationRole   = $null
            InstallationMediaPath               = $null
            InstallDns                          = $false
            IsGlobalCatalog                     = $false
            LogPath                             = $null
            ReadOnlyReplica                     = $false
            SafemodeAdministratorPassword       = $SafemodeAdministratorPassword
            SiteName                            = $null
            SysvolPath                          = $null
        }
    }

    return $targetResource
}

<#
    .SYNOPSIS
        Installs, or change properties on, a domain controller.

    .PARAMETER DomainName
        Provide the FQDN of the domain the Domain Controller is being added to.

    .PARAMETER Credential
        Specifies the credential for the account used to install the domain controller.
        This account must have permission to access the other domain controllers
        in the domain to be able replicate domain information.

    .PARAMETER SafemodeAdministratorPassword
        Provide a password that will be used to set the DSRM password. This is a PSCredential.

    .PARAMETER Ensure
        Specifies if the node will be configured as a domain controller

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

    .PARAMETER DenyPasswordReplicationAccountName
        Provides a list of the users, computers, and groups to add to the password replication denied list.

    .PARAMETER FlexibleSingleMasterOperationRole
        Specifies one or more Flexible Single Master Operation (FSMO) roles to
        move to this domain controller. The current owner must be online and
        responding for the move to be allowed.

    .PARAMETER InstallDns
        Specifies if the DNS Server service should be installed and configured on
        the domain controller. If this is not set the default value of the parameter
        InstallDns of the cmdlet Install-ADDSDomainController is used.
        The parameter `InstallDns` is only used during the provisioning of a domain
        controller. The parameter cannot be used to install or uninstall the DNS
        server on an already provisioned domain controller.
    .NOTES
        Used Functions:
            Name                                               | Module
            ---------------------------------------------------|--------------------------
            Install-ADDSDomainController                       | ActiveDirectory
            Test-ADDSDomainControllerUninstallation            | ActiveDirectory
            Uninstall-ADDSDomainController                     | ActiveDirectory
            Get-ADDomain                                       | ActiveDirectory
            Get-ADForest                                       | ActiveDirectory
            Set-ADObject                                       | ActiveDirectory
            Move-ADDirectoryServer                             | ActiveDirectory
            Move-ADDirectoryServerOperationMasterRole          | ActiveDirectory
            Remove-ADDomainControllerPasswordReplicationPolicy | ActiveDirectory
            Add-ADDomainControllerPasswordReplicationPolicy    | ActiveDirectory
            Get-DomainControllerObject                         | ActiveDirectoryDsc.Common
            New-InvalidOperationException                      | DscResource.Common
#>
function Set-TargetResource
{
    <#
        Suppressing this rule because $global:DSCMachineStatus is used to
        trigger a reboot for the one that was suppressed when calling
        Install-ADDSDomainController.
    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '',
        Justification = 'Read-Only Domain Controller (RODC) Creation support(AllowPasswordReplicationAccountName and DenyPasswordReplicationAccountName)')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorPassword,

        [Parameter()]
        [ValidateSet('Absent', 'Present')]
        [System.String]
        $Ensure = 'Present',

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
        $DenyPasswordReplicationAccountName,

        [Parameter()]
        [ValidateSet('DomainNamingMaster', 'SchemaMaster', 'InfrastructureMaster', 'PDCEmulator', 'RIDMaster')]
        [System.String[]]
        $FlexibleSingleMasterOperationRole,

        [Parameter()]
        [System.Boolean]
        $InstallDns
    )

    $getTargetResourceParameters = @{
        DomainName                    = $DomainName
        Credential                    = $Credential
        SafeModeAdministratorPassword = $SafemodeAdministratorPassword
    }

    $targetResource = Get-TargetResource @getTargetResourceParameters

    if ($targetResource.Ensure)
    {
        $ensureValue = 'Present'
    }
    else
    {
        $ensureValue = 'Absent'
    }


    if ($Ensure -eq 'Absent')
    {
        if ($targetResource.Ensure -eq $false)
        {
            break
        }

        # Test to make sure the domain controller can be removed from the domain
        $ADDSDomainUninstallationParameters = @{
            LocalAdministratorPassword = $SafemodeAdministratorPassword.Password
            Credential                 = $Credential
            NoRebootOnCompletion       = $true
            Force                      = $true
        }
        $testStatus = Test-ADDSDomainControllerUninstallation @ADDSDomainUninstallationParameters

        if ($testStatus.Status -eq 'Error')
        {
            New-InvalidOperationException -Message ($script:localizedData.TestDemoteStatus -f $testStatus.Status, $testStatus.Message)
        }
        elseif ($testStatus.Status -eq 'Success')
        {
            # No issues found that will cause issues demoting the domain controller
            try
            {
                Uninstall-ADDSDomainController @ADDSDomainUninstallationParameters -ErrorAction Stop
                Write-Verbose -Message ($script:localizedData.Demoted -f $env:COMPUTERNAME)
            }
            catch
            {
                $errorMessage = $script:localizedData.FailedToDemote
                New-InvalidResultException -Message $errorMessage -ErrorRecord $_
            }
            <#
                Signal to the LCM to reboot the node to compensate for the one we
                suppressed from Uninstall-ADDSDomainController
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
                Justification = 'Set LCM DSCMachineStatus to indicate reboot required')]
            $global:DSCMachineStatus = 1
        }
    }
    elseif ($targetResource.Ensure -eq $false)
    {
        Write-Verbose -Message ($script:localizedData.Promoting -f $env:COMPUTERNAME, $DomainName)

        # Node is not a domain controller so we promote it.
        $installADDSDomainControllerParameters = @{
            DomainName                    = $DomainName
            SafeModeAdministratorPassword = $SafemodeAdministratorPassword.Password
            Credential                    = $Credential
            NoRebootOnCompletion          = $true
            Force                         = $true
        }

        if ($PSBoundParameters.ContainsKey('ReadOnlyReplica') -and $ReadOnlyReplica -eq $true)
        {
            if (-not $PSBoundParameters.ContainsKey('SiteName'))
            {
                New-InvalidOperationException -Message $script:localizedData.RODCMissingSite
            }

            $installADDSDomainControllerParameters.Add('ReadOnlyReplica', $true)
        }

        if ($PSBoundParameters.ContainsKey('AllowPasswordReplicationAccountName'))
        {
            $installADDSDomainControllerParameters.Add('AllowPasswordReplicationAccountName',
                $AllowPasswordReplicationAccountName)
        }

        if ($PSBoundParameters.ContainsKey('DenyPasswordReplicationAccountName'))
        {
            $installADDSDomainControllerParameters.Add('DenyPasswordReplicationAccountName',
                $DenyPasswordReplicationAccountName)
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

        if ($PSBoundParameters.ContainsKey('InstallDns'))
        {
            $installADDSDomainControllerParameters.Add('InstallDns', $InstallDns)
        }

        if (-not [System.String]::IsNullOrWhiteSpace($InstallationMediaPath))
        {
            $installADDSDomainControllerParameters.Add('InstallationMediaPath', $InstallationMediaPath)
        }

        Install-ADDSDomainController @installADDSDomainControllerParameters

        Write-Verbose -Message ($script:localizedData.Promoted -f $env:COMPUTERNAME, $DomainName)

        <#
            Signal to the LCM to reboot the node to compensate for the one we
            suppressed from Install-ADDSDomainController
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
            Justification = 'Set LCM DSCMachineStatus to indicate reboot required')]
        $global:DSCMachineStatus = 1
    }
    elseif ($targetResource.Ensure)
    {
        # Node is a domain controller. We check if other properties are in desired state

        Write-Verbose -Message ($script:localizedData.IsDomainController -f $env:COMPUTERNAME, $DomainName)

        $domainControllerObject = Get-DomainControllerObject `
            -DomainName $DomainName -ComputerName $env:COMPUTERNAME -Credential $Credential

        # Check if Node Global Catalog state is correct
        if ($PSBoundParameters.ContainsKey('IsGlobalCatalog') -and
            $targetResource.IsGlobalCatalog -ne $IsGlobalCatalog)
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

            Set-ADObject -Identity $domainControllerObject.NTDSSettingsObjectDN -Replace @{
                options = $globalCatalogOptionValue
            }
        }

        if ($PSBoundParameters.ContainsKey('SiteName') -and $targetResource.SiteName -ne $SiteName)
        {
            # DC is not in correct site. Move it.
            Write-Verbose -Message ($script:localizedData.MovingDomainController -f
                $targetResource.SiteName, $SiteName)

            Move-ADDirectoryServer -Identity $env:COMPUTERNAME -Site $SiteName -Credential $Credential
        }

        if ($PSBoundParameters.ContainsKey('AllowPasswordReplicationAccountName'))
        {
            $testMembersParameters = @{
                ExistingMembers = $targetResource.AllowPasswordReplicationAccountName
                Members         = $AllowPasswordReplicationAccountName
            }

            if (-not (Test-Members @testMembersParameters))
            {
                Write-Verbose -Message (
                    $script:localizedData.AllowedSyncAccountsMismatch -f
                    ($targetResource.AllowPasswordReplicationAccountName -join ';'),
                    ($AllowPasswordReplicationAccountName -join ';')
                )

                $getMembersToAddAndRemoveParameters = @{
                    DesiredMembers = $AllowPasswordReplicationAccountName
                    CurrentMembers = $targetResource.AllowPasswordReplicationAccountName
                }

                $getMembersToAddAndRemoveResult = Get-MembersToAddAndRemove @getMembersToAddAndRemoveParameters

                $adPrincipalsToRemove = $getMembersToAddAndRemoveResult.MembersToRemove
                $adPrincipalsToAdd = $getMembersToAddAndRemoveResult.MembersToAdd

                if ($null -ne $adPrincipalsToRemove)
                {
                    $removeADPasswordReplicationPolicy = @{
                        Identity    = $domainControllerObject
                        AllowedList = $adPrincipalsToRemove
                    }

                    Remove-ADDomainControllerPasswordReplicationPolicy @removeADPasswordReplicationPolicy `
                        -Confirm:$false
                }

                if ($null -ne $adPrincipalsToAdd)
                {
                    $addADPasswordReplicationPolicy = @{
                        Identity    = $domainControllerObject
                        AllowedList = $adPrincipalsToAdd
                    }

                    Add-ADDomainControllerPasswordReplicationPolicy @addADPasswordReplicationPolicy
                }
            }
        }

        if ($PSBoundParameters.ContainsKey('DenyPasswordReplicationAccountName'))
        {
            $testMembersParameters = @{
                ExistingMembers = $targetResource.DenyPasswordReplicationAccountName
                Members         = $DenyPasswordReplicationAccountName;
            }

            if (-not (Test-Members @testMembersParameters))
            {
                Write-Verbose -Message (
                    $script:localizedData.DenySyncAccountsMismatch -f
                    ($targetResource.DenyPasswordReplicationAccountName -join ';'),
                    ($DenyPasswordReplicationAccountName -join ';')
                )

                $getMembersToAddAndRemoveParameters = @{
                    DesiredMembers = $DenyPasswordReplicationAccountName
                    CurrentMembers = $targetResource.DenyPasswordReplicationAccountName
                }

                $getMembersToAddAndRemoveResult = Get-MembersToAddAndRemove @getMembersToAddAndRemoveParameters

                $adPrincipalsToRemove = $getMembersToAddAndRemoveResult.MembersToRemove
                $adPrincipalsToAdd = $getMembersToAddAndRemoveResult.MembersToAdd

                if ($null -ne $adPrincipalsToRemove)
                {
                    $removeADPasswordReplicationPolicy = @{
                        Identity   = $domainControllerObject
                        DeniedList = $adPrincipalsToRemove
                    }

                    Remove-ADDomainControllerPasswordReplicationPolicy @removeADPasswordReplicationPolicy `
                        -Confirm:$false
                }

                if ($null -ne $adPrincipalsToAdd)
                {
                    $addADPasswordReplicationPolicy = @{
                        Identity   = $domainControllerObject
                        DeniedList = $adPrincipalsToAdd
                    }

                    Add-ADDomainControllerPasswordReplicationPolicy @addADPasswordReplicationPolicy
                }

            }
        }

        if ($PSBoundParameters.ContainsKey('FlexibleSingleMasterOperationRole'))
        {
            foreach ($desiredFlexibleSingleMasterOperationRole in $FlexibleSingleMasterOperationRole)
            {
                if ($desiredFlexibleSingleMasterOperationRole -notin $targetResource.FlexibleSingleMasterOperationRole)
                {
                    switch ($desiredFlexibleSingleMasterOperationRole)
                    {
                        <#
                            Connect to any available domain controller to get the
                            current owner for the specific role.
                        #>
                        { $_ -in @('DomainNamingMaster', 'SchemaMaster') }
                        {
                            $currentOwnerFullyQualifiedDomainName = (Get-ADForest).$_
                        }

                        { $_ -in @('InfrastructureMaster', 'PDCEmulator', 'RIDMaster') }
                        {
                            $currentOwnerFullyQualifiedDomainName = (Get-ADDomain).$_
                        }
                    }

                    Write-Verbose -Message ($script:localizedData.MovingFlexibleSingleMasterOperationRole -f
                        $desiredFlexibleSingleMasterOperationRole, $currentOwnerFullyQualifiedDomainName)

                    <#
                        Using the object returned from Get-ADDomainController to handle
                        an issue with calling Move-ADDirectoryServerOperationMasterRole
                        with Fully Qualified Domain Name (FQDN) in the Identity parameter.
                    #>
                    $MoveADDirectoryServerOperationMasterRoleParameters = @{
                        Identity            = $domainControllerObject
                        OperationMasterRole = $desiredFlexibleSingleMasterOperationRole
                        Server              = $currentOwnerFullyQualifiedDomainName
                        ErrorAction         = 'Stop'
                    }

                    Move-ADDirectoryServerOperationMasterRole @MoveADDirectoryServerOperationMasterRoleParameters
                }
            }
        }
    }
}

<#
    .SYNOPSIS
        Determines if the domain controller is in desired state.

    .PARAMETER DomainName
        Provide the FQDN of the domain the Domain Controller is being added to.

    .PARAMETER Credential
        Specifies the credential for the account used to install the domain controller.
        This account must have permission to access the other domain controllers
        in the domain to be able replicate domain information.

    .PARAMETER SafemodeAdministratorPassword
        Provide a password that will be used to set the DSRM password. This is a PSCredential.

    .PARAMETER Ensure
        Specifies if the node will be configured as a domain controller

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

    .PARAMETER DenyPasswordReplicationAccountName
        Provides a list of the users, computers, and groups to add to the password replication denied list.

    .PARAMETER FlexibleSingleMasterOperationRole
        Specifies one or more Flexible Single Master Operation (FSMO) roles to
        move to this domain controller. The current owner must be online and
        responding for the move to be allowed.

    .PARAMETER InstallDns
        Specifies if the DNS Server service should be installed and configured on
        the domain controller. If this is not set the default value of the parameter
        InstallDns of the cmdlet Install-ADDSDomainController is used.
        The parameter `InstallDns` is only used during the provisioning of a domain
        controller. The parameter cannot be used to install or uninstall the DNS
        server on an already provisioned domain controller.

        Not used in Test-TargetResource.

    .NOTES
        Used Functions:
            Name                          | Module
            ------------------------------|--------------------------
            Test-ADReplicationSite        | ActiveDirectoryDsc.Common
            Test-Members                  | ActiveDirectoryDsc.Common
            New-InvalidOperationException | DscResource.Common
            New-ObjectNotFoundException   | DscResource.Common
#>
function Test-TargetResource
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "",
        Justification = 'Read-Only Domain Controller (RODC) Creation support($AllowPasswordReplicationAccountName and DenyPasswordReplicationAccountName)')]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorPassword,

        [Parameter()]
        [ValidateSet('Absent', 'Present')]
        [System.String]
        $Ensure = 'Present',

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
        $DenyPasswordReplicationAccountName,

        [Parameter()]
        [ValidateSet('DomainNamingMaster', 'SchemaMaster', 'InfrastructureMaster', 'PDCEmulator', 'RIDMaster')]
        [System.String[]]
        $FlexibleSingleMasterOperationRole,

        [Parameter()]
        [System.Boolean]
        $InstallDns
    )

    Write-Verbose -Message ($script:localizedData.TestingConfiguration -f $env:COMPUTERNAME, $DomainName)

    if ($PSBoundParameters.ContainsKey('ReadOnlyReplica') -and $ReadOnlyReplica -eq $true)
    {
        if (-not $PSBoundParameters.ContainsKey('SiteName'))
        {
            New-InvalidOperationException -Message $script:localizedData.RODCMissingSite
        }
    }

    if ($PSBoundParameters.ContainsKey('SiteName'))
    {
        if (-not (Test-ADReplicationSite -SiteName $SiteName -DomainName $DomainName -Credential $Credential))
        {
            $errorMessage = $script:localizedData.FailedToFindSite -f $SiteName, $DomainName
            New-ObjectNotFoundException -Message $errorMessage
        }
    }

    $getTargetResourceParameters = @{
        DomainName                    = $DomainName
        Credential                    = $Credential
        SafeModeAdministratorPassword = $SafemodeAdministratorPassword
    }

    $existingResource = Get-TargetResource @getTargetResourceParameters

    $testTargetResourceReturnValue = $existingResource.Ensure

    if ($testTargetResourceReturnValue)
    {
        $ensureValue = 'Present'
    }
    else
    {
        $ensureValue = 'Absent'
    }


    if ($ensureValue -ne $Ensure)
    {
        Write-Verbose -Message ($script:localizedData.EnsureMismatch -f $ensureValue, $Ensure)
        $testTargetResourceReturnValue = $false
    }

    if ($PSBoundParameters.ContainsKey('ReadOnlyReplica') -and $ReadOnlyReplica)
    {
        if ($testTargetResourceReturnValue -and -not $existingResource.ReadOnlyReplica)
        {
            New-InvalidOperationException -Message $script:localizedData.CannotConvertToRODC
        }
    }

    if ($PSBoundParameters.ContainsKey('SiteName') -and $existingResource.SiteName -ne $SiteName)
    {
        Write-Verbose -Message ($script:localizedData.WrongSite -f $existingResource.SiteName, $SiteName)

        $testTargetResourceReturnValue = $false
    }

    # Check Global Catalog Config
    if ($PSBoundParameters.ContainsKey('IsGlobalCatalog') -and $existingResource.IsGlobalCatalog -ne $IsGlobalCatalog)
    {
        if ($IsGlobalCatalog)
        {
            Write-Verbose -Message ($script:localizedData.ExpectedGlobalCatalogEnabled -f
                $existingResource.SiteName, $SiteName)
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.ExpectedGlobalCatalogDisabled -f
                $existingResource.SiteName, $SiteName)
        }

        $testTargetResourceReturnValue = $false
    }

    if ($PSBoundParameters.ContainsKey('AllowPasswordReplicationAccountName') -and
        $null -ne $existingResource.AllowPasswordReplicationAccountName)
    {
        $testMembersParameters = @{
            ExistingMembers = $existingResource.AllowPasswordReplicationAccountName
            Members         = $AllowPasswordReplicationAccountName
        }

        if (-not (Test-Members @testMembersParameters))
        {
            Write-Verbose -Message (
                $script:localizedData.AllowedSyncAccountsMismatch -f
                ($existingResource.AllowPasswordReplicationAccountName -join ';'),
                ($AllowPasswordReplicationAccountName -join ';')
            )

            $testTargetResourceReturnValue = $false
        }
    }

    if ($PSBoundParameters.ContainsKey('DenyPasswordReplicationAccountName') -and
        $null -ne $existingResource.DenyPasswordReplicationAccountName)
    {
        $testMembersParameters = @{
            ExistingMembers = $existingResource.DenyPasswordReplicationAccountName
            Members         = $DenyPasswordReplicationAccountName;
        }

        if (-not (Test-Members @testMembersParameters))
        {
            Write-Verbose -Message (
                $script:localizedData.DenySyncAccountsMismatch -f
                ($existingResource.DenyPasswordReplicationAccountName -join ';'),
                ($DenyPasswordReplicationAccountName -join ';')
            )

            $testTargetResourceReturnValue = $false
        }
    }

    <#
        Only evaluate Flexible Single Master Operation (FSMO) roles if the
        node is already a domain controller.
    #>
    if ($PSBoundParameters.ContainsKey('FlexibleSingleMasterOperationRole') -and $existingResource.Ensure -eq $true)
    {
        $FlexibleSingleMasterOperationRole | ForEach-Object -Process {
            if ($_ -notin $existingResource.FlexibleSingleMasterOperationRole)
            {
                Write-Verbose -Message ($script:localizedData.NotOwnerOfFlexibleSingleMasterOperationRole -f $_ )

                $testTargetResourceReturnValue = $false
            }
        }
    }

    <#
        If the node is not a domain controller and ensure is set to Absent we need to return
        True as it will fail if other options are set on the resource.
    #>
    if ($ensureValue -eq 'Absent' -and $Ensure -eq 'Absent')
    {
        $testTargetResourceReturnValue = $true
    }

    return $testTargetResourceReturnValue
}

<#
    .SYNOPSIS
        Return a hashtable with members that are not present in CurrentMembers,
        and members that are present add should not be present.

    .PARAMETER DesiredMembers
        Specifies the list of desired members in the hashtable.

    .PARAMETER CurrentMembers
        Specifies the list of current members in the hashtable.

    .OUTPUTS
        Returns a hashtable with two properties. The property MembersToAdd contains the
        members as ADPrincipal objects that are not members in the collection
        provided in $CurrentMembers. The property MembersToRemove contains the
        unwanted members as ADPrincipal objects in the collection provided
        in $CurrentMembers.
#>
function Get-MembersToAddAndRemove
{
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $DesiredMembers,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $CurrentMembers
    )

    $principalsToRemove = foreach ($memberName in $CurrentMembers)
    {
        if ($memberName -notin $DesiredMembers)
        {
            New-Object -TypeName Microsoft.ActiveDirectory.Management.ADPrincipal -ArgumentList $memberName
        }
    }

    $principalsToAdd = foreach ($memberName in $DesiredMembers)
    {
        if ($memberName -notin $CurrentMembers)
        {
            New-Object -TypeName Microsoft.ActiveDirectory.Management.ADPrincipal -ArgumentList $memberName
        }
    }

    return @{
        MembersToAdd    = [Microsoft.ActiveDirectory.Management.ADPrincipal[]] $principalsToAdd
        MembersToRemove = [Microsoft.ActiveDirectory.Management.ADPrincipal[]] $principalsToRemove
    }
}

Export-ModuleMember -Function *-TargetResource
