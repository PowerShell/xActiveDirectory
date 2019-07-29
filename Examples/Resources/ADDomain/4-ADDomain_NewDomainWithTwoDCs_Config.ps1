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

# Configuration Data for AD
$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName         = 'dsc-testNode1'
            Role             = 'Primary DC'
            DomainName       = 'dsc-test.contoso.com'
            CertificateFile  = 'C:\publicKeys\targetNode.cer'
            Thumbprint       = 'AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8'
            RetryCount       = 20
            RetryIntervalSec = 30
        },
        @{
            NodeName         = 'dsc-testNode2'
            Role             = 'Replica DC'
            DomainName       = 'dsc-test.contoso.com'
            CertificateFile  = 'C:\publicKeys\targetNode.cer'
            Thumbprint       = 'AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8'
            RetryCount       = 20
            RetryIntervalSec = 30
        }
    )
}

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

    Node $AllNodes.Where{ $_.Role -eq 'Primary DC' }.NodeName
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

    Node $AllNodes.Where{ $_.Role -eq 'Replica DC' }.NodeName
    {
        WindowsFeature 'ADDSInstall'
        {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }

        WaitForADDomain 'DscForestWait'
        {
            DomainName           = $Node.DomainName
            DomainUserCredential = $Credential
            RetryCount           = $Node.RetryCount
            RetryIntervalSec     = $Node.RetryIntervalSec

            DependsOn            = '[WindowsFeature]ADDSInstall'
        }

        ADDomainController 'SecondDC'
        {
            DomainName                    = $Node.DomainName
            Credential                    = $Credential
            SafeModeAdministratorPassword = $SafeModePassword

            DependsOn                     = '[WaitForADDomain]DscForestWait'
        }
    }
}
