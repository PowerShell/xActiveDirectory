<#
    .EXAMPLE
        In this example, we create a 'NANO-001' computer account in the 'Server' OU of the 'example.com' Active Directory domain.
#>
configuration Example_xADComputerAccount
{
    Param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $DomainController,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DomainCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $ComputerName,

        [parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADComputer "$ComputerName"
        {
           DomainController = $DomainController
           DomainAdministratorCredential = $DomainCredential
           ComputerName = $ComputerName
           Path = $Path
        }
    }
}

Example_xADComputerAccount -DomainController 'DC01' `
    -DomainCredential (Get-Credential -Message "Domain Credentials") `
    -ComputerName 'NANO-001' `
    -Path 'ou=Servers,dc=example,dc=com' `
    -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path .\Example_xADComputerAccount -Wait -Verbose
