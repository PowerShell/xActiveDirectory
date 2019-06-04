<#PSScriptInfo
.VERSION 1.0.0
.GUID b4d414dc-e230-4055-bdc3-fae268493881
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
#Requires -module xFailoverCluster

<#
    .DESCRIPTION
        This configuration will configure a cluster using a pre-staged computer
        account, and enforcing the pre-staged computer account to be enabled.
#>
Configuration EnabledPrestagedClusterComputerAccount_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential
    )

    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xFailoverCluster

    node localhost
    {
        xCluster 'CreateCluster'
        {
            Name                          = 'CLU_CNO01'
            StaticIPAddress               = '192.168.100.20/24'
            DomainAdministratorCredential = $DomainAdministratorCredential
        }

        xADObjectEnabledState 'EnforceEnabledPropertyToEnabled'
        {
            Identity    = 'CLU_CNO01'
            ObjectClass = 'Computer'
            Enabled     = $true

            DependsOn   = @(
                '[xCluster]CreateCluster'
            )
        }
    }
}
