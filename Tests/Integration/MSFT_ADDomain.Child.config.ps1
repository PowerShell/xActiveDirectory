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
                NodeName           = 'localhost'
                CertificateFile    = $env:DscPublicCertificatePath
                CredentialUserName = 'administrator@contoso.com'
                CredentialPassword = 'password'
                SafeModePassword   = 'SafemodePassword@1'
                Tests              = [Ordered]@{
                    FeatureInstall   = @{ }
                    ForestChildDomain = @{
                        DomainName        = 'child'
                        ParentDomainName  = 'contoso.com'
                        DomainNetbiosName = 'CHILD-CONTOSO'
                        DatabasePath      = 'C:\NTDS'
                        LogPath           = 'C:\NTDS'
                        SysvolPath        = 'C:\SysVol'
                        DomainMode        = 'WinThreshold'
                    }
                }
            }
        )
    }
}

<#
    .SYNOPSIS
        Initialise Config
#>
Configuration MSFT_ADDomain_FeatureInstall_Config
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    $testName = 'FeatureInstall'

    node $AllNodes.NodeName
    {
        WindowsFeature 'ADDS'
        {
            Name = 'AD-Domain-Services'
        }
    }
}

<#
    .SYNOPSIS
        Initialise Config
#>
Configuration MSFT_ADDomain_ForestChildDomain_Config
{
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'

    $testName = 'ForestChildDomain'

    node $AllNodes.NodeName
    {
        $SecureCredentialPassword = ConvertTo-SecureString `
            -String $Node.CredentialPassword `
            -AsPlainText -Force

        $Credential = [System.Management.Automation.PSCredential]::new(
            $Node.CredentialUserName,
            $SecureCredentialPassword
        )

        $SafeModePassword = ConvertTo-SecureString `
            -String $Node.SafeModePassword `
            -AsPlainText -Force

        $SafemodeCredential = [System.Management.Automation.PSCredential]::new('n/a', $SafemodePassword)

        ADDomain Integration_Test
        {
            DomainName                    = $Node.Tests.$testName.DomainName
            ParentDomainName              = $Node.Tests.$testName.ParentDomainName
            Credential                    = $Credential
            SafemodeAdministratorPassword = $SafeModeCredential
            DomainNetbiosName             = $Node.Tests.$testName.DomainNetbiosName
            DatabasePath                  = $Node.Tests.$testName.DatabasePath
            LogPath                       = $Node.Tests.$testName.LogPath
            SysvolPath                    = $Node.Tests.$testName.SysvolPath
            DomainMode                    = $Node.Tests.$testName.DomainMode
        }
    }
}
