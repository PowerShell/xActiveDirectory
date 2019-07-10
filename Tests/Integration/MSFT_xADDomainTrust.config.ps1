#region HEADER
# Integration Test Config Template Version: 1.2.0
#endregion

<#
    .NOTES
        To run this integration test there are prerequisites that need to
        be setup.

        1. One Domain Controller with forest contoso.com.
        2. One Domain Controller with forest lab.local.
        3. DNS working between the forests (conditional forwarder).
        4. Credentials with permission in the target domain (lab.local).
        5. If no certificate path is set to the environment variable
           `$env:DscPublicCertificatePath` then `PSDscAllowPlainTextPassword = $true`
           must be added to the ConfigurationData-block.
#>

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

                SourceDomain    = 'contoso.com'
                TargetDomain    = 'lab.local'

                SourceForest    = 'contoso.com'
                TargetForest    = 'lab.local'

                TargetUserName  = "LAB\Administrator"
                TargetPassword  = 'P@ssw0rd1'
            }
        )
    }
}

<#
    .SYNOPSIS
        Creates a domain trust.
#>
Configuration MSFT_xADDomainTrust_CreateDomainTrust_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADDomainTrust 'Integration_Test'
        {
            SourceDomainName                    = $Node.SourceDomain
            TargetDomainName                    = $Node.TargetDomain
            TrustType                           = 'External'
            TrustDirection                      = 'Outbound'
            TargetDomainAdministratorCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($Node.TargetUserName, (ConvertTo-SecureString -String $Node.TargetPassword -AsPlainText -Force))

        }
    }
}

<#
    .SYNOPSIS
        Changes trust direction on an existing domain trust.
#>
Configuration MSFT_xADDomainTrust_ChangeDomainTrustDirection_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADDomainTrust 'Integration_Test'
        {
            SourceDomainName                    = $Node.SourceDomain
            TargetDomainName                    = $Node.TargetDomain
            TrustType                           = 'External'
            TrustDirection                      = 'Inbound'
            TargetDomainAdministratorCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($Node.TargetUserName, (ConvertTo-SecureString -String $Node.TargetPassword -AsPlainText -Force))

        }
    }
}

<#
    .SYNOPSIS
        Removes the domain trust.
#>
Configuration MSFT_xADDomainTrust_RemoveDomainTrust_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADDomainTrust 'Integration_Test'
        {
            Ensure                              = 'Absent'
            SourceDomainName                    = $Node.SourceDomain
            TargetDomainName                    = $Node.TargetDomain
            TrustType                           = 'External'
            TrustDirection                      = 'Bidirectional'
            TargetDomainAdministratorCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($Node.TargetUserName, (ConvertTo-SecureString -String $Node.TargetPassword -AsPlainText -Force))

        }
    }
}

<#
    .SYNOPSIS
        Creates a forest trust.
#>
Configuration MSFT_xADDomainTrust_CreateForestTrust_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADDomainTrust 'Integration_Test'
        {
            SourceDomainName                    = $Node.SourceForest
            TargetDomainName                    = $Node.TargetForest
            TrustType                           = 'Forest'
            TrustDirection                      = 'Outbound'
            TargetDomainAdministratorCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($Node.TargetUserName, (ConvertTo-SecureString -String $Node.TargetPassword -AsPlainText -Force))

        }
    }
}

<#
    .SYNOPSIS
        Changes trust direction on an existing forest trust.
#>
Configuration MSFT_xADDomainTrust_ChangeForestTrustDirection_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADDomainTrust 'Integration_Test'
        {
            SourceDomainName                    = $Node.SourceForest
            TargetDomainName                    = $Node.TargetForest
            TrustType                           = 'Forest'
            TrustDirection                      = 'Inbound'
            TargetDomainAdministratorCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($Node.TargetUserName, (ConvertTo-SecureString -String $Node.TargetPassword -AsPlainText -Force))

        }
    }
}

<#
    .SYNOPSIS
        Removes the domain trust.
#>
Configuration MSFT_xADDomainTrust_RemoveForestTrust_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADDomainTrust 'Integration_Test'
        {
            Ensure                              = 'Absent'
            SourceDomainName                    = $Node.SourceForest
            TargetDomainName                    = $Node.TargetForest
            TrustType                           = 'Forest'
            TrustDirection                      = 'Bidirectional'
            TargetDomainAdministratorCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($Node.TargetUserName, (ConvertTo-SecureString -String $Node.TargetPassword -AsPlainText -Force))

        }
    }
}
