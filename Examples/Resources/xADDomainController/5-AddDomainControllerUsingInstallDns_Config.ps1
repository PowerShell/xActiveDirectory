<#PSScriptInfo
.VERSION 1.0.0
.GUID ba30df50-0873-4c2c-872b-96f5c825910d
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT (c) Microsoft Corporation. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/PowerShell/xActiveDirectory/blob/master/LICENSE
.PROJECTURI https://github.com/PowerShell/xActiveDirectory
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>

#Requires -module xActiveDirectory

<#
    .DESCRIPTION
    This configuration will add a domain controller to the domain contoso.com
    without installing the local DNS server service and using the one in the existing domain.
#>
Configuration AddDomainControllerUsingInstallDns_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential
    )

    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName xActiveDirectory

    node localhost
    {
        WindowsFeature 'InstallADDomainServicesFeature'
        {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }

        WindowsFeature 'RSATADPowerShell'
        {
            Ensure    = 'Present'
            Name      = 'RSAT-AD-PowerShell'

            DependsOn = '[WindowsFeature]InstallADDomainServicesFeature'
        }

        xWaitForADDomain 'WaitForestAvailability'
        {
            DomainName           = 'contoso.com'
            DomainUserCredential = $DomainAdministratorCredential
            RetryCount           = 10
            RetryIntervalSec     = 120

            DependsOn            = '[WindowsFeature]RSATADPowerShell'
        }

        xADDomainController 'DomainControllerUsingExistingDNSServer'
        {
            DomainName                    = 'contoso.com'
            DomainAdministratorCredential = $DomainAdministratorCredential
            SafemodeAdministratorPassword = $DomainAdministratorCredential
            InstallDns                    = $false
            DependsOn                     = '[xWaitForADDomain]WaitForestAvailability'
        }
    }
}
