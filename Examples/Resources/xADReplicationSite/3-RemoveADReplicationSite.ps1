<#
    .EXAMPLE
        In this example, we will remove the Active Directory replication site called 'Cupertino'.
#>
configuration Example_xADReplicationSite
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

Example_xADReplicationSite

Start-DscConfiguration -Path .\Example_xADReplicationSite -Wait -Verbose