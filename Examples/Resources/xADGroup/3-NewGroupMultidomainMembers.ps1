<#
.EXAMPLE
    This example creates a new domain-local group in contoso with three members in different domains.
#>
configuration NewGroupMultidomainMembers
{
    Import-DscResource -ModuleName xActiveDirectory

    node localhost
    {
        xADGroup dl1
        {
            GroupName = 'DL_APP_1'
            GroupScope = 'DomainLocal'
            MembershipAttribute = 'DistinguishedName'
            Members = 'CN=john,OU=Accounts,DC=contoso,DC=com','CN=jim,OU=Accounts,DC=subdomain,DC=contoso,DC=com','CN=sally,OU=Accounts,DC=anothersub,DC=contoso,DC=com'
        }
    }
}
