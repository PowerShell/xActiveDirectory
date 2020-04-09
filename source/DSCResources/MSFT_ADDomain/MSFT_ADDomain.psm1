$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'ActiveDirectoryDsc.Common'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'ActiveDirectoryDsc.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_ADDomain'

<#
    .SYNOPSIS
        Get the current state of the Domain.

    .PARAMETER DomainName
        The fully qualified domain name (FQDN) of a new domain. If setting up a
        child domain this must be set to a single-label DNS name.

    .PARAMETER Credential
        Specifies the user name and password that corresponds to the account used to install
        the domain controller. These are only used when adding a child domain and these credentials
        need the correct permission in the parent domain. This will not be created as a user in the
        new domain. The domain administrator password will be the same as the password of the local
        Administrator of this node.

    .PARAMETER SafeModeAdministratorPassword
        Password for the administrator account when the computer is started in Safe Mode.

    .PARAMETER ParentDomainName
        Fully qualified domain name (FQDN) of the parent domain.

    .NOTES
        Used Functions:
            Name                           | Module
            -------------------------------|--------------------------
            Get-ADDomain                   | ActiveDirectory
            Get-ADForest                   | ActiveDirectory
            Assert-Module                  | ActiveDirectoryDsc.Common
            Resolve-DomainFQDN             | ActiveDirectoryDsc.Common
            New-InvalidOperationException  | ActiveDirectoryDsc.Common
            ConvertTo-DeploymentForestMode | ActiveDirectoryDsc.Common
            ConvertTo-DeploymentDomainMode | ActiveDirectoryDsc.Common
