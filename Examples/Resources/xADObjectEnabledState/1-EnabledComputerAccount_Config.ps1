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

<#
    .DESCRIPTION
        This configuration will create a computer account disabled, and
        enforcing the account to be enabled.
#>
Configuration EnabledComputerAccount_Config
{
    Import-DscResource -ModuleName xActiveDirectory

    node localhost
    {
        xADComputer 'CreateDisabled'
        {
            ComputerName      = 'CLU_CNO01'
            EnabledOnCreation = $false
        }

        xADObjectEnabledState 'EnforceEnabledPropertyToEnabled'
        {
            Identity    = 'CLU_CNO01'
            ObjectClass = 'Computer'
            Enabled     = $true

            DependsOn   = '[xADComputer]CreateDisabled'
        }
    }
}
