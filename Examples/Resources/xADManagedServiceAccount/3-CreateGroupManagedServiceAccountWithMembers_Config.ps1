<#PSScriptInfo
.VERSION 1.0
.GUID b743c31a-6db6-4aad-93fb-7f209042d8c1
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
        This configuration will create a group managed service account with members.
#>

Configuration CreateGroupManagedServiceAccountWithMembers_Config
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADManagedServiceAccount 'AddingMembersUsingSamAccountName'
        {
            Ensure             = 'Present'
            ServiceAccountName = 'Service01'
            AccountType        = 'Group'
            Path               = 'OU=ServiceAccounts,DC=contoso,DC=com'
            Members            = 'User01', 'Computer01$'
        }

        xADManagedServiceAccount 'AddingMembersUsingDN'
        {
            Ensure             = 'Present'
            ServiceAccountName = 'Service02'
            AccountType        = 'Group'
            Path               = 'OU=ServiceAccounts,DC=contoso,DC=com'
            Members            = 'CN=User01,OU=Users,DC=contoso,DC=com', 'CN=Computer01,OU=Computers,DC=contoso,DC=com'
        }
    }
}
