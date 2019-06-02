<#
    .EXAMPLE
        In this example we will create a managed service account.
#>

configuration CreateGroupManagedServiceAccount
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADManagedServiceAccount ExampleGroupMSA
        {
            Ensure             = 'Present'
            ServiceAccountName = 'Service01'
            AccountType        = 'Group'
            Path               = 'OU=ServiceAccounts,DC=contoso,DC=com'
        }
    }
}
