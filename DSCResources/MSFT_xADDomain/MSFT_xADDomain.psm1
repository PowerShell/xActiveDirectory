$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'xActiveDirectory.Common'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'xActiveDirectory.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xADDomain'

<#
    .SYNOPSIS
        Retrieves the name of the file that tracks the status of the xADDomain resource with the
        specified domain name.

    .PARAMETER DomainName
        The domain name of the xADDomain resource to retrieve the tracking file name of.

    .NOTES
        The tracking file is currently output to the environment's temp directory.

        This file is NOT removed when a configuration completes, so if another call to a xADDomain
        resource with the same domain name occurs in the same environment, this file will already
        be present.

        This is so that when another call is made to the same resource, the resource will not
        attempt to promote the machine to a domain controller again (which would cause an error).

        If the resource should be promoted to a domain controller once again, you must first remove
        this file from the environment's temp directory (usually C:\Temp).

        If in the future this functionality needs to change so that future configurations are not
        affected, $env:temp should be changed to the resource's cache location which is removed
        after each configuration.
        ($env:systemRoot\system32\Configuration\BuiltinProvCache\MSFT_xADDomain)
#>
function Get-TrackingFilename
{
    [OutputType([System.String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName
    )

    return Join-Path -Path ($env:temp) -ChildPath ('{0}.xADDomain.completed' -f $DomainName)
}

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
        $DomainAdministratorCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorPassword,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ParentDomainName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainNetBIOSName,

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

    Assert-Module -ModuleName 'ADDSDeployment' -ImportModule
    $domainFQDN = Resolve-DomainFQDN -DomainName $DomainName -ParentDomainName $ParentDomainName
    $isDomainMember = Test-DomainMember

    $retries = 0
    $maxRetries = 5
    $retryIntervalInSeconds = 30
    $domainShouldExist = (Test-Path (Get-TrackingFilename -DomainName $DomainName))
    do
    {
        try
        {
            if ($isDomainMember)
            {
                # We're already a domain member, so take the credentials out of the equation
                Write-Verbose ($script:localizedData.QueryDomainWithLocalCredential -f $domainFQDN)
                $domain = Get-ADDomain -Identity $domainFQDN -ErrorAction Stop
                $forest = Get-ADForest -Identity $domain.Forest -ErrorAction Stop
            }
            else
            {
                Write-Verbose ($script:localizedData.QueryDomainWithCredential -f $domainFQDN)
                $domain = Get-ADDomain -Identity $domainFQDN -Credential $DomainAdministratorCredential -ErrorAction Stop
                $forest = Get-ADForest -Identity $domain.Forest -Credential $DomainAdministratorCredential -ErrorAction Stop
            }

            <#
                No need to check whether the node is actually a domain controller. If we don't throw an exception,
                the domain is already UP - and this resource shouldn't run. Domain controller functionality
                should be checked by the xADDomainController resource?
            #>
            Write-Verbose ($script:localizedData.DomainFound -f $domain.DnsRoot)

            $targetResource = @{
                DomainName = $domain.DnsRoot
                ParentDomainName = $domain.ParentDomain
                DomainNetBIOSName = $domain.NetBIOSName
                ForestMode = (ConvertTo-DeploymentForestMode -Mode $forest.ForestMode) -as [System.String]
                DomainMode = (ConvertTo-DeploymentDomainMode -Mode $domain.DomainMode) -as [System.String]
            }

            return $targetResource
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            $errorMessage = $script:localizedData.ExistingDomainMemberError -f $DomainName
            ThrowInvalidOperationError -ErrorId 'xADDomain_DomainMember' -ErrorMessage $errorMessage
        }
        catch [Microsoft.ActiveDirectory.Management.ADServerDownException]
        {
            Write-Verbose ($script:localizedData.DomainNotFound -f $domainFQDN)
            $domain = @{ }
            # will fall into retry mechanism
        }
        catch [System.Security.Authentication.AuthenticationException]
        {
            $errorMessage = $script:localizedData.InvalidCredentialError -f $DomainName
            ThrowInvalidOperationError -ErrorId 'xADDomain_InvalidCredential' -ErrorMessage $errorMessage
        }
        catch
        {
            $errorMessage = $script:localizedData.UnhandledError -f ($_.Exception | Format-List -Force | Out-String)
            Write-Verbose $errorMessage

            if ($domainShouldExist -and ($_.Exception.InnerException -is [System.ServiceModel.FaultException]))
            {
                Write-Verbose $script:localizedData.FaultExceptionAndDomainShouldExist
                # will fall into retry mechanism
            }
            else
            {
                # Not sure what's gone on here!
                throw $_
            }
        }

        if ($domainShouldExist)
        {
            $retries++

            Write-Verbose ($script:localizedData.RetryingGetADDomain -f $retries, $maxRetries, $retryIntervalInSeconds)

            Start-Sleep -Seconds ($retries * $retryIntervalInSeconds)
        }
    } while ($domainShouldExist -and ($retries -le $maxRetries))

} #end function Get-TargetResource

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
        $DomainAdministratorCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorPassword,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ParentDomainName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainNetBIOSName,

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

    $targetResource = Get-TargetResource @PSBoundParameters
    $isCompliant = $true

    <#
        The Get-Target resource returns .DomainName as the domain's FQDN. Therefore, we
        need to resolve this before comparison.
    #>
    $domainFQDN = Resolve-DomainFQDN -DomainName $DomainName -ParentDomainName $ParentDomainName
    if ($domainFQDN -ne $targetResource.DomainName)
    {
        $message = $script:localizedData.ResourcePropertyValueIncorrect -f 'DomainName', $domainFQDN, $targetResource.DomainName
        Write-Verbose -Message $message
        $isCompliant = $false
    }

    $propertyNames = @('ParentDomainName','DomainNetBIOSName')
    foreach ($propertyName in $propertyNames)
    {
        if ($PSBoundParameters.ContainsKey($propertyName))
        {
            $propertyValue = (Get-Variable -Name $propertyName).Value

            if ($targetResource.$propertyName -ne $propertyValue)
            {
                $message = $script:localizedData.ResourcePropertyValueIncorrect -f $propertyName, $propertyValue, $targetResource.$propertyName
                Write-Verbose -Message $message
                $isCompliant = $false
            }
        }
    }

    if ($isCompliant)
    {
        Write-Verbose -Message ($script:localizedData.ResourceInDesiredState -f $domainFQDN)
        return $true
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ResourceNotInDesiredState -f $domainFQDN)
        return $false
    }
} #end function Test-TargetResource

