function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $FeatureName,

        [parameter(Mandatory = $true)]
        [System.String]
        $ForestFQDN,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EnterpriseAdministratorCredential
    )

    Try
    {
        # AD cmdlets generate non-terminating errors.
        $ErrorActionPreference = 'Stop'

        $Feature = Get-ADOptionalFeature -Filter {name -eq $FeatureName} -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential

        If ($Feature.EnabledScopes.Count -gt 0) {
            $FeatureEnabled = $True
        } Else {
            $FeatureEnabled = $False
        }
    }

    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException],[Microsoft.ActiveDirectory.Management.ADServerDownException] {
        Write-Error -Message "Cannot contact forest $ForestFQDN. Check the spelling of the Forest FQDN and make sure that a domain contoller is available on the network."
        Throw $_
    }
    Catch [System.Security.Authentication.AuthenticationException] {
        Write-Error -Message "Credential error. Check the username and password used."
        Throw $_
    }
    Catch {
        Write-Error -Message "Unhandled exception getting $FeatureName status for forest $ForestFQDN."
        Throw $_
    }

    Finally {
        $ErrorActionPreference = 'Continue'
    }

    $returnValue = @{
        ForestFQDN = $ForestFQDN
        FeatureName = $FeatureName
        Enabled = $FeatureEnabled
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $FeatureName,

        [parameter(Mandatory = $true)]
        [System.String]
        $ForestFQDN,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EnterpriseAdministratorCredential
    )


    Try
    {
        # AD cmdlets generate non-terminating errors.
        $ErrorActionPreference = 'Stop'

        $Feature = Get-ADOptionalFeature -Filter {name -eq $FeatureName} -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential

        $Forest = Get-ADForest -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential
        $Domain = Get-ADDomain -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential


        # Check minimum forest level and throw if not
        If (($Forest.ForestMode -as [int]) -lt ($Feature.RequiredForestMode -as [int])) {
            Write-Verbose -Message "Forest functionality level $($Forest.ForestMode) does not meet minimum requirement of $($Feature.RequiredForestMode) or greater."
            Throw "Forest functionality level $($Forest.ForestMode) does not meet minimum requirement of $($Feature.RequiredForestMode) or greater."
        }

        # Check minimum domain level and throw if not
        If (($Domain.DomainMode -as [int]) -lt ($Feature.RequiredDomainMode -as [int])) {
            Write-Verbose -Message "Forest functionality level $($Forest.ForestMode) does not meet minimum requirement of $($Feature.RequiredDomainMode) or greater."
            Throw "Domain functionality level $($Domain.DomainMode) does not meet minimum requirement of $($Feature.RequiredDomainMode) or greater."
        }

        If ($PSCmdlet.ShouldProcess($Forest.RootDomain, "Enable $FeatureName")) {
            Enable-ADOptionalFeature $FeatureName -Scope ForestOrConfigurationSet `
                -Target $Forest.RootDomain -Server $Forest.DomainNamingMaster `
                -Credential $EnterpriseAdministratorCredential `
                -Verbose
        }
    }

    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException],[Microsoft.ActiveDirectory.Management.ADServerDownException] {
        Write-Error -Message "Cannot contact forest $ForestFQDN. Check the spelling of the Forest FQDN and make sure that a domain contoller is available on the network."
        Throw $_
    }
    Catch [System.Security.Authentication.AuthenticationException] {
        Write-Error -Message "Credential error. Check the username and password used."
        Throw $_
    }
    Catch {
        Write-Error -Message "Unhandled exception setting $FeatureName status for forest $ForestFQDN."
        Throw $_
    }

    Finally {
        $ErrorActionPreference = 'Continue'
    }

}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $FeatureName,

        [parameter(Mandatory = $true)]
        [System.String]
        $ForestFQDN,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EnterpriseAdministratorCredential
    )

    Try {
        # AD cmdlets generate non-terminating errors.
        $ErrorActionPreference = 'Stop'

        $State = Get-TargetResource @PSBoundParameters

        If ($true -eq $State.Enabled) {
            Write-Verbose "$FeatureName is enabled."
            Return $True
        } Else {
            Write-Verbose "$FeatureName is not enabled."
            Return $False
        }
    }

    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException],[Microsoft.ActiveDirectory.Management.ADServerDownException] {
        Write-Error -Message "Cannot contact forest $ForestFQDN. Check the spelling of the Forest FQDN and make sure that a domain contoller is available on the network."
        Throw $_
    }
    Catch [System.Security.Authentication.AuthenticationException] {
        Write-Error -Message "Credential error. Check the username and password used."
        Throw $_
    }
    Catch {
        Write-Error -Message "Unhandled exception testing $FeatureName status for forest $ForestFQDN."
        Throw $_
    }

    Finally {
        $ErrorActionPreference = 'Continue'
    }


}


Export-ModuleMember -Function *-TargetResource

<#
Test syntax:

$cred = Get-Credential contoso\administrator

# Valid Domain
Get-TargetResource -FeatureName 'Privileged Access Management Feature' -ForestFQDN contoso.com -EnterpriseAdministratorCredential $cred
Test-TargetResource -FeatureName 'Privileged Access Management Feature' -ForestFQDN contoso.com -EnterpriseAdministratorCredential $cred
Set-TargetResource -FeatureName 'Privileged Access Management Feature' -ForestFQDN contoso.com -EnterpriseAdministratorCredential $cred -WhatIf

# Invalid Domain
Get-TargetResource -FeatureName 'Privileged Access Management Feature' -ForestFQDN contoso.cm -EnterpriseAdministratorCredential $cred
Test-TargetResource -FeatureName 'Privileged Access Management Feature' -ForestFQDN contoso.cm -EnterpriseAdministratorCredential $cred
Set-TargetResource -FeatureName 'Privileged Access Management Feature' -ForestFQDN contoso.cm -EnterpriseAdministratorCredential $cred -WhatIf
#>
