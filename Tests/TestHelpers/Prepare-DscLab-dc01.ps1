<#
    .SYNOPSIS
        Prerequisites configuration for running integration tests.
        This configuration sets up the prerequisites for the
        node dc01.dscadlab.com.

    .NOTES
        This must initialize the test environment prior running so
        that the configuration can find the required modules.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                    = '*'
            PSDscAllowDomainUser        = $true
            PsDscAllowPlainTextPassword = $true
        },
        @{
            NodeName = 'localhost'
        }
    )
}

[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node $AllNodes.NodeName
    {
        Settings
        {
            RefreshMode          = 'Push'
            RebootNodeIfNeeded   = $false
            ConfigurationMode    = 'ApplyOnly'
            CertificateId        = $node.Thumbprint
            AllowModuleOverwrite = $true
            DebugMode            = 'ForceModuleImport'
        }
    }
}

<#
    .SYNOPSIS
        Configures the Hyper-V node dc01 with the correct prerequisites.
#>
Configuration DomainController
{
    Import-DSCResource -ModuleName 'PSDscResources' -ModuleVersion '2.12.0.0'
    Import-DSCResource -ModuleName 'NetworkingDsc' -ModuleVersion '7.4.0.0'
    Import-DSCResource -ModuleName 'ComputerManagementDsc' -ModuleVersion '8.1.0'

    Node 'localhost'
    {
        Computer NewName
        {
            Name        = 'dc01'
            Description = 'First domain controller'
        }

        DnsClientGlobalSetting ConfigureSuffixSearchListSingle
        {
            IsSingleInstance = 'Yes'
            SuffixSearchList = 'dscadlab.com'
        }

        NetAdapterName 'RenameNetAdapter'
        {
            NewName = 'dscadlab.com'
            Status  = 'Up'
        }

        NetIPInterface 'DisableDhcp'
        {
            InterfaceAlias = 'dscadlab.com'
            AddressFamily  = 'IPv4'
            Dhcp           = 'Disabled'

            DependsOn      = '[NetAdapterName]RenameNetAdapter'
        }

        IPAddress NewIPv4Address
        {
            IPAddress      = '10.0.2.4/8'
            InterfaceAlias = 'dscadlab.com'
            AddressFamily  = 'IPV4'

            DependsOn      = '[NetAdapterName]RenameNetAdapter'
        }

        DNSServerAddress 'SetFirstDomainControllerDNSIPAddresses'
        {
            InterfaceAlias = 'dscadlab.com'
            AddressFamily  = 'IPv4'
            Address        = @('127.0.0.1', '10.0.3.4')
            Validate       = $false

            DependsOn      = '[NetAdapterName]RenameNetAdapter'
        }

        Firewall 'AllowICMP'
        {
            Ensure      = 'Present'
            Enabled     = 'True'
            Name        = 'dscadlab-allow-icmp'
            DisplayName = 'DSC AD Lab - Allow ICMP'
            Group       = 'DSC AD Lab'
            Profile     = @('Domain', 'Private', 'Public')
            Direction   = 'InBound'
            Protocol    = 'ICMPv4'
            Description = 'This rule will allow all types of the ICMP protcol to allow unrestricted ping'
        }

        WindowsFeature 'DNS'
        {
            Ensure = 'Present'
            Name   = 'DNS'
        }

        WindowsFeature 'AD-Domain-Services'
        {
            Ensure    = 'Present'
            Name      = 'AD-Domain-Services'

            DependsOn = '[WindowsFeature]DNS'
        }

        WindowsFeature 'RSAT-AD-PowerShell'
        {
            Ensure    = 'Present'
            Name      = 'RSAT-AD-PowerShell'

            DependsOn = '[WindowsFeature]AD-Domain-Services'
        }

        WindowsFeature 'RSAT-ADDS'
        {
            Ensure    = 'Present'
            Name      = 'RSAT-ADDS'

            DependsOn = '[WindowsFeature]AD-Domain-Services'
        }
    }
}

LCMConfig `
    -ConfigurationData $ConfigurationData `
    -OutputPath 'C:\DSC\Configuration' `
    -Verbose

DomainController `
    -ConfigurationData $ConfigurationData `
    -OutputPath 'C:\DSC\Configuration' `
    -Verbose
