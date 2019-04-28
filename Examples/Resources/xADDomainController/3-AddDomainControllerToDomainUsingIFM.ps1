<#PSScriptInfo
.VERSION 1.0.0
.GUID b4beb2be-8852-4591-ac46-bc8005528183
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
        contoso.com using the information from media.
#>
Configuration xADDomainController_AddDomainControllerToDomainUsingIFM_Config
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

        xADDomainController 'DomainControllerWithIFM'
        {
            DomainName                    = 'contoso.com'
            DomainAdministratorCredential = $DomainAdministratorCredential
            SafemodeAdministratorPassword = $DomainAdministratorCredential
            InstallationMediaPath         = 'F:\IFM'
        }
    }
}
