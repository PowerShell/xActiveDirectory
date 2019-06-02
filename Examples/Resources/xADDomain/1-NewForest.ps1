<#
    .EXAMPLE
        This example will create a new domain with a new forest and a forest functional level of Server 2016
#>
$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName   = 'localhost'
            FFL        = 'WinThreshold'
            DomainName = 'contoso.com'
        }
    )
}

configuration NewForest
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
            ForestMode                    = $Node.FFL
        }
    }
}
