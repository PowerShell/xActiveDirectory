<#PSScriptInfo
.VERSION 1.0
.GUID 8fced2a6-bb34-400c-a44e-2c484e3bc9e3
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
        This configuration will remove the Active Directory replication site
        called 'Cupertino'.
#>

Configuration RemoveADReplicationSite_Config
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADReplicationSite 'CupertinoSite'
        {
            Ensure = 'Absent'
            Name   = 'Cupertino'
        }
    }
}
