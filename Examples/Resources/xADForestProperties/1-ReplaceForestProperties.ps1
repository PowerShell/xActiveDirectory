<#
.EXAMPLE
    This example manages the Service and User Principal name suffixes in the Consto.com
    forest by replacing any existing suffixes with the ones specified in the configuration.
#>
configuration Example
{
    Import-DscResource -ModuleName xActiveDirectory

    node localhost
    {
        xADForestProperties ContosoProperties
        {
            ForestName                 = 'contoso.com'
            UserPrincipalNameSuffix    = 'fabrikam.com', 'industry.com'
            ServicePrincipalNameSuffix = 'corporate.com'
        }
    }
}
