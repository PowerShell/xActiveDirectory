<#PSScriptInfo
.VERSION 1.0
.GUID bd5991db-7382-41cf-aefa-ba2b57af227a
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
    This configuration will manage the Service and User Principal name suffixes in
    the forest by adding and removing the desired suffixes. This will not overwrite
    existing suffixes in the forest.
#>

Configuration AddRemoveForestProperties_Config
{
    Import-DscResource -ModuleName xActiveDirectory

    node localhost
    {
        xADForestProperties 'ContosoProperties'
        {
            ForestName                         = 'contoso.com'
            ServicePrincipalNameSuffixToAdd    = 'test.net'
            ServicePrincipalNameSuffixToRemove = 'test.com'
            UserPrincipalNameSuffixToAdd       = 'cloudapp.net', 'fabrikam.com'
            UserPrincipalNameSuffixToRemove    = 'pester.net'
        }
    }
}
