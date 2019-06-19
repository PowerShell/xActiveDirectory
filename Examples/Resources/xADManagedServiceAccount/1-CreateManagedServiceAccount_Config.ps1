<#PSScriptInfo
.VERSION 1.0
.GUID 4ab7581b-8729-4262-ae01-b04d1af51ab2
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
        This configuration will create a managed service account.
#>

Configuration CreateManagedServiceAccount_Config
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADManagedServiceAccount 'ExampleSingleMSA'
        {
            Ensure             = 'Present'
            ServiceAccountName = 'Service01'
        }
    }
}
