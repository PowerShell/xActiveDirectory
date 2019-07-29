<#PSScriptInfo
.VERSION 1.0
.GUID aad067ec-0e7a-4a41-874d-432a3ff73437
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
        This configuration will create a domain, and then create a child domain on
        another node.
#>
Configuration ADDomain_NewForestWithParentAndChildDomain_Config
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

    Node 'dsc-testParentNode1'
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
            RetryCount           = 50
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

    Node 'dsc-testChildNode2'
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
            RetryCount           = 50
            RetryIntervalSec     = 30

            DependsOn            = '[WindowsFeature]ADDSInstall'
        }

        ADDomain 'ChildDS'
        {
            DomainName                    = 'dsc-child'
            ParentDomainName              = 'dsc-test.contoso.com'
            Credential                    = $Credential
            SafeModeAdministratorPassword = $SafeModePassword

            DependsOn                     = '[WaitForADDomain]DscForestWait'
        }
    }
}
