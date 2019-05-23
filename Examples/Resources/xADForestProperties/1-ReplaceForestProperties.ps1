<#
.EXAMPLE
    This example manages the Service and User Principal name suffixes in the Consto.com
    forest by replacing any existing suffixes with the ones specified in the configuration.
#>
configuration Example_ADPrincipalSuffix
{
    Param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $TargetName,

        [parameter(Mandatory = $true)]
        [System.String]
        $ForestName,

        [parameter(Mandatory = $true)]
        [String[]]
        $UserPrincipalNameSuffix,

        [parameter(Mandatory = $true)]
        [String[]]
        $ServicePrincipalNameSuffix
    )

Import-DscResource -ModuleName xActiveDirectory

    node $TargetName
    {
        xADForestProperties $ForestName
        {
            ForestName = $ForestName
            UserPrincipalNameSuffix = $UserPrincipalNameSuffix
            ServicePrincipalNameSuffix = $ServicePrincipalNameSuffix
        }
    }
}

$parameters = @{
    TargetName = 'dc.contoso.com'
    ForestName = 'contoso.com'
    UserPrincipalNameSuffix = 'fabrikam.com','industry.com'
    ServicePrincipalNameSuffix = 'corporate.com'
    OutputPath = c:\output
}
