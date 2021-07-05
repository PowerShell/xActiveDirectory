<#PSScriptInfo
.VERSION 1.0.1
.GUID 50ee1ed8-2e39-4194-93f5-ceff18443e13
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
    This configuration will demote an exiting domain controller from the domain contoso.com.
#>


Configuration ADDomainController_DemoteDomainController_Config
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

    node localhost
    {
        WindowsFeature 'InstallADDomainServicesFeature'
        {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }

        WindowsFeature 'RSATADPowerShell'
        {
            Ensure    = 'Present'
            Name      = 'RSAT-AD-PowerShell'

            DependsOn = '[WindowsFeature]InstallADDomainServicesFeature'
        }

        WaitForADDomain 'WaitForestAvailability'
        {
            DomainName = 'contoso.com'
            Credential = $Credential

            DependsOn  = '[WindowsFeature]RSATADPowerShell'
        }

        ADDomainController 'DemoteDomainController'
        {
            Ensure                        = 'Absent'
            DomainName                    = 'contoso.com'
            Credential                    = $Credential
            SafeModeAdministratorPassword = $SafeModePassword

            DependsOn                     = '[WaitForADDomain]WaitForestAvailability'
        }
    }
}
