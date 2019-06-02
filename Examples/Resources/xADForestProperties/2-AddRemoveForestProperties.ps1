<#
.EXAMPLE
    This example manages the Service and User Principal name suffixes in the Consto.com
    forest by adding and removing the desired suffixes.  This will not overwrite existing
    suffixes in the forest.
#>
configuration AddRemoveForestProperties
{
    Import-DscResource -ModuleName xActiveDirectory

    node localhost
    {
        xADForestProperties ContosoProperties
        {
            ForestName                          = 'contoso.com'
            ServicePrincipalNameSuffixToAdd     = 'test.net'
            ServicePrincipalNameSuffixToRemove  = 'test.com'
            UserPrincipalNameSuffixToAdd        = 'cloudapp.net', 'fabrikam.com'
            UserPrincipalNameSuffixToRemove     = 'pester.net'
        }
    }
}
