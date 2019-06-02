<#
    .EXAMPLE
        In the following example configuration, a highly available domain is created by adding a second domain controller to the newly created domain.
        This example uses the xWaitForDomain resource to ensure that the domain is present before the second domain controller is added.
#>
Configuration NewDomainWithTwoDCs
{
    param
    (
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,
        [Parameter(Mandatory)]
        [pscredential]$domainCred,
        [Parameter(Mandatory)]
        [pscredential]$DNSDelegationCred,
        [Parameter(Mandatory)]
        [pscredential]$NewADUserCred
    )
    Import-DscResource -ModuleName xActiveDirectory
    Node $AllNodes.Where{ $_.Role -eq "Primary DC" }.Nodename
    {
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name   = "AD-Domain-Services"
        }
        xADDomain FirstDS
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DnsDelegationCredential       = $DNSDelegationCred
            DependsOn                     = "[WindowsFeature]ADDSInstall"
        }
        xWaitForADDomain DscForestWait
        {
            DomainName           = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount           = $Node.RetryCount
            RetryIntervalSec     = $Node.RetryIntervalSec
            DependsOn            = "[xADDomain]FirstDS"
        }
        xADUser FirstUser
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            UserName                      = "dummy"
            Password                      = $NewADUserCred
            Ensure                        = "Present"
            DependsOn                     = "[xWaitForADDomain]DscForestWait"
        }
    }
    Node $AllNodes.Where{ $_.Role -eq "Replica DC" }.Nodename
    {
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name   = "AD-Domain-Services"
        }
        xWaitForADDomain DscForestWait
        {
            DomainName           = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount           = $Node.RetryCount
            RetryIntervalSec     = $Node.RetryIntervalSec
            DependsOn            = "[WindowsFeature]ADDSInstall"
        }
        xADDomainController SecondDC
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DependsOn                     = "[xWaitForADDomain]DscForestWait"
        }
    }
}
# Configuration Data for AD
$ConfigurationData = @{
    AllNodes = @(
        @{
            Nodename         = "dsc-testNode1"
            Role             = "Primary DC"
            DomainName       = "dsc-test.contoso.com"
            CertificateFile  = "C:\publicKeys\targetNode.cer"
            Thumbprint       = "AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8"
            RetryCount       = 20
            RetryIntervalSec = 30
        },
        @{
            Nodename         = "dsc-testNode2"
            Role             = "Replica DC"
            DomainName       = "dsc-test.contoso.com"
            CertificateFile  = "C:\publicKeys\targetNode.cer"
            Thumbprint       = "AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8"
            RetryCount       = 20
            RetryIntervalSec = 30
        }
    )
}
