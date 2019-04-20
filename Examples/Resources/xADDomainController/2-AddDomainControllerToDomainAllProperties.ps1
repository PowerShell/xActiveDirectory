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

#Requires -module ComputerManagementDsc

<#
    .DESCRIPTION
        This configuration will add a domain controller to the domain
        contoso.com, specifying all properties of the resource.
#>
Configuration xADDomainController_AddDomainControllerToDomainAllProperties_Config
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
        WindowsFeature RSAT
        {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }

        xADDomainController 'DomainController1'
        {
            DomainName                    = 'contoso.com'
            DomainAdministratorCredential = $DomainAdministratorCredential
            SafemodeAdministratorPassword = $DomainAdministratorCredential
            DatabasePath                  = 'C:\Windows\NTDS'
            LogPath                       = 'C:\Windows\Logs'
            SysvolPath                    = 'C:\Windows\SYSVOL'
            SiteName                      = 'Europe'
            IsGlobalCatalog               = $true
        }
    }
}
