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
        [String]$DomainName,

        [Parameter()]
        [PSCredential]$DomainUserCredential,

        [Parameter()]
        [UInt64]$RetryIntervalSec = 60,

        [Parameter()]
        [UInt32]$RetryCount = 10,

        [Parameter()]
        [UInt32]$RebootRetryCount = 0

    )

    if($DomainUserCredential)
    {
        $convertToCimCredential = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$DomainUserCredential.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly
    }
    else
    {
        $convertToCimCredential = $null
    }

    Write-Verbose -Message ($script:localizedData.GetDomain -f $DomainName)
    $domain = Get-Domain -DomainName $DomainName -DomainUserCredential $DomainUserCredential


    $returnValue = @{
        DomainName = $domain.Name
        DomainUserCredential = $convertToCimCredential
        RetryIntervalSec = $RetryIntervalSec
        RetryCount = $RetryCount
        RebootRetryCount = $RebootRetryCount
    }

    $returnValue
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
        [String]$DomainName,

        [Parameter()]
        [PSCredential]$DomainUserCredential,

        [Parameter()]
        [UInt64]$RetryIntervalSec = 60,

        [Parameter()]
        [UInt32]$RetryCount = 10,

        [Parameter()]
        [UInt32]$RebootRetryCount = 0

    )

    $rebootLogFile = "$env:temp\xWaitForADDomain_Reboot.tmp"

    for($count = 0; $count -lt $RetryCount; $count++)
    {
        $domain = Get-Domain -DomainName $DomainName -DomainUserCredential $DomainUserCredential

        if($domain)
        {
            if($RebootRetryCount -gt 0)
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

    if(-not $domain)
    {
        if($RebootRetryCount -gt 0)
        {
            [UInt32]$rebootCount = Get-Content $RebootLogFile -ErrorAction SilentlyContinue

            if($rebootCount -lt $RebootRetryCount)
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
        [String]$DomainName,

        [Parameter()]
        [PSCredential]$DomainUserCredential,

        [Parameter()]
        [UInt64]$RetryIntervalSec = 60,

        [Parameter()]
        [UInt32]$RetryCount = 10,

        [Parameter()]
        [UInt32]$RebootRetryCount = 0

    )

    $rebootLogFile = "$env:temp\xWaitForADDomain_Reboot.tmp"

    $domain = Get-Domain -DomainName $DomainName -DomainUserCredential $DomainUserCredential

    if($domain)
    {
        if($RebootRetryCount -gt 0)
        {
            Remove-Item $rebootLogFile -ErrorAction SilentlyContinue
        }

        Write-Verbose -Message ($script:localizedData.DomainInDesiredState -f $DomainName)
        $true
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.DomainNotInDesiredState -f $DomainName)
        $false
    }
}



function Get-Domain
{
    [OutputType([PSObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]$DomainName,

        [Parameter()]
        [PSCredential]$DomainUserCredential

    )
    Write-Verbose -Message ($script:localizedData.CheckDomain -f $DomainName)

    if($DomainUserCredential)
    {
        $context = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain', $DomainName, $DomainUserCredential.UserName, $DomainUserCredential.GetNetworkCredential().Password)
    }
    else
    {
        $context = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain',$DomainName)
    }

    try
    {
        $domain = ([System.DirectoryServices.ActiveDirectory.DomainController]::FindOne($context)).domain.ToString()
        Write-Verbose -Message ($script:localizedData.FoundDomain -f $DomainName)
        $returnValue = @{
            Name = $domain
        }

       $returnValue
    }
    catch
    {
        Write-Verbose -Message ($script:localizedData.DomainNotFound -f $DomainName)
    }
}
