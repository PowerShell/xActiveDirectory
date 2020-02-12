<#PSScriptInfo
.VERSION 1.0.1
.GUID 40a01066-4c01-4115-b7a8-c21b51ac4ed3
.AUTHOR DSC Community
.COMPANYNAME DSC Community
.COPYRIGHT DSC Community contributors. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/dsccommunity/ActiveDirectoryDsc/blob/master/LICENSE
.PROJECTURI https://github.com/dsccommunity/ActiveDirectoryDsc
.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png
.RELEASENOTES
Updated author, copyright notice, and URLs.

#>

#Requires -Module ActiveDirectoryDsc

<#
    .DESCRIPTION
        This configuration will create a new child domain in an existing forest with
        a Domain Functional Level of Windows Server 2016 (WinThreshold).
        The credential parameter must contain the domain qualified credentials of a
        user in the forest who has permissions to create a new child domain.
#>
Configuration ADDomain_NewChildDomain_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SafeModePassword
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc

    node 'localhost'
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

        ADDomain 'child'
        {
            DomainName                    = 'child'
            Credential                    = $Credential
            SafemodeAdministratorPassword = $SafeModePassword
            DomainMode                    = 'WinThreshold'
            ParentDomainName              = 'contoso.com'
        }
    }
}
