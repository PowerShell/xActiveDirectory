# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        AddingManagedServiceAccount           = Adding AD Managed Service Account '{0}'
        UpdatingManagedServiceAccount         = Updating AD Managed Service Account '{0}'
        RemovingManagedServiceAccount         = Removing AD Managed Service Account '{0}'
        MovingManagedServiceAccount           = Moving AD Managed Service Account '{0}' to '{1}'
        ManagedServiceAccountNotFound         = AD Managed Service Account '{0}' was not found
        NotDesiredPropertyState               = AD Managed Service Account '{0}' is not correct. Expected '{1}', actual '{2}'
        UpdatingManagedServiceAccountProperty = Updating AD Managed Service Account property '{0}' to '{1}'
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DisplayName,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    $adServiceAccountParams = Get-ADCommonParameters @PSBoundParameters

    try {
        $adServiceAccount = Get-ADServiceAccount @adServiceAccountParams -Property Name,DistinguishedName,Description,DisplayName,ManagedBy

        $targetResource = @{
            Name = $adServiceAccount.Name
            Path = Get-ADObjectParentDN -DN $adServiceAccount.DistinguishedName
            Description = $adServiceAccount.Description
            DisplayName = $adServiceAccount.DisplayName
            ManagedBy = $adServiceAccount.ManagedBy
            Ensure = 'Absent'
        }

        if ($adServiceAccount)
        {
            $targetResource['Ensure'] = 'Present';
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Verbose ($LocalizedData.ManagedServiceAccountNotFound -f $Name)
        $targetResource = @{
            Name = $Name
            Path = $Path
            Description = $Description
            DisplayName = $DisplayName
            ManagedBy = $ManagedBy
            Ensure = 'Absent'
        }
    }
    return $targetResource;
} #end function Get-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DisplayName,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        ## This must be the user's DN
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ManagedBy
    )

    $targetResource = Get-TargetResource @PSBoundParameters
    $targetResourceInCompliance = $true

    if ($Path -and ($targetResource.Path -ne $Path))
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'Path', $Path, $targetResource.Path)
        $targetResourceInCompliance = $false
    }

    if ($Description -and ($targetResource.Description -ne $Description))
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'Description', $Description, $targetResource.Description)
        $targetResourceInCompliance = $false
    }

    if ($DisplayName -and ($targetResource.DisplayName -ne $DisplayName))
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'DisplayName', $DisplayName, $targetResource.DisplayName)
        $targetResourceInCompliance = $false
    }

    if ($ManagedBy -and ($targetResource.ManagedBy -ne $ManagedBy))
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'ManagedBy', $ManagedBy, $targetResource.ManagedBy)
        $targetResourceInCompliance = $false
    }

    if ($targetResource.Ensure -ne $Ensure)
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'Ensure', $Ensure, $targetResource.Ensure)
        $targetResourceInCompliance = $false
    }

    return $targetResourceInCompliance
} #end function Test-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DisplayName,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        ## This must be the user's DN
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ManagedBy
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    $adServiceAccountParams = Get-ADCommonParameters @PSBoundParameters

    try {
        $adServiceAccount = Get-ADServiceAccount @adServiceAccountParams -Property Name,DistinguishedName,Description,DisplayName,ManagedBy

        if ($Ensure -eq 'Present') {
            $setADServiceAccountParams = $adServiceAccountParams.Clone()
            $setADServiceAccountParams['Identity'] = $adServiceAccount.DistinguishedName

            # Update existing group properties
            if ($Description -and ($Description -ne $adServiceAccount.Description))
            {
                Write-Verbose ($LocalizedData.UpdatingManagedServiceAccountProperty -f 'Description', $Description)
                $setADServiceAccountParams['Description'] = $Description
            }

            if ($DisplayName -and ($DisplayName -ne $adServiceAccount.DisplayName))
            {
                Write-Verbose ($LocalizedData.UpdatingManagedServiceAccountProperty -f 'DisplayName', $DisplayName)
                $setADServiceAccountParams['DisplayName'] = $DisplayName
            }

            if ($ManagedBy -and ($ManagedBy -ne $adServiceAccount.ManagedBy))
            {
                Write-Verbose ($LocalizedData.UpdatingManagedServiceAccountProperty -f 'ManagedBy', $ManagedBy)
                $setADServiceAccountParams['ManagedBy'] = $ManagedBy
            }

            Write-Verbose ($LocalizedData.UpdatingManagedServiceAccount -f $Name)
            Set-ADServiceAccount @setADServiceAccountParams

            # Move service account if the path is not correct
            if ($Path -and ($Path -ne (Get-ADObjectParentDN -DN $adServiceAccount.DistinguishedName))) {
                Write-Verbose ($LocalizedData.MovingManagedServiceAccount -f $Name, $Path)
                $moveADObjectParams = $adServiceAccountParams.Clone()
                $moveADObjectParams['Identity'] = $adServiceAccount.DistinguishedName
                Move-ADObject @moveADObjectParams -TargetPath $Path
            }
        }
        elseif ($Ensure -eq 'Absent')
        {
            # Remove existing service account
            Write-Verbose ($LocalizedData.RemovingManagedServiceAccount -f $Name)
            Remove-ADServiceAccount @adServiceAccountParams -Confirm:$false
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        ## The service account doesn't exist
        if ($Ensure -eq 'Present')
        {
            Write-Verbose ($LocalizedData.ManagedServiceAccountNotFound -f $Name)
            Write-Verbose ($LocalizedData.AddingManagedServiceAccount -f $Name)

            $adServiceAccountParams = Get-ADCommonParameters @PSBoundParameters -UseNameParameter

            if ($Description)
            {
                $adServiceAccountParams['Description'] = $Description
            }

            if ($DisplayName)
            {
                $adServiceAccountParams['DisplayName'] = $DisplayName
            }

            if ($ManagedBy)
            {
                $adServiceAccountParams['ManagedBy'] = $ManagedBy
            }

            if ($Path)
            {
                $adServiceAccountParams['Path'] = $Path
            }

            ## Create service account
            $adServiceAccount = New-ADServiceAccount @adServiceAccountParams -PassThru
        }
    } #end catch
} #end function Set-TargetResource

## Import the common AD functions
$adCommonFunctions = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath '\MSFT_xADCommon\MSFT_xADCommon.ps1'
. $adCommonFunctions

Export-ModuleMember -Function *-TargetResource