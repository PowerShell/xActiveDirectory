<#
    .EXAMPLE
        In this example we will create an AD Replication Site Link.
#>

configuration CreateReplicationSiteLink
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADReplicationSiteLink HQSiteLink
        {
            Name                          = 'HQSiteLInk'
            SitesIncluded                 = @('site1', 'site2')
            Cost                          = 100
            ReplicationFrequencyInMinutes = 15
            Ensure                        = 'Present'
        }
    }
}
