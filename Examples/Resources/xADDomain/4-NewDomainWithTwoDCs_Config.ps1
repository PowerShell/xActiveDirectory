<#PSScriptInfo
.VERSION 1.0
.GUID 400370df-41bc-44d4-8730-0aa9a135383f
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
        This configuration will create a highly available domain by adding
        a second domain controller to the newly created domain.
        The xWaitForDomain resource is used to ensure that the domain is
        present before the second domain controller is added.
#>

Configuration NewDomainWithTwoDCs_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorCred,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $domainCred,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DNSDelegationCred,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $NewADUserCred
    )

    Import-DscResource -ModuleName xActiveDirectory

    Node $AllNodes.Where{ $_.Role -eq 'Primary DC' }.NodeName
    {
        WindowsFeature 'ADDSInstall'
        {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }

        xADDomain 'FirstDS'
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $SafemodeAdministratorCred
            DnsDelegationCredential       = $DNSDelegationCred
            DependsOn                     = '[WindowsFeature]ADDSInstall'
        }

        xWaitForADDomain 'DscForestWait'
        {
            DomainName           = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount           = $Node.RetryCount
            RetryIntervalSec     = $Node.RetryIntervalSec
            DependsOn            = '[xADDomain]FirstDS'
        }

        xADUser 'FirstUser'
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            UserName                      = 'dummy'
            Password                      = $NewADUserCred
            Ensure                        = 'Present'
            DependsOn                     = '[xWaitForADDomain]DscForestWait'
        }
    }

    Node $AllNodes.Where{ $_.Role -eq 'Replica DC' }.NodeName
    {
        WindowsFeature 'ADDSInstall'
        {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }

        xWaitForADDomain 'DscForestWait'
        {
            DomainName           = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount           = $Node.RetryCount
            RetryIntervalSec     = $Node.RetryIntervalSec
            DependsOn            = '[WindowsFeature]ADDSInstall'
        }

        xADDomainController 'SecondDC'
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $SafemodeAdministratorCred
            DependsOn                     = '[xWaitForADDomain]DscForestWait'
        }
    }
}

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
