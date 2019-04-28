$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'DscResource.LocalizationHelper'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'DscResource.LocalizationHelper.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xADDomainController'

## Import the common AD functions
$adCommonFunctions = Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath '\MSFT_xADCommon\MSFT_xADCommon.psm1'
Import-Module -Name $adCommonFunctions

<#
    .SYNOPSIS
        Returns the current state of the certificate that may need to be requested.

    .PARAMETER DomainName
        Provide the FQDN of the domain the Domain Controller is being added to.

    .PARAMETER DomainAdministrationCredential
        Provide the Domain Admin credentials to be able to promote a new Domain Controller. This is a PSCredential.

    .PARAMETER SafemodeAdministratorPassword
        Provide a password that will be used to set the DSRM password. This is a PSCredential.

    .PARAMETER DatabasePath
        Provide the path where the NTDS.dit will be created and stored.

    .PARAMETER LogPath
        Provide the path where the logs for the NTDS will be created and stored.

    .PARAMETER SysvolPath
        Provide the path where the Sysvol will be created and stored.

    .PARAMETER SiteName
        Provide the name of the site you want the Domain Controller to be added to.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorPassword,

        [Parameter()]
        [System.String]
        $DatabasePath,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.String]
        $SysvolPath,

        [Parameter()]
        [System.String]
        $SiteName
    )

    Assert-Module -ModuleName 'ActiveDirectory'

    $returnValue = @{
        DomainName           = $DomainName
        Ensure               = $false
        IsGlobalCatalog      = $false
    }

    Write-Verbose -Message (
        $script:localizedData.ResolveDomainName -f $DomainName
    )

    try
    {
        $domain = Get-ADDomain -Identity $DomainName -Credential $DomainAdministratorCredential
    }
    catch
    {
        $errorMessage = $script:localizedData.MissingDomain -f $DomainName
        New-ObjectNotFoundException -Message $errorMessage -ErrorRecord $_
    }

    Write-Verbose -Message (
        $script:localizedData.DomainPresent -f $DomainName
    )

    <#
        It is not possible to use `-ErrorAction 'SilentlyContinue` on the
        cmdlet Get-ADDomainController since it will throw an error if the
        node is not a domain controller regardless.
    #>
    try
    {
        $domainControllerObject = Get-ADDomainController -Identity $env:COMPUTERNAME -Credential $DomainAdministratorCredential
    }
    catch
    {
        <#
            Catches the error from Get-ADDomainController when the node
            is not a domain controller.

            Writing out the error message, in case there is another unforseen
            error.
        #>
        $domainControllerObject = $null

        Write-Verbose -Message (
            $script:localizedData.ConcludeNotDomainController -f $_.ToString()
        )
    }

    if ($domainControllerObject)
    {
        Write-Verbose -Message (
            $script:localizedData.FoundDomainController -f $domainControllerObject.Name, $domainControllerObject.Domain
        )

        if ($domainControllerObject.Domain -eq $DomainName)
        {
            Write-Verbose -Message (
                $script:localizedData.AlreadyDomainController -f $domainControllerObject.Name, $domainControllerObject.Domain
            )

            $serviceNTDS = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters'
            $serviceNETLOGON = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'

            $returnValue.Ensure = $true
            $returnValue.DatabasePath = $serviceNTDS.'DSA Working Directory'
            $returnValue.LogPath = $serviceNTDS.'Database log files path'
            $returnValue.SysvolPath = $serviceNETLOGON.SysVol -replace '\\sysvol$', ''
            $returnValue.SiteName = $domainControllerObject.Site
            $returnValue.IsGlobalCatalog = $domainControllerObject.IsGlobalCatalog
        }
    }
    else
    {
        Write-Verbose -Message (
            $script:localizedData.NotDomainController -f $env:COMPUTERNAME
        )
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Returns the current state of the certificate that may need to be requested.

    .PARAMETER DomainName
        Provide the FQDN of the domain the Domain Controller is being added to.

    .PARAMETER DomainAdministrationCredential
        Provide the Domain Admin credentials to be able to promote a new Domain Controller. This is a PSCredential.

    .PARAMETER SafemodeAdministratorPassword
        Provide a password that will be used to set the DSRM password. This is a PSCredential.

    .PARAMETER DatabasePath
        Provide the path where the NTDS.dit will be created and stored.

    .PARAMETER LogPath
        Provide the path where the logs for the NTDS will be created and stored.

    .PARAMETER SysvolPath
        Provide the path where the Sysvol will be created and stored.

    .PARAMETER SiteName
        Provide the name of the site you want the Domain Controller to be added to.

    .PARAMETER InstallationMediaPath
        Provide the path for the IFM folder that was created with ntdsutil.
        This should not be on a share but locally to the Domain Controller being promoted.

    .PARAMETER IsGlobalCatalog
        Specifies if the domain controller will be a Global Catalog (GC).
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorPassword,

        [Parameter()]
        [System.String]
        $DatabasePath,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.String]
        $SysvolPath,

        [Parameter()]
        [System.String]
        $SiteName,

        [Parameter()]
        [System.String]
        $InstallationMediaPath,

        [Parameter()]
        [System.Boolean]
        $IsGlobalCatalog
    )

    # Debug can pause Install-ADDSDomainController, so we remove it.
    $getTargetResourceParameters = @{} + $PSBoundParameters
    $getTargetResourceParameters.Remove('Debug')
    $getTargetResourceParameters.Remove('InstallationMediaPath')
    $getTargetResourceParameters.Remove('IsGlobalCatalog')
    $targetResource = Get-TargetResource @getTargetResourceParameters

    if ($targetResource.Ensure -eq $false)
    {
        Write-Verbose -Message (
            $script:localizedData.Promoting -f $env:COMPUTERNAME, $DomainName
        )

        # Node is not a domain controller so we promote it.
        $installADDSDomainControllerParameters = @{
            DomainName                    = $DomainName
            SafeModeAdministratorPassword = $SafemodeAdministratorPassword.Password
            Credential                    = $DomainAdministratorCredential
            NoRebootOnCompletion          = $true
            Force                         = $true
        }

        if ($PSBoundParameters.ContainsKey('DatabasePath'))
        {
            $installADDSDomainControllerParameters.Add('DatabasePath', $DatabasePath)
        }

        if ($PSBoundParameters.ContainsKey('LogPath'))
        {
            $installADDSDomainControllerParameters.Add('LogPath', $LogPath)
        }

        if ($PSBoundParameters.ContainsKey('SysvolPath'))
        {
            $installADDSDomainControllerParameters.Add('SysvolPath', $SysvolPath)
        }

        if ($PSBoundParameters.ContainsKey('SiteName') -and $SiteName)
        {
            $installADDSDomainControllerParameters.Add('SiteName', $SiteName)
        }

        if ($PSBoundParameters.ContainsKey('IsGlobalCatalog') -and $IsGlobalCatalog -eq $false)
        {
            $installADDSDomainControllerParameters.Add('NoGlobalCatalog', $true)
        }

        if (-not [string]::IsNullOrWhiteSpace($InstallationMediaPath))
        {
            $installADDSDomainControllerParameters.Add('InstallationMediaPath', $InstallationMediaPath)
        }

        Install-ADDSDomainController @installADDSDomainControllerParameters

        Write-Verbose -Message (
            $script:localizedData.Promoted -f $env:COMPUTERNAME, $DomainName
        )

        <#
            Signal to the LCM to reboot the node to compensate for the one we
            suppressed from Install-ADDSDomainController
        #>
        $global:DSCMachineStatus = 1
    }
    elseif ($targetResource.Ensure)
    {
        # Node is a domain controller. We check if other properties are in desired state

        Write-Verbose -Message (
            $script:localizedData.IsDomainController -f $env:COMPUTERNAME, $DomainName
        )

        # Check if Node Global Catalog state is correct
        if ($PSBoundParameters.ContainsKey('IsGlobalCatalog') -and $targetResource.IsGlobalCatalog -ne $IsGlobalCatalog)
        {
            # DC is not in the expected Global Catalog state
            if ($IsGlobalCatalog)
            {
                $value = 1

                Write-Verbose -Message $script:localizedData.AddGlobalCatalog
            }
            else
            {
                $value = 0

                Write-Verbose -Message $script:localizedData.RemoveGlobalCatalog
            }

            try
            {
                <#
                    It is not possible to use `-ErrorAction 'SilentlyContinue` on the
                    cmdlet Get-ADDomainController since it will throw an error if the
                    node is not a domain controller regardless.
                #>
                $domainControllerObject = Get-ADDomainController -Identity $env:COMPUTERNAME -Credential $DomainAdministratorCredential -ErrorAction 'Stop'
            }
            catch
            {
                $errorMessage = $script:localizedData.FailedEvaluatingDomainController
                New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
            }

            Set-ADObject -Identity $domainControllerObject.NTDSSettingsObjectDN -replace @{
                options = $value
            }
        }

        if ($PSBoundParameters.ContainsKey('SiteName') -and $targetResource.SiteName -ne $SiteName)
        {
            Write-Verbose -Message (
                $script:localizedData.IsDomainController -f $targetResource.SiteName, $SiteName
            )

            # DC is not in correct site. Move it.
            Move-ADDirectoryServer -Identity $env:COMPUTERNAME -Site $SiteName -Credential $DomainAdministratorCredential
        }
    }
}

