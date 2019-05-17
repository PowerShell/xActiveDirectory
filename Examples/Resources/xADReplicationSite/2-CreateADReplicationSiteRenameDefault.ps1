<#
.EXAMPLE
    In this example, we will create an Active Directory replication site called 'Seattle'.
    If the 'Default-First-Site-Name' site exists, it will rename this site instead of create a new one.

#>
configuration Example_xADReplicationSite
{
    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADReplicationSite 'SeattleSite'
        {
           Ensure                     = 'Present'
           Name                       = 'Seattle'
           RenameDefaultFirstSiteName = $true
        }
    }
}
