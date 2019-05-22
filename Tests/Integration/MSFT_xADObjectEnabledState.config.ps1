#region HEADER
# Integration Test Config Template Version: 1.2.0
#endregion

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    <#
        Allows reading the configuration data from a JSON file, for real testing
        scenarios outside of the CI.
    #>
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName                = 'localhost'
                CertificateFile         = $env:DscPublicCertificatePath

                ComputerName            = 'DSCINTEGTEST01'
            }
        )
    }
}

<#
    .SYNOPSIS
        Creates a computer account using the default values.
#>
Configuration MSFT_xADObjectEnabledState_Prerequisites_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADComputer 'CreateComputerAccount'
        {
            ComputerName = $Node.ComputerName
        }
    }
}

<#
    .SYNOPSIS
        Disables a computer account.

#>
Configuration MSFT_xADObjectEnabledState_DisableComputerAccount_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADObjectEnabledState 'Integration_Test'
        {
            Identity    = $Node.ComputerName
            ObjectClass = 'Computer'
            Enabled     = $false
        }
    }
}

<#
    .SYNOPSIS
        Enables a computer account.

#>
Configuration MSFT_xADObjectEnabledState_EnableComputerAccount_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADObjectEnabledState 'Integration_Test'
        {
            Identity    = $Node.ComputerName
            ObjectClass = 'Computer'
            Enabled     = $true
        }
    }
}

<#
    .SYNOPSIS
        Clean up the computer account.
#>
Configuration MSFT_xADObjectEnabledState_CleanUp_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADComputer 'RemoveComputerAccount'
        {
            Ensure       = 'Absent'
            ComputerName = $Node.ComputerName
        }
    }
}