<#
    .SYNOPSIS
        Returns the current state of the certificate that may need to be requested.

    .PARAMETER DomainName
        Provide the FQDN of the domain the Domain Controller is being added to.

    .PARAMETER DomainAdministrationCredential
        Provide the Domain Admin credentials to be able to promote a new Domain Controller. This is a PSCredential.

    .PARAMETER SafemodeAdministratorPassword
        Provide a password that will be used to set the DSRM password. This is a PSCredential.

    .PARAMETER DatabasePath
        Provide the path where the NTDS.dit will be created and stored.

    .PARAMETER LogPath
        Provide the path where the logs for the NTDS will be created and stored.

    .PARAMETER SysvolPath
        Provide the path where the Sysvol will be created and stored.

    .PARAMETER SiteName
        Provide the name of the site you want the Domain Controller to be added to.

    .PARAMETER InstallationMediaPath
        Provide the path for the IFM folder that was created with ntdsutil.
        This should not be on a share but locally to the Domain Controller being promoted.

    .PARAMETER IsGlobalCatalog
        Specifies if the domain controller will be a Global Catalog (GC).
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SafemodeAdministratorPassword,

        [Parameter()]
        [System.String]
        $DatabasePath,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.String]
        $SysvolPath,

        [Parameter()]
        [System.String]
        $SiteName,

        [Parameter()]
        [System.String]
        $InstallationMediaPath,

        [Parameter()]
        [System.Boolean]
        $IsGlobalCatalog
    )

    Write-Verbose -Message (
        $script:localizedData.TestingConfiguration -f $env:COMPUTERNAME, $DomainName
    )

    if ($PSBoundParameters.SiteName)
    {
        if (-not (Test-ADReplicationSite -SiteName $SiteName -DomainName $DomainName -Credential $DomainAdministratorCredential))
        {
            $errorMessage = $script:localizedData.FailedToFindSite -f $SiteName, $DomainName
            New-ObjectNotFoundException -Message $errorMessage
        }
    }

    $getTargetResourceParameters = @{} + $PSBoundParameters
    $getTargetResourceParameters.Remove('Debug')
    $getTargetResourceParameters.Remove('InstallationMediaPath')
    $getTargetResourceParameters.Remove('IsGlobalCatalog')
    $existingResource = Get-TargetResource @getTargetResourceParameters

    $isCompliant = $existingResource.Ensure

    if ($PSBoundParameters.ContainsKey('SiteName') -and $existingResource.SiteName -ne $SiteName)
    {
        Write-Verbose -Message (
            $script:localizedData.WrongSite -f $existingResource.SiteName, $SiteName
        )

        $isCompliant = $false
    }

    ## Check Global Catalog Config
    if ($PSBoundParameters.ContainsKey('IsGlobalCatalog') -and $existingResource.IsGlobalCatalog -ne $IsGlobalCatalog)
    {
        $isCompliant = $false
    }

    return $isCompliant
}

Export-ModuleMember -Function *-TargetResource
