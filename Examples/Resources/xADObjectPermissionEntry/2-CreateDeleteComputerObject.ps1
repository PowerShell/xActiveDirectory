<#
    .EXAMPLE
        Allow a group permission to create and delete (CreateChild,DeleteChild)
        computer objects in an OU and all sub-OUs that may get created.
#>

configuration CreateDeleteComputerObject
{
    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADObjectPermissionEntry ADObjectPermissionEntry
        {
            Ensure                             = 'Present'
            Path                               = 'OU=ContosoComputers,DC=contoso,DC=com'
            IdentityReference                  = 'CONTOSO\ComputerAdminGroup'
            ActiveDirectoryRights              = 'CreateChild', 'DeleteChild'
            AccessControlType                  = 'Allow'
            ObjectType                         = 'bf967a86-0de6-11d0-a285-00aa003049e2' # Computer objects
            ActiveDirectorySecurityInheritance = 'All'
            InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
        }
    }
}
