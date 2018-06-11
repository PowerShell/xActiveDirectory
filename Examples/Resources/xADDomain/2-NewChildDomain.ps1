<#
    .EXAMPLE
        This example will create a new child domain in an existing forest with a Domain Functional Level of Windows Server 2012R2
#>
$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                    = 'localhost'
            DFL                         = 'Win2012R2'
            DomainName                  = 'child'
            ParentDomain                = 'contoso.com'

            <#
                NOTE! THIS IS NOT RECOMMENDED IN PRODUCTION.
                This is added so that AppVeyor automatic tests can pass, otherwise
                the tests will fail on passwords being in plain text and not being
                encrypted. Because it is not possible to have a certificate in
                AppVeyor to encrypt the passwords we need to add the parameter
                'PSDscAllowPlainTextPassword'.
                NOTE! THIS IS NOT RECOMMENDED IN PRODUCTION.
            #>
            PSDscAllowPlainTextPassword = $true
        }
    )
}

configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential
    )

    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName xActiveDirectory
    node $AllNodes.NodeName
    {
        WindowsFeature ADDS
        {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'        
        }

        WindowsFeature RSAT
        {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }

        xADDomain $Node.DomainName
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $DomainAdministratorCredential
            SafemodeAdministratorPassword = $DomainAdministratorCredential
            DomainMode                    = $Node.DFL
            ParentDomainName              = $node.ParentDomain
        }
    }

}