function Set-TargetResource
{
    <#
        Suppressing this rule because $global:DSCMachineStatus is used to
        trigger a reboot for the one that was suppressed when calling
        Install-ADDSForest or Install-ADDSDomains.
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
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ParentDomainName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainNetBIOSName,

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
    [ref] $null = $PSBoundParameters.Remove('Debug')

    # Not entirely necessary, but run Get-TargetResource to ensure we raise any pre-flight errors.
    $targetResource = Get-TargetResource @PSBoundParameters

    $installADDSParams = @{
        SafeModeAdministratorPassword = $SafemodeAdministratorPassword.Password
        NoRebootOnCompletion = $true
        Force = $true
    }

    if ($PSBoundParameters.ContainsKey('DnsDelegationCredential'))
    {
        $installADDSParams['DnsDelegationCredential'] = $DnsDelegationCredential
        $installADDSParams['CreateDnsDelegation'] = $true
    }

    if ($PSBoundParameters.ContainsKey('DatabasePath'))
    {
        $installADDSParams['DatabasePath'] = $DatabasePath
    }

    if ($PSBoundParameters.ContainsKey('LogPath'))
    {
        $installADDSParams['LogPath'] = $LogPath
    }

    if ($PSBoundParameters.ContainsKey('SysvolPath'))
    {
        $installADDSParams['SysvolPath'] = $SysvolPath
    }

    if ($PSBoundParameters.ContainsKey('DomainMode'))
    {
        $installADDSParams['DomainMode'] = $DomainMode
    }

    if ($PSBoundParameters.ContainsKey('ParentDomainName'))
    {
        Write-Verbose -Message ($script:localizedData.CreatingChildDomain -f $DomainName, $ParentDomainName)
        $installADDSParams['Credential'] = $DomainAdministratorCredential
        $installADDSParams['NewDomainName'] = $DomainName
        $installADDSParams['ParentDomainName'] = $ParentDomainName
        $installADDSParams['DomainType'] = 'ChildDomain'

        if ($PSBoundParameters.ContainsKey('DomainNetBIOSName'))
        {
            $installADDSParams['NewDomainNetbiosName'] = $DomainNetBIOSName
        }

        Install-ADDSDomain @installADDSParams

        Write-Verbose -Message ($script:localizedData.CreatedChildDomain)
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.CreatingForest -f $DomainName)
        $installADDSParams['DomainName'] = $DomainName

        if ($PSBoundParameters.ContainsKey('DomainNetbiosName'))
        {
            $installADDSParams['DomainNetbiosName'] = $DomainNetBIOSName
        }

        if ($PSBoundParameters.ContainsKey('ForestMode'))
        {
            $installADDSParams['ForestMode'] = $ForestMode
        }

        Install-ADDSForest @installADDSParams

        Write-Verbose -Message ($script:localizedData.CreatedForest -f $DomainName)
    }

    'Finished' | Out-File -FilePath (Get-TrackingFilename -DomainName $DomainName) -Force

    <#
        Signal to the LCM to reboot the node to compensate for the one we
        suppressed from Install-ADDSForest/Install-ADDSDomain.
    #>
    $global:DSCMachineStatus = 1
} #end function Set-TargetResource

Export-ModuleMember -Function *-TargetResource
