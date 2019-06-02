<#
    .EXAMPLE
        This example will create a new one way inbound trust between two domains.
#>

Configuration NewOneWayTrust
{
    param
    (
        [Parameter(Mandatory)]
        [String]$SourceDomain,
        [Parameter(Mandatory)]
        [String]$TargetDomain,
        [Parameter(Mandatory)]
        [PSCredential]$TargetDomainAdminCred
    )

    Import-DscResource -module xActiveDirectory
    Node $AllNodes.NodeName
    {
        xADDomainTrust trust
        {
            Ensure                              = 'Present'
            SourceDomainName                    = $SourceDomain
            TargetDomainName                    = $TargetDomain
            TargetDomainAdministratorCredential = $TargetDomainAdminCred
            TrustDirection                      = 'Inbound'
            TrustType                           = 'External'
        }
    }
}