#>
function Get-TargetResource
{
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
        $SafeModeAdministratorPassword,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ParentDomainName
    )

    Assert-Module -ModuleName 'ADDSDeployment' -ImportModule
    $domainFQDN = Resolve-DomainFQDN -DomainName $DomainName -ParentDomainName $ParentDomainName

    # If the domain has been installed then the Netlogon SysVol registry item will exist.
    $domainShouldBePresent = $true
    try
    {
        $sysvolPath = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name 'SysVol'
    }
    catch
    {
        $domainShouldBePresent = $false
    }

    if ($domainShouldBePresent)
    {
        # Test that the correct domain SysVol path exists
        $domainSysVolPath = Join-Path -Path $sysvolPath -ChildPath $domainFQDN

        if (-not (Test-Path -Path $domainSysVolPath))
        {
            $errorMessage = $script:localizedData.SysVolPathDoesNotExistError -f $domainSysVolPath
            New-InvalidOperationException -Message $errorMessage
        }

        Write-Verbose ($script:localizedData.QueryDomain -f $domainFQDN)

        $retries = 0
        $maxRetries = 15
        $retryIntervalInSeconds = 30

        do
        {
            $domainFound = $true
            try
            {
                $domain = Get-ADDomain -Identity $domainFQDN -Server localhost -ErrorAction Stop
            }
            catch [Microsoft.ActiveDirectory.Management.ADServerDownException], `
                [System.Security.Authentication.AuthenticationException], `
                [System.InvalidOperationException], `
                [System.ArgumentException]
            {
                Write-Verbose ($script:localizedData.ADServerNotReady -f $domainFQDN)
                $domainFound = $false
                # will fall into the retry mechanism.
            }
            catch
            {
                $errorMessage = $script:localizedData.GetAdDomainUnexpectedError -f $domainFQDN
                New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
            }

            if (-not $domainFound)
            {
                $retries++

                Write-Verbose ($script:localizedData.RetryingGetADDomain -f
                    $retries, $maxRetries, $retryIntervalInSeconds)

                Start-Sleep -Seconds $retryIntervalInSeconds
            }
        } while ((-not $domainFound) -and $retries -lt $maxRetries)

        if ($retries -eq $maxRetries)
        {
            $errorMessage = $script:localizedData.MaxDomainRetriesReachedError -f $domainFQDN
            New-InvalidOperationException -Message $errorMessage
        }
    }
    else
    {
        $domain = $null
    }

    if ($domain)
    {
        Write-Verbose ($script:localizedData.DomainFound -f $domain.DnsRoot)

        try
        {
            $forest = Get-ADForest -Identity $domain.Forest -Server localhost -ErrorAction Stop
        }
        catch
        {
            $errorMessage = $script:localizedData.GetAdForestUnexpectedError -f $domain.Forest
            New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
        }

        $deploymentForestMode = (ConvertTo-DeploymentForestMode -Mode $forest.ForestMode) -as [System.String]
        $deploymentDomainMode = (ConvertTo-DeploymentDomainMode -Mode $domain.DomainMode) -as [System.String]
        $serviceNTDS = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters'
        $serviceNETLOGON = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'

        $returnValue = @{
            DomainName                    = $DomainName
            Credential                    = $Credential
            SafeModeAdministratorPassword = $SafeModeAdministratorPassword
            ParentDomainName              = $domain.ParentDomain
            DomainNetBiosName             = $domain.NetBIOSName
            DnsDelegationCredential       = $null
            DatabasePath                  = $serviceNTDS.'DSA Working Directory'
            LogPath                       = $serviceNTDS.'Database log files path'
            SysvolPath                    = $serviceNETLOGON.SysVol -replace '\\sysvol$', ''
            ForestMode                    = $deploymentForestMode
            DomainMode                    = $deploymentDomainMode
            DomainExist                   = $true
            Forest                        = $forest.Name
            DnsRoot                       = $domain.DnsRoot
        }
    }
    else
    {
        $returnValue = @{
            DomainName                    = $DomainName
            Credential                    = $Credential
            SafeModeAdministratorPassword = $SafeModeAdministratorPassword
            ParentDomainName              = $ParentDomainName
            DomainNetBiosName             = $null
            DnsDelegationCredential       = $null
            DatabasePath                  = $null
            LogPath                       = $null
            SysvolPath                    = $null
            ForestMode                    = $null
            DomainMode                    = $null
            DomainExist                   = $false
            Forest                        = $null
            DnsRoot                       = $null
        }
    }

    return $returnValue
} #end function Get-TargetResource

<#
    .SYNOPSIS
        Tests the current state of the Domain.

    .PARAMETER DomainName
        The fully qualified domain name (FQDN) of a new domain. If setting up a
        child domain this must be set to a single-label DNS name.

    .PARAMETER Credential
        Specifies the user name and password that corresponds to the account used to install
        the domain controller. These are only used when adding a child domain and these credentials
        need the correct permission in the parent domain. This will not be created as a user in the
        new domain. The domain administrator password will be the same as the password of the local
        Administrator of this node.

    .PARAMETER SafeModeAdministratorPassword
        Password for the administrator account when the computer is started in Safe Mode.

    .PARAMETER ParentDomainName
        Fully qualified domain name (FQDN) of the parent domain.

    .PARAMETER DomainNetBiosName
        NetBIOS name for the new domain.

    .PARAMETER DnsDelegationCredential
        Credential used for creating DNS delegation.

    .PARAMETER DatabasePath
        Path to a directory that contains the domain database.

    .PARAMETER LogPath
        Path to a directory for the log file that will be written.

    .PARAMETER SysvolPath
        Path to a directory where the Sysvol file will be written.

    .PARAMETER ForestMode
        The Forest Functional Level for the entire forest.

    .PARAMETER DomainMode
        The Domain Functional Level for the entire domain.

    .NOTES
        Used Functions:
            Name               | Module
            -------------------|--------------------------
            Resolve-DomainFQDN | ActiveDirectoryDsc.Common
#>
function Test-TargetResource
{
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
        $SafeModeAdministratorPassword,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ParentDomainName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainNetBiosName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $DnsDelegationCredential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DatabasePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $LogPath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $SysvolPath,

        [Parameter()]
        [ValidateSet('Win2008', 'Win2008R2', 'Win2012', 'Win2012R2', 'WinThreshold')]
        [System.String]
        $ForestMode,

        [Parameter()]
        [ValidateSet('Win2008', 'Win2008R2', 'Win2012', 'Win2012R2', 'WinThreshold')]
        [System.String]
        $DomainMode
    )

    $getTargetResourceParameters = @{
        DomainName                    = $DomainName
        Credential                    = $Credential
        SafeModeAdministratorPassword = $SafeModeAdministratorPassword
        ParentDomainName              = $ParentDomainName
    }

    @($getTargetResourceParameters.Keys) |
        ForEach-Object {
            if (-not $PSBoundParameters.ContainsKey($_))
            {
                $getTargetResourceParameters.Remove($_)
            }
        }

    $targetResource = Get-TargetResource @getTargetResourceParameters

    $domainFQDN = Resolve-DomainFQDN -DomainName $DomainName -ParentDomainName $ParentDomainName

    if ($targetResource.DomainExist)
    {
        Write-Verbose -Message ($script:localizedData.DomainInDesiredState -f
            $domainFQDN)
        $inDesiredState = $true
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.DomainNotInDesiredState -f
            $domainFQDN)
        $inDesiredState = $false
    }

    return $inDesiredState
} #end function Test-TargetResource

<#
    .SYNOPSIS
        Sets the state of the Domain.

    .PARAMETER DomainName
        The fully qualified domain name (FQDN) of a new domain. If setting up a
        child domain this must be set to a single-label DNS name.

    .PARAMETER Credential
        Specifies the user name and password that corresponds to the account used to install
        the domain controller. These are only used when adding a child domain and these credentials
        need the correct permission in the parent domain. This will not be created as a user in the
        new domain. The domain administrator password will be the same as the password of the local
        Administrator of this node.

    .PARAMETER SafeModeAdministratorPassword
        Password for the administrator account when the computer is started in Safe Mode.

    .PARAMETER ParentDomainName
        Fully qualified domain name (FQDN) of the parent domain.

    .PARAMETER DomainNetBiosName
        NetBIOS name for the new domain.

    .PARAMETER DnsDelegationCredential
        Credential used for creating DNS delegation.

    .PARAMETER DatabasePath
        Path to a directory that contains the domain database.

    .PARAMETER LogPath
        Path to a directory for the log file that will be written.

    .PARAMETER SysvolPath
        Path to a directory where the Sysvol file will be written.

    .PARAMETER ForestMode
        The Forest Functional Level for the entire forest.

    .PARAMETER DomainMode
        The Domain Functional Level for the entire domain.

    .NOTES
        Used Functions:
            Name                           | Module
            -------------------------------|--------------------------
            Install-ADDSDomain             | ActiveDirectory
            Install-ADDSForest             | ActiveDirectory
#>
function Set-TargetResource
{
    <#
        Suppressing this rule because $global:DSCMachineStatus is used to
        trigger a reboot for the one that was suppressed when calling
        Install-ADDSForest or Install-ADDSDomain.
    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
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
        $SafeModeAdministratorPassword,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ParentDomainName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainNetBiosName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $DnsDelegationCredential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DatabasePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $LogPath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $SysvolPath,

        [Parameter()]
        [ValidateSet('Win2008', 'Win2008R2', 'Win2012', 'Win2012R2', 'WinThreshold')]
        [System.String]
        $ForestMode,

        [Parameter()]
        [ValidateSet('Win2008', 'Win2008R2', 'Win2012', 'Win2012R2', 'WinThreshold')]
        [System.String]
        $DomainMode
    )

    # Debug can pause Install-ADDSForest/Install-ADDSDomain, so we remove it.
    $null = $PSBoundParameters.Remove('Debug')

    $getTargetResourceParameters = @{
        DomainName                    = $DomainName
        Credential                    = $Credential
        SafeModeAdministratorPassword = $SafeModeAdministratorPassword
        ParentDomainName              = $ParentDomainName
    }

    @($getTargetResourceParameters.Keys) |
        ForEach-Object {
            if (-not $PSBoundParameters.ContainsKey($_))
            {
                $getTargetResourceParameters.Remove($_)
            }
        }

    $targetResource = Get-TargetResource @getTargetResourceParameters

    if (-not $targetResource.DomainExist)
    {
        $installADDSParameters = @{
            SafeModeAdministratorPassword = $SafeModeAdministratorPassword.Password
            NoRebootOnCompletion          = $true
            Force                         = $true
            ErrorAction                   = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('DnsDelegationCredential'))
        {
            $installADDSParameters['DnsDelegationCredential'] = $DnsDelegationCredential
            $installADDSParameters['CreateDnsDelegation'] = $true
        }

        if ($PSBoundParameters.ContainsKey('DatabasePath'))
        {
            $installADDSParameters['DatabasePath'] = $DatabasePath
        }

        if ($PSBoundParameters.ContainsKey('LogPath'))
        {
            $installADDSParameters['LogPath'] = $LogPath
        }

        if ($PSBoundParameters.ContainsKey('SysvolPath'))
        {
            $installADDSParameters['SysvolPath'] = $SysvolPath
        }

        if ($PSBoundParameters.ContainsKey('DomainMode'))
        {
            $installADDSParameters['DomainMode'] = $DomainMode
        }

        if ($PSBoundParameters.ContainsKey('ParentDomainName'))
        {
            Write-Verbose -Message ($script:localizedData.CreatingChildDomain -f $DomainName, $ParentDomainName)
            $installADDSParameters['Credential'] = $Credential
            $installADDSParameters['NewDomainName'] = $DomainName
            $installADDSParameters['ParentDomainName'] = $ParentDomainName
            $installADDSParameters['DomainType'] = 'ChildDomain'

            if ($PSBoundParameters.ContainsKey('DomainNetBiosName'))
            {
                $installADDSParameters['NewDomainNetBiosName'] = $DomainNetBiosName
            }

            Install-ADDSDomain @installADDSParameters

            Write-Verbose -Message ($script:localizedData.CreatedChildDomain)
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.CreatingForest -f $DomainName)
            $installADDSParameters['DomainName'] = $DomainName

            if ($PSBoundParameters.ContainsKey('DomainNetBiosName'))
            {
                $installADDSParameters['DomainNetBiosName'] = $DomainNetBiosName
            }

            if ($PSBoundParameters.ContainsKey('ForestMode'))
            {
                $installADDSParameters['ForestMode'] = $ForestMode
            }

            Install-ADDSForest @installADDSParameters

            Write-Verbose -Message ($script:localizedData.CreatedForest -f $DomainName)
        }

        <#
            Signal to the LCM to reboot the node to compensate for the one we
            suppressed from Install-ADDSForest/Install-ADDSDomain.
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
            Justification = 'Set LCM DSCMachineStatus to indicate reboot required')]
        $global:DSCMachineStatus = 1
    }
} #end function Set-TargetResource

Export-ModuleMember -Function *-TargetResource
