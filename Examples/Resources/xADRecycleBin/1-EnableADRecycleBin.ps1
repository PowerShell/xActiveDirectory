<#
.EXAMPLE
    This example will enable the Active Directory Recycle Bin for a specified Domain
#>

Configuration EnableADRecycleBin
{
    Param(
        [parameter(Mandatory = $true)]
        [System.String]
        $ForestFQDN,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EACredential
    )

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADRecycleBin RecycleBin
        {
            EnterpriseAdministratorCredential = $EACredential
            ForestFQDN                        = $ForestFQDN
        }
    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = '2012r2-dc'
        }
    )
}
