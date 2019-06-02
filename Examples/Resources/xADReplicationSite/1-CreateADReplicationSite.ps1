<#
    .EXAMPLE
        In this example, we will create an Active Directory replication site called 'Seattle'.
#>
configuration CreateADReplicationSite
{
    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADReplicationSite 'SeattleSite'
        {
            Ensure = 'Present'
            Name   = 'Seattle'
        }
    }
}
