<#PSScriptInfo
.VERSION 1.0
.GUID f486afc3-63c8-4809-a84a-34bd227023a3
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
        This configuration will create an Active Directory replication site called
        'Seattle'. If the 'Default-First-Site-Name' site exists, it will rename
        this site instead of create a new one.
#>

Configuration CreateADReplicationSiteRenameDefault_Config
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADReplicationSite 'SeattleSite'
        {
            Ensure                     = 'Present'
            Name                       = 'Seattle'
            RenameDefaultFirstSiteName = $true
        }
    }
}
