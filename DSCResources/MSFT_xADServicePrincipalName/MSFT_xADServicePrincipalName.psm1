
<#
    .SYNOPSIS
    Returns the current state of the specified service principal name.

    .PARAMETER Ensure
    Specify if the SPN should be added or removed.

    .PARAMETER ServicePrincipalName
    Specify the full service principal name.

    .PARAMETER Account
    Specify the target account.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServicePrincipalName,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Account = ''
    )

    $spnAccounts = Get-ADObject -Filter { ServicePrincipalName -eq $ServicePrincipalName } -Properties 'SamAccountName' |
                       Select-Object -ExpandProperty 'SamAccountName'

    if ($spnAccounts.Count -eq 0)
    {
        # No SPN found
        $returnValue = @{
            Ensure               = 'Absent'
            ServicePrincipalName = $ServicePrincipalName
            Account              = ''
        }
    }
    elseif ($spnAccounts.Count -eq 1)
    {
        # Exactly one SPN found, return the account name
        $returnValue = @{
            Ensure               = 'Present'
            ServicePrincipalName = $ServicePrincipalName
            Account              = $spnAccounts
        }
    }
    else
    {
        # More then one SPN found, return 
        $returnValue = @{
            Ensure               = 'Present'
            ServicePrincipalName = $ServicePrincipalName
            Account              = $spnAccounts -join ';'
        }
    }

    return $returnValue
}

<#
    .SYNOPSIS
    Add or remove the service principal name.

    .PARAMETER Ensure
    Specify if the SPN should be added or removed.

    .PARAMETER ServicePrincipalName
    Specify the full service principal name.

    .PARAMETER Account
    Specify the target account.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServicePrincipalName,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Account = ''
    )

    $spnAccounts = Get-ADObject -Filter { ServicePrincipalName -eq $ServicePrincipalName } -Properties 'SamAccountName' |
                       Select-Object -ExpandProperty 'SamAccountName'

    if ($Ensure -eq 'Present')
    {
        if ([String]::IsNullOrEmpty($Account) -or ($null -eq (Get-ADObject -Filter { SamAccountName -eq $Account })))
        {
            throw "AD object with SamAccountName = '$Account' not found!"
        }

        foreach ($spnAccount in $spnAccounts)
        {
            if ($spnAccount -ne $Account)
            {
                Get-ADObject -Filter { SamAccountName -eq $spnAccount } |
                    Set-ADObject -Remove @{ ServicePrincipalName = $ServicePrincipalName }
            }
        }

        if ($spnAccounts -notcontains $Account)
        {
            Get-ADObject -Filter { SamAccountName -eq $Account } |
                Set-ADObject -Add @{ ServicePrincipalName = $ServicePrincipalName }
        }
    }

    if ($Ensure -eq 'Absent')
    {
        foreach ($spnAccount in $spnAccounts)
        {
            Get-ADObject -Filter { SamAccountName -eq $spnAccount } |
                Set-ADObject -Remove @{ ServicePrincipalName = $ServicePrincipalName }
        }
    }
}

<#
    .SYNOPSIS
    Tests the service principal name.

    .PARAMETER Ensure
    Specify if the SPN should be added or removed.

    .PARAMETER ServicePrincipalName
    Specify the full service principal name.

    .PARAMETER Account
    Specify the target account.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServicePrincipalName,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Account = ''
    )

    [System.Boolean] $desiredConfigurationMatch = $true

    $currentConfig = Get-TargetResource @PSBoundParameters

    $desiredConfigurationMatch = $desiredConfigurationMatch -and
                                 $currentConfig.Ensure -eq $Ensure

    if ($Ensure -eq 'Present')
    {
        $desiredConfigurationMatch = $desiredConfigurationMatch -and
                                     $currentConfig.Account -eq $Account
    }

    return $desiredConfigurationMatch
}

Export-ModuleMember -function *-TargetResource
