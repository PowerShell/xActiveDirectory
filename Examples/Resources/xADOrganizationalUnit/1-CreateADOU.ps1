<#
    .EXAMPLE
        In this example, we add an Active Directory organizational unit to the 'example.com' domain root.
#>
configuration Example_xADOrganizationalUnit
{
    Param(
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [System.Boolean]
        $ProtectedFromAccidentalDeletion = $true,

        [ValidateNotNull()]
        [System.String]
        $Description = ''
    )

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADOrganizationalUnit ExampleOU
        {
            Name                            = $Name
            Path                            = $Path
            ProtectedFromAccidentalDeletion = $ProtectedFromAccidentalDeletion
            Description                     = $Description
            Ensure                          = 'Present'
        }
    }
}

Example_xADOrganizationalUnit -Name 'Example OU' -Path 'dc=example,dc=com' -Description 'Example test organizational unit' -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path .\Example_xADOrganizationalUnit -Wait -Verbose
