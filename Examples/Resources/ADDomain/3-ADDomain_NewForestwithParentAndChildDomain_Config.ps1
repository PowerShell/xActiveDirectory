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

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName         = 'dsc-testNode1'
            Role             = 'Parent DC'
            DomainName       = 'dsc-test.contoso.com'
            CertificateFile  = 'C:\publicKeys\targetNode.cer'
            Thumbprint       = 'AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8'
            RetryCount       = 50
            RetryIntervalSec = 30
        },

        @{
            NodeName         = 'dsc-testNode2'
            Role             = 'Child DC'
            DomainName       = 'dsc-child'
            ParentDomainName = 'dsc-test.contoso.com'
            CertificateFile  = 'C:\publicKeys\targetNode.cer'
            Thumbprint       = 'AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8'
            RetryCount       = 50
            RetryIntervalSec = 30
        }
    )
}

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

    Node $AllNodes.Where{ $_.Role -eq 'Parent DC' }.NodeName
    {
        WindowsFeature 'ADDSInstall'
        {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }

        ADDomain 'FirstDS'
        {
            DomainName                    = $Node.DomainName
            Credential                    = $Credential
            SafeModeAdministratorPassword = $SafeModePassword
            DnsDelegationCredential       = $DnsDelegationCredential

            DependsOn                     = '[WindowsFeature]ADDSInstall'
        }

        WaitForADDomain 'DscForestWait'
        {
            DomainName           = $Node.DomainName
            DomainUserCredential = $Credential
            RetryCount           = $Node.RetryCount
            RetryIntervalSec     = $Node.RetryIntervalSec

            DependsOn            = '[ADDomain]FirstDS'
        }

        ADUser 'FirstUser'
        {
            DomainName = $Node.DomainName
            Credential = $Credential
            UserName   = 'dummy'
            Password   = $NewADUserPassword
            Ensure     = 'Present'

            DependsOn  = '[WaitForADDomain]DscForestWait'
        }

    }

    Node $AllNodes.Where{ $_.Role -eq 'Child DC' }.NodeName
    {
        WindowsFeature 'ADDSInstall'
        {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }

        WaitForADDomain 'DscForestWait'
        {
            DomainName           = $Node.ParentDomainName
            DomainUserCredential = $Credential
            RetryCount           = $Node.RetryCount
            RetryIntervalSec     = $Node.RetryIntervalSec

            DependsOn            = '[WindowsFeature]ADDSInstall'
        }

        ADDomain 'ChildDS'
        {
            DomainName                    = $Node.DomainName
            ParentDomainName              = $Node.ParentDomainName
            Credential                    = $Credential
            SafeModeAdministratorPassword = $SafeModePassword

            DependsOn                     = '[WaitForADDomain]DscForestWait'
        }
    }
}
