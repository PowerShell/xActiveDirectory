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
    $computersContainerDistinguishedName = (Get-ADDomain).ComputersContainer
    if ($computersContainerDistinguishedName -match 'DC=.+')
    {
        $domainDistinguishedName = $matches[0]
    }

    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName                = 'localhost'
                CertificateFile         = $env:DscPublicCertificatePath

                DomainDistinguishedName = $domainDistinguishedName
                ComputerName1           = 'DSCINTEGTEST01'
                ComputerName2           = 'DSCINTEGTEST02'
                ComputerName3           = 'DSCINTEGTEST03'
                RequestFileName         = 'C:\DscComputer3.txt'

                OrganizationalUnitName  = 'Global'

                Location                = 'New location'
                DnsHostName             = 'DSCINTEGTEST01@contoso.com'
                ServicePrincipalNames   = @('spn/a', 'spn/b')
                UserPrincipalName       = 'DSCINTEGTEST01@contoso.com'
                DisplayName             = 'DSCINTEGTEST01'
                Description             = 'New description'
            }
        )
    }
}

<#
    .SYNOPSIS
        Creates a computer account using the default values.

    .NOTES
        This computer account should be created enabled, as it will
        use the default value for the property Enable of the cmdlet
        New-ADComputer.
#>
Configuration MSFT_xADComputer_CreateComputerAccount1_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADComputer 'Integration_Test'
        {
            ComputerName = $Node.ComputerName1
        }
    }
}

<#
    .SYNOPSIS
        Removes a computer account using the default values.

    .NOTES
        This removed computer account will later be used to restore the
        computer account from the recycle bin.
#>
Configuration MSFT_xADComputer_RemoveComputerAccount1_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADComputer 'Integration_Test'
        {
            Ensure       = 'Absent'
            ComputerName = $Node.ComputerName1
        }
    }
}

<#
    .SYNOPSIS
        Restores a computer account from recycle bin.

#>
Configuration MSFT_xADComputer_RestoreComputerAccount1_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADComputer 'Integration_Test'
        {
            Ensure                = 'Present'
            ComputerName          = $Node.ComputerName1
            RestoreFromRecycleBin = $true
        }
    }
}

<#
    .SYNOPSIS
        Updates all available properties on a computer account.

#>
Configuration MSFT_xADComputer_UpdateComputerAccount1_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADOrganizationalUnit 'Global'
        {
            Ensure                          = 'Present'
            Name                            = $Node.OrganizationalUnitName
            Path                            = $Node.DomainDistinguishedName
            ProtectedFromAccidentalDeletion = $false
        }

        xADComputer 'Integration_Test'
        {
            Ensure                = 'Present'
            ComputerName          = $Node.ComputerName1
            Location              = $Node.Location
            DnsHostName           = $Node.DnsHostName
            ServicePrincipalNames = $Node.ServicePrincipalNames
            UserPrincipalName     = $Node.UserPrincipalName
            DisplayName           = $Node.DisplayName
            Path                  = 'OU={0},{1}' -f $Node.OrganizationalUnitName, $Node.DomainDistinguishedName
            Description           = $Node.Description

            DependsOn             = '[xADOrganizationalUnit]Global'
        }
    }
}

<#
    .SYNOPSIS
        Creates a computer account disabled.
#>
Configuration MSFT_xADComputer_CreateComputerAccount2Disabled_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADComputer 'Integration_Test'
        {
            ComputerName      = $Node.ComputerName2
            EnabledOnCreation = $false
        }
    }
}


<#
    .SYNOPSIS
        Creates a computer account using the default values.

    .NOTES
        This computer account should be created enabled, as it will
        use the default value for the property Enable of the cmdlet
        New-ADComputer.
#>
Configuration MSFT_xADComputer_CreateComputerAccount3WithOfflineDomainJoin_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'

    node $AllNodes.NodeName
    {
        xADComputer 'Integration_Test'
        {
            ComputerName = $Node.ComputerName3
            RequestFile  = $Node.RequestFileName
        }
    }
}

<#
    .SYNOPSIS
        Clean up all the computer accounts.
#>
Configuration MSFT_xADComputer_CleanUp_Config
{
    Import-DscResource -ModuleName 'xActiveDirectory'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    node $AllNodes.NodeName
    {
        xADComputer 'RemoveComputerAccount1'
        {
            Ensure       = 'Absent'
            ComputerName = $Node.ComputerName1
        }

        xADComputer 'RemoveComputerAccount2'
        {
            Ensure       = 'Absent'
            ComputerName = $Node.ComputerName2
        }

        xADComputer 'RemoveComputerAccount3'
        {
            Ensure       = 'Absent'
            ComputerName = $Node.ComputerName3
        }

        xADOrganizationalUnit 'RemoveRegions'
        {
            Ensure = 'Absent'
            Name   = $Node.OrganizationalUnitName
            Path   = $Node.DomainDistinguishedName
        }

        File 'RemoveRequestFile'
        {
            Ensure          = 'Absent'
            DestinationPath = $Node.RequestFileName
        }
    }
}
