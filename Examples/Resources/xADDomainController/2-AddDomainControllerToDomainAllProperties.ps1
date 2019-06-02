<#PSScriptInfo
.VERSION 1.0.0
.GUID 4e7c335f-1816-48df-8f9c-f87fe4720ced
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
        This configuration will add a domain controller to the domain
        contoso.com, specifying all properties of the resource.
#>
Configuration AddDomainControllerToDomainAllProperties
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
            Name = 'AD-Domain-Services'
        }

        WindowsFeature 'RSATADPowerShell'
        {
            Ensure = 'Present'
            Name   = 'RSAT-AD-PowerShell'

            DependsOn = '[WindowsFeature]InstallADDomainServicesFeature'
        }

        xWaitForADDomain 'WaitForestAvailability'
        {
            DomainName = 'contoso.com'
            DomainUserCredential = $DomainAdministratorCredential
            RetryCount = 10
            RetryIntervalSec = 120

            DependsOn = '[WindowsFeature]RSATADPowerShell'
        }

        xADDomainController 'DomainControllerAllProperties'
        {
            DomainName                    = 'contoso.com'
            DomainAdministratorCredential = $DomainAdministratorCredential
            SafemodeAdministratorPassword = $DomainAdministratorCredential
            DatabasePath                  = 'C:\Windows\NTDS'
            LogPath                       = 'C:\Windows\Logs'
            SysvolPath                    = 'C:\Windows\SYSVOL'
            SiteName                      = 'Europe'
            IsGlobalCatalog               = $true

            DependsOn = '[xWaitForADDomain]WaitForestAvailability'
        }
    }
}
