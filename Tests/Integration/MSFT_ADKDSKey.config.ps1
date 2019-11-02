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
                NodeName        = 'localhost'
                CertificateFile = $env:DscPublicCertificatePath
                EffectiveTime   = '01/01/1999 13:00:00'
            }
        )
    }
}

<#
    .SYNOPSIS
        Create a KDS root key in the past. This will allow the key to be used right away
#>
Configuration MSFT_ADKDSKey_CreateKDSRootKeyInPast_Config
{
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'

    node $AllNodes.NodeName
    {
        ADKDSKey 'Integration_Test'
        {
            Ensure                   = 'Present'
            EffectiveTime            = $ConfigurationData.AllNodes.EffectiveTime
            AllowUnsafeEffectiveTime = $true
        }
    }
}
