
<#
    .SYNOPSIS
        Returns the current state of the specified service principal name.

    .PARAMETER Ensure
        Specifies if the service principal name should be added or remove.

    .PARAMETER ServicePrincipalName
        The full SPN to add or remove, e.g. HOST/LON-DC1.

    .PARAMETER Account
        The user or computer account to add or remove the SPN, e.b. User1 or
        LON-DC1$.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServicePrincipalName
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
    else
    {
        # One or more SPN(s) found, return the account name(s)
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
        Specifies if the service principal name should be added or remove.

    .PARAMETER ServicePrincipalName
        The full SPN to add or remove, e.g. HOST/LON-DC1.

    .PARAMETER Account
        The user or computer account to add or remove the SPN, e.b. User1 or
        LON-DC1$.
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
        Specifies if the service principal name should be added or remove.

    .PARAMETER ServicePrincipalName
        The full SPN to add or remove, e.g. HOST/LON-DC1.

    .PARAMETER Account
        The user or computer account to add or remove the SPN, e.b. User1 or
        LON-DC1$.
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

    $currentConfiguration = Get-TargetResource @PSBoundParameters

    $desiredConfigurationMatch = $desiredConfigurationMatch -and
                                 $currentConfiguration.Ensure -eq $Ensure

    if ($Ensure -eq 'Present')
    {
        $desiredConfigurationMatch = $desiredConfigurationMatch -and
                                     $currentConfiguration.Account -eq $Account
    }

    return $desiredConfigurationMatch
}

Export-ModuleMember -function *-TargetResource
