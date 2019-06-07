$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'xActiveDirectory.Common'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'xActiveDirectory.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xADRecycleBin'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ForestFQDN,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EnterpriseAdministratorCredential
    )

    $previousErrorActionPreference = $ErrorActionPreference

    try
    {
        # AD cmdlets generate non-terminating errors.
        $ErrorActionPreference = 'Stop'

        $rootDSE = Get-ADRootDSE -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential
        $recycleBinPath = "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,$($rootDSE.configurationNamingContext)"
        $msDSEnabledFeature = Get-ADObject -Identity "CN=Partitions,$($rootDSE.configurationNamingContext)" -Property 'msDS-EnabledFeature' -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential |
            Select-Object -ExpandProperty 'msDS-EnabledFeature'

        if ($msDSEnabledFeature -contains $recycleBinPath)
        {
            Write-Verbose -Message $script:localizedData.RecycleBinEnabled
            $recycleBinEnabled = $true
        }
        else
        {
            Write-Verbose -Message $script:localizedData.RecycleBinNotEnabled
            $recycleBinEnabled = $false
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException], [Microsoft.ActiveDirectory.Management.ADServerDownException]
    {
        Write-Error -Message ($script:localizedData.ForestNotFound -f $ForestFQDN)
        throw $_
    }
    catch [System.Security.Authentication.AuthenticationException]
    {
        Write-Error -Message $script:localizedData.CredentialError
        throw $_
    }
    catch
    {
        Write-Error -Message ($script:localizedData.GetUnhandledException -f $ForestFQDN)
        throw $_
    }
    finally
    {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    return @{
        ForestFQDN        = $ForestFQDN
        RecycleBinEnabled = $recycleBinEnabled
        ForestMode        = $rootDSE.forestFunctionality.ToString()
    }
}

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ForestFQDN,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EnterpriseAdministratorCredential
    )

    $previousErrorActionPreference = $ErrorActionPreference

    try
    {
        # AD cmdlets generate non-terminating errors.
        $ErrorActionPreference = 'Stop'

        $forest = Get-ADForest -Identity $ForestFQDN -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential

        # Check minimum forest level and throw if not
        if (($forest.ForestMode -as [int]) -lt 4)
        {
            throw ($script:localizedData.ForestFunctionalLevelError -f $forest.ForestMode)
        }

        if ($PSCmdlet.ShouldProcess($forest.RootDomain, "Enable Active Directory Recycle Bin"))
        {
            Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet `
                -Target $forest.RootDomain -Server $forest.DomainNamingMaster `
                -Credential $EnterpriseAdministratorCredential `
                -Verbose
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException], [Microsoft.ActiveDirectory.Management.ADServerDownException]
    {
        Write-Error -Message ($script:localizedData.ForestNotFound -f $ForestFQDN)
        throw $_
    }
    catch [System.Security.Authentication.AuthenticationException]
    {
        Write-Error -Message $script:localizedData.CredentialError
        throw $_
    }
    catch
    {
        Write-Error -Message ($script:localizedData.SetUnhandledException -f $ForestFQDN)
        throw $_
    }
    finally
    {
        $ErrorActionPreference = $previousErrorActionPreference
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ForestFQDN,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EnterpriseAdministratorCredential
    )

    $previousErrorActionPreference = $ErrorActionPreference

    try
    {
        # AD cmdlets generate non-terminating errors.
        $ErrorActionPreference = 'Stop'

        $rootDSE = Get-ADRootDSE -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential
        $recycleBinPath = "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,$($rootDSE.configurationNamingContext)"
        $msDSEnabledFeature = Get-ADObject -Identity "CN=Partitions,$($rootDSE.configurationNamingContext)" -Property 'msDS-EnabledFeature' -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential |
            Select-Object -ExpandProperty 'msDS-EnabledFeature'

        if ($msDSEnabledFeature -contains $recycleBinPath)
        {
            Write-Verbose $script:localizedData.RecycleBinEnabled
            return $true
        }
        else
        {
            Write-Verbose $script:localizedData.RecycleBinNotEnabled
            return $false
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException], [Microsoft.ActiveDirectory.Management.ADServerDownException]
    {
        Write-Error -Message ($script:localizedData.ForestNotFound -f $ForestFQDN)
        throw $_
    }
    catch [System.Security.Authentication.AuthenticationException]
    {
        Write-Error -Message $script:localizedData.CredentialError
        throw $_
    }
    catch
    {
        Write-Error -Message ($script:localizedData.TestUnhandledException -f $ForestFQDN)
        throw $_
    }
    finally
    {
        $ErrorActionPreference = $previousErrorActionPreference
    }
}

Export-ModuleMember -Function *-TargetResource
