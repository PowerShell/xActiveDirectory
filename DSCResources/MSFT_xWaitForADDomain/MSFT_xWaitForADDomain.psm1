$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'xActiveDirectory.Common'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'xActiveDirectory.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xWaitForADDomain'

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DomainUserCredential,

        [Parameter()]
        [System.UInt64]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 10,

        [Parameter()]
        [System.UInt32]
        $RebootRetryCount = 0
    )

    if ($DomainUserCredential)
    {
        $convertToCimCredential = New-CimInstance -ClassName MSFT_Credential -Namespace 'root/microsoft/windows/desiredstateconfiguration' -ClientOnly -Property @{
            Username = [System.String] $DomainUserCredential.UserName
            Password = [System.String] $null
        }
    }
    else
    {
        $convertToCimCredential = $null
    }

    Write-Verbose -Message ($script:localizedData.GetDomain -f $DomainName)

    $domain = Get-Domain -DomainName $DomainName -DomainUserCredential $DomainUserCredential

    return @{
        DomainName = $domain.Name
        DomainUserCredential = $convertToCimCredential
        RetryIntervalSec = $RetryIntervalSec
        RetryCount = $RetryCount
        RebootRetryCount = $RebootRetryCount
    }
}

function Set-TargetResource
{
    <#
        Suppressing this rule because $global:DSCMachineStatus is used to trigger
        a reboot if the domain name cannot be found withing the timeout period.
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

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DomainUserCredential,

        [Parameter()]
        [System.UInt64]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 10,

        [Parameter()]
        [System.UInt32]
        $RebootRetryCount = 0

    )

    $rebootLogFile = "$env:temp\xWaitForADDomain_Reboot.tmp"

    for ($count = 0; $count -lt $RetryCount; $count++)
    {
        $domain = Get-Domain -DomainName $DomainName -DomainUserCredential $DomainUserCredential

        if ($domain)
        {
            if ($RebootRetryCount -gt 0)
            {
                Remove-Item $rebootLogFile -ErrorAction SilentlyContinue
            }

            break
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.DomainNotFoundRetrying -f $DomainName, $RetryIntervalSec)

            Start-Sleep -Seconds $RetryIntervalSec

            Clear-DnsClientCache
        }
    }

    if (-not $domain)
    {
        if ($RebootRetryCount -gt 0)
        {
            [System.UInt32] $rebootCount = Get-Content $RebootLogFile -ErrorAction SilentlyContinue

            if ($rebootCount -lt $RebootRetryCount)
            {
                $rebootCount = $rebootCount + 1

                Write-Verbose -Message  ($script:localizedData.DomainNotFoundRebooting -f $DomainName, $count, $RetryIntervalSec, $rebootCount, $RebootRetryCount)

                Set-Content -Path $RebootLogFile -Value $rebootCount

                $global:DSCMachineStatus = 1
            }
            else
            {
                throw ($script:localizedData.DomainNotFoundAfterReboot -f $DomainName, $RebootRetryCount)
            }
        }
        else
        {
            throw ($script:localizedData.DomainNotFoundAfterRetry -f $DomainName, $RetryCount)
        }
    }
}

function Test-TargetResource
{
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DomainUserCredential,

        [Parameter()]
        [System.UInt64]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 10,

        [Parameter()]
        [System.UInt32]
        $RebootRetryCount = 0

    )

    $rebootLogFile = "$env:temp\xWaitForADDomain_Reboot.tmp"

    $domain = Get-Domain -DomainName $DomainName -DomainUserCredential $DomainUserCredential

    if ($domain)
    {
        if ($RebootRetryCount -gt 0)
        {
            Remove-Item $rebootLogFile -ErrorAction SilentlyContinue
        }

        Write-Verbose -Message ($script:localizedData.DomainInDesiredState -f $DomainName)

        return $true
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.DomainNotInDesiredState -f $DomainName)
        return $false
    }
}

function Get-Domain
{
    [OutputType([PSObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DomainUserCredential
    )

    Write-Verbose -Message ($script:localizedData.CheckDomain -f $DomainName)

    if ($DomainUserCredential)
    {
        $context = New-Object -TypeName 'System.DirectoryServices.ActiveDirectory.DirectoryContext' -ArgumentList @('Domain', $DomainName, $DomainUserCredential.UserName, $DomainUserCredential.GetNetworkCredential().Password)
    }
    else
    {
        $context = New-Object -TypeName 'System.DirectoryServices.ActiveDirectory.DirectoryContext' -ArgumentList @('Domain', $DomainName)
    }

    try
    {
        $domain = ([System.DirectoryServices.ActiveDirectory.DomainController]::FindOne($context)).domain.ToString()

        Write-Verbose -Message ($script:localizedData.FoundDomain -f $DomainName)

        return @{
            Name = $domain
        }
    }
    catch
    {
        Write-Verbose -Message ($script:localizedData.DomainNotFound -f $DomainName)
    }
}
