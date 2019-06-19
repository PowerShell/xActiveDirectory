<#PSScriptInfo
.VERSION 1.0
.GUID 0d6564cf-5492-4922-b4ef-4c20da0b7b3f
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
        This configuration will create a new domain-local group with three members.
#>

Configuration NewGroupWithMembers_Config
{
    Import-DscResource -ModuleName xActiveDirectory

    node localhost
    {
        xADGroup 'dl1'
        {
            GroupName  = 'DL_APP_1'
            GroupScope = 'DomainLocal'
            Members    = 'john', 'jim', 'sally'
        }
    }
}
