<#
    .EXAMPLE
        In this example we will modify an existing AD Replication Site Link.
#>

configuration ModifyExistingReplicationSiteLink
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADReplicationSiteLink HQSiteLink
        {
            Name                          = 'HQSiteLInk'
            SitesIncluded                 = 'site1'
            SitesExcluded                 = 'site2'
            Cost                          = 100
            ReplicationFrequencyInMinutes = 20
            Ensure                        = 'Present'
        }
    }
}
