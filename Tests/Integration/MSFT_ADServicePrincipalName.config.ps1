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
    $currentDomain = Get-ADDomain
    $domainDistinguishedName = $currentDomain.DistinguishedName

    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName        = 'localhost'
                CertificateFile = $env:DscPublicCertificatePath

                PSDscAllowPlainTextPassword = $true

                DomainDistinguishedName = $domainDistinguishedName
                Password = New-Object `
                    -TypeName System.Management.Automation.PSCredential `
                    -ArgumentList @(
                    'AnyName',
                    (ConvertTo-SecureString -String 'P@ssW0rd1' -AsPlainText -Force)
                )
            }
        )
    }
}

<#
    .DESCRIPTION
        This configuration will add a Computer to the domain
#>
Configuration MSFT_ADServicePrincipalName_PreReqs_Config
{
    Import-DscResource -Module ActiveDirectoryDsc

    Node $AllNodes.NodeName
    {
        ADComputer 'Integration_Test'
        {
            ComputerName = 'IIS01'
            Ensure       = 'Present'
        }

        ADUser 'Integration_Test'
        {
            DomainName = $Node.DomainDistinguishedName
            UserName   = 'SQL01Svc'
            Password   = $Node.Password
        }
    }
}

<#
    .DESCRIPTION
        This configuration will add a Service Principal Name to a user account.
#>
Configuration MSFT_ADServicePrincipalName_AddUserServicePrincipalName_Config
{
    Import-DscResource -Module ActiveDirectoryDsc

    Node $AllNodes.NodeName
    {
        ADServicePrincipalName 'Integration_Test'
        {
            ServicePrincipalName = 'MSSQLSvc/sql01.contoso.com:1433'
            Account              = 'SQL01Svc'
            Ensure               = 'Present'
        }
    }
}

<#
    .DESCRIPTION
        This configuration will add a second Service Principal Name to a user account.
#>
Configuration MSFT_ADServicePrincipalName_AddSecondUserServicePrincipalName_Config
{
    Import-DscResource -Module ActiveDirectoryDsc

    Node $AllNodes.NodeName
    {
        ADServicePrincipalName 'Integration_Test'
        {
            ServicePrincipalName = 'MSSQLSvc/sql02.contoso.com:1433'
            Account              = 'SQL01Svc'
            Ensure               = 'Present'
        }
    }
}

<#
    .DESCRIPTION
        This configuration will add a Service Principal Name to a computer account.
#>
Configuration MSFT_ADServicePrincipalName_AddComputerServicePrincipalName_Config
{
    Import-DscResource -Module ActiveDirectoryDsc

    Node $AllNodes.NodeName
    {
        ADServicePrincipalName 'Integration_Test'
        {
            ServicePrincipalName = 'HTTP/web.contoso.com'
            Account              = 'IIS01$'
            Ensure               = 'Present'
        }
    }
}

<#
    .DESCRIPTION
        This configuration will remove a Service Principal Name from a user account.
#>
Configuration MSFT_ADServicePrincipalName_RemoveUserServicePrincipalName_Config
{
    Import-DscResource -Module ActiveDirectoryDsc

    Node $AllNodes.NodeName
    {
        ADServicePrincipalName 'Integration_Test'
        {
            ServicePrincipalName = 'MSSQLSvc/sql01.contoso.com:1433'
            Account              = 'SQL01Svc'
            Ensure               = 'Absent'
        }
    }
}

<#
    .DESCRIPTION
        This configuration will remove the second Service Principal Name from a user account.
#>
Configuration MSFT_ADServicePrincipalName_RemoveSecondUserServicePrincipalName_Config
{
    Import-DscResource -Module ActiveDirectoryDsc

    Node $AllNodes.NodeName
    {
        ADServicePrincipalName 'Integration_Test'
        {
            ServicePrincipalName = 'MSSQLSvc/sql02.contoso.com:1433'
            Account              = 'SQL01Svc'
            Ensure               = 'Absent'
        }
    }
}

<#
    .DESCRIPTION
        This configuration will add a Service Principal Name to a computer account.
#>
Configuration MSFT_ADServicePrincipalName_RemoveComputerServicePrincipalName_Config
{
    Import-DscResource -Module ActiveDirectoryDsc

    Node $AllNodes.NodeName
    {
        ADServicePrincipalName 'Integration_Test'
        {
            ServicePrincipalName = 'HTTP/web.contoso.com'
            Account              = 'IIS01$'
            Ensure               = 'Absent'
        }
    }
}

<#
    .DESCRIPTION
        This configuration will remove a Computer from the domain
#>
Configuration MSFT_ADServicePrincipalName_RemovePreReqs_Config
{
    Import-DscResource -Module ActiveDirectoryDsc

    Node $AllNodes.NodeName
    {
        ADComputer 'Integration_Test'
        {
            ComputerName = 'IIS01'
            Ensure       = 'Absent'
        }
        ADUser 'Integration_Test'
        {
            DomainName = $Node.DomainDistinguishedName
            UserName   = 'SQL01Svc'
            Password   = $Node.Password
            Ensure     = 'Absent'
        }
    }
}
