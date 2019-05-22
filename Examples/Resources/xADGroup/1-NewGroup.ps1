<#
.EXAMPLE
    This example creates a new domain-local group in contoso
#>
configuration Example_xADGroup
{
Param(
    [parameter(Mandatory = $true)]
    [System.String]
    $GroupName,

    [ValidateSet('DomainLocal','Global','Universal')]
    [System.String]
    $Scope = 'Global',

    [ValidateSet('Security','Distribution')]
    [System.String]
    $Category = 'Security',

    [ValidateNotNullOrEmpty()]
    [System.String]
    $Description
)

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADGroup ExampleGroup
        {
           GroupName = $GroupName
           GroupScope = $Scope
           Category = $Category
           Description = $Description
           Ensure = 'Present'
        }
    }
}