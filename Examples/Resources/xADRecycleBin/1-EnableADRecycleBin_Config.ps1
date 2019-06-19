<#PSScriptInfo
.VERSION 1.0
.GUID 63447da7-3fe9-4d03-b680-2129a2d0318f
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
.RELEASENOTES
.PRIVATEDATA
#>

#Requires -module xActiveDirectory

<#
    .DESCRIPTION
        This configuration will enable the Active Directory Recycle Bin for a
        specified Domain
#>

Configuration EnableADRecycleBin_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ForestFQDN,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EACredential
    )

    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADRecycleBin 'RecycleBin'
        {
            EnterpriseAdministratorCredential = $EACredential
            ForestFQDN                        = $ForestFQDN
        }
    }
}
