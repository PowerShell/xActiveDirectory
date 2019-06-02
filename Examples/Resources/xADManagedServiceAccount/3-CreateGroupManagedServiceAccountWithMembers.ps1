<#
    .EXAMPLE
        In this example we will create a managed service account.
#>

configuration CreateGroupManagedServiceAccountWithMembers
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADManagedServiceAccount AddingMembersUsingSamAccountName
        {
            Ensure             = 'Present'
            ServiceAccountName = 'Service01'
            AccountType        = 'Group'
            Path               = 'OU=ServiceAccounts,DC=contoso,DC=com'
            Members            = 'User01', 'Computer01$'
        }

        xADManagedServiceAccount AddingMembersUsingDN
        {
            Ensure             = 'Present'
            ServiceAccountName = 'Service02'
            AccountType        = 'Group'
            Path               = 'OU=ServiceAccounts,DC=contoso,DC=com'
            Members            = 'CN=User01,OU=Users,DC=contoso,DC=com', 'CN=Computer01,OU=Computers,DC=contoso,DC=com'
        }
    }
}
