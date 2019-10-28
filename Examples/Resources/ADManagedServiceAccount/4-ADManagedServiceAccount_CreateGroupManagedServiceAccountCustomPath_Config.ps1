<#PSScriptInfo
.VERSION 1.0
.GUID f758390b-0576-416a-9110-a0b26263415e
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT (c) Microsoft Corporation. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/PowerShell/ActiveDirectoryDsc/blob/master/LICENSE
.PROJECTURI https://github.com/PowerShell/ActiveDirectoryDsc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
.PRIVATEDATA
#>

#Requires -module ActiveDirectoryDsc

<#
    .DESCRIPTION
        This configuration will create a group managed service account in the specified path.
#>
Configuration ADManagedServiceAccount_CreateGroupManagedServiceAccountCustomPath_Config
{
    Import-DscResource -Module ActiveDirectoryDsc

    Node localhost
    {
        Node localhost
        {
            ADManagedServiceAccount 'ExampleGroupMSA'
            {
                Ensure             = 'Present'
                ServiceAccountName = 'Service01'
                AccountType        = 'Group'
                Path               = 'OU=ServiceAccounts,DC=contoso,DC=com'
            }
        }
    }
}
