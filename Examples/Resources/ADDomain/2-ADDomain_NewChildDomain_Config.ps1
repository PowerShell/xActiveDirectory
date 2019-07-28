<#PSScriptInfo
.VERSION 1.0
.GUID 40a01066-4c01-4115-b7a8-c21b51ac4ed3
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
        This configuration will create a new child domain in an existing forest with
        a Domain Functional Level of Windows Server 2012R2.
#>

Configuration ADDomain_NewChildDomain_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential
    )

    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName ActiveDirectoryDsc

    node $AllNodes.NodeName
    {
        WindowsFeature 'ADDS'
        {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature 'RSAT'
        {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }

        ADDomain $Node.DomainName
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $DomainAdministratorCredential
            SafemodeAdministratorPassword = $DomainAdministratorCredential
            DomainMode                    = $Node.DFL
            ParentDomainName              = $node.ParentDomain
        }
    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName     = 'localhost'
            DFL          = 'Win2012R2'
            DomainName   = 'child'
            ParentDomain = 'contoso.com'
        }
    )
}
