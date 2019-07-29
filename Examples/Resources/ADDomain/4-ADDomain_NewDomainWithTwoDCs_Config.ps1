<#PSScriptInfo
.VERSION 1.0
.GUID 400370df-41bc-44d4-8730-0aa9a135383f
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
        This configuration will create a highly available domain by adding
        a second domain controller to the newly created domain.
        The WaitForDomain resource is used to ensure that the domain is
        present before the second domain controller is added.
#>
Configuration ADDomain_NewDomainWithTwoDCs_Config
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
        $SafeModePassword,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DnsDelegationCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $NewADUserPassword
    )

    Import-DscResource -ModuleName ActiveDirectoryDsc

    Node 'dsc-testDomainNode1'
    {
        WindowsFeature 'ADDSInstall'
        {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }

        ADDomain 'FirstDS'
        {
            DomainName                    = 'dsc-test.contoso.com'
            Credential                    = $Credential
            SafeModeAdministratorPassword = $SafeModePassword
            DnsDelegationCredential       = $DnsDelegationCredential

            DependsOn                     = '[WindowsFeature]ADDSInstall'
        }

        WaitForADDomain 'DscForestWait'
        {
            DomainName           = 'dsc-test.contoso.com'
            DomainUserCredential = $Credential
            RetryCount           = 20
            RetryIntervalSec     = 30

            DependsOn            = '[ADDomain]FirstDS'
        }

        ADUser 'FirstUser'
        {
            DomainName = 'dsc-test.contoso.com'
            Credential = $Credential
            UserName   = 'dummy'
            Password   = $NewADUserPassword
            Ensure     = 'Present'

            DependsOn  = '[WaitForADDomain]DscForestWait'
        }
    }

    Node 'dsc-testDomainNode2'
    {
        WindowsFeature 'ADDSInstall'
        {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }

        WaitForADDomain 'DscForestWait'
        {
            DomainName           = 'dsc-test.contoso.com'
            DomainUserCredential = $Credential
            RetryCount           = 20
            RetryIntervalSec     = 30

            DependsOn            = '[WindowsFeature]ADDSInstall'
        }

        ADDomainController 'SecondDC'
        {
            DomainName                    = 'dsc-test.contoso.com'
            Credential                    = $Credential
            SafeModeAdministratorPassword = $SafeModePassword

            DependsOn                     = '[WaitForADDomain]DscForestWait'
        }
    }
}
