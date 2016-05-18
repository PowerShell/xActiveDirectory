configuration Example_xADDomainJoinFile
{
Param(
    [parameter(Mandatory = $true)]
    [System.String]
    $CompterName,
    
    [parameter(Mandatory = $true)]
    [System.String]
    $DomainName,
    
    [parameter(Mandatory = $true)]
    [System.String]
    $RequestFile,

    [ValidateNotNull()]
    [System.String]
    $Path
)

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADDomainJoinFile ExampleRequestODJ
        {
           ComputerName = $ComputerName
           DomainName = $DomainName
           RequestFile = $RequestFile
           Path = $Path
        }
    }
}

Example_xADDomainJoinFile -ComputerName 'NANOSERVER1' -DomainName 'CONTOSO.COM' -Path 'cn=Servers' -RequestFile 'c:\NANOSERVER1-ODJ.txt' -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path .\Example_xADDomainJoinFile -Wait -Verbose
