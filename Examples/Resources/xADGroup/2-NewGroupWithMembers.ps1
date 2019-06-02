<#
.EXAMPLE
    This example creates a new domain-local group in contoso with three members.
#>
configuration NewGroupWithMembers
{
    Import-DscResource -ModuleName xActiveDirectory

    node localhost
    {
        xADGroup dl1
        {
            GroupName = 'DL_APP_1'
            GroupScope = 'DomainLocal'
            Members = 'john','jim','sally'
        }
    }
}
