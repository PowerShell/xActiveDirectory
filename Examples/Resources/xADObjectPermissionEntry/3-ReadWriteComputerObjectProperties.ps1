<#
    .EXAMPLE
        Allow a group permission to read and write (ReadProperty,WriteProperty)
        all properties of computer objects in an OU and all sub-OUs that may get
        created.
#>

configuration ReadWriteComputerObjectProperties
{
    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADObjectPermissionEntry ADObjectPermissionEntry
        {
            Ensure                             = 'Present'
            Path                               = 'OU=ContosoComputers,DC=contoso,DC=com'
            IdentityReference                  = 'CONTOSO\ComputerAdminGroup'
            ActiveDirectoryRights              = 'ReadProperty', 'WriteProperty'
            AccessControlType                  = 'Allow'
            ObjectType                         = '00000000-0000-0000-0000-000000000000'
            ActiveDirectorySecurityInheritance = 'Descendents'
            InheritedObjectType                = 'bf967a86-0de6-11d0-a285-00aa003049e2' # Computer objects
        }
    }
}
