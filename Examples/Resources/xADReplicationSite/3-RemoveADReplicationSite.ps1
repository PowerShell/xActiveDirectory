<#
    .EXAMPLE
        In this example, we will remove the Active Directory replication site called 'Cupertino'.
#>
configuration RemoveADReplicationSite
{
    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADReplicationSite 'CupertinoSite'
        {
            Ensure = 'Absent'
            Name   = 'Cupertino'
        }
    }
}
