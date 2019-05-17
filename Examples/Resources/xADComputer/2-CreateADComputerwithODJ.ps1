<#
    .EXAMPLE
        In this example, we create a 'NANO-200' computer account in the 'Nano' OU of the 'example.com' Active Directory domain as well as creating an Offline Domain Join Request file.
#>
configuration Example_xADComputerAccountODJ
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
        $Path,

        [parameter(Mandatory = $true)]
        [System.String]
        $RequestFile
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
           RequestFile = $RequestFile
        }
    }
}

Example_xADComputerAccountODJ -DomainController 'DC01' `
    -DomainCredential (Get-Credential -Message "Domain Credentials") `
    -ComputerName 'NANO-200' `
    -Path 'ou=Nano,dc=example,dc=com' `
    -RequestFile 'd:\ODJFiles\NANO-200.txt' `
    -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path .\Example_xADComputerAccount -Wait -Verbose
