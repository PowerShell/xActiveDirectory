<#
    .EXAMPLE
        In this example, we will add full control (GenericAll) permissions to
        the virtual computer object (VCO) ROLE01 for a cluster name object (CNO)
        CONTOSO\CLUSTER01$. This is used so that the Windows Failover Cluster
        can control the roles AD objects.
#>

configuration DelegateFullControl
{
    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADObjectPermissionEntry ADObjectPermissionEntry
        {
            Ensure                             = 'Present'
            Path                               = 'CN=ROLE01,CN=Computers,DC=contoso,DC=com'
            IdentityReference                  = 'CONTOSO\CLUSTER01$'
            ActiveDirectoryRights              = 'GenericAll'
            AccessControlType                  = 'Allow'
            ObjectType                         = '00000000-0000-0000-0000-000000000000'
            ActiveDirectorySecurityInheritance = 'None'
            InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
        }
    }
}
