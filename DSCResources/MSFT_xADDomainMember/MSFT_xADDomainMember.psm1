function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ADAdmin,

        [parameter(Mandatory = $false)]
        [System.Boolean]
        $AllowReboot = $true
    )

    Write-Debug "Start cADDomainMember::Get-TargetResource"
    $isDomainMember = [System.Boolean] (Get-CimInstance -ClassName Win32_ComputerSystem -Verbose:$false).PartOfDomain;
    $actualDomain = [System.String] (Get-CimInstance -ClassName Win32_ComputerSystem -Verbose:$false).Domain;

    Write-Verbose "cADDomainMember::Get-TargetResource returning values DesiredDomain: $DomainName IsDomainMember: $isDomainMember DomainName: $actualDomain AllowReboot: $AllowReboot"

    $targetResource = @{
            DesiredDomain = $DomainName;
            IsDomainMember = $isDomainMember;
            DomainName = $actualDomain;
            AllowReboot = $AllowReboot;
    }

    Write-Debug "End cADDomainMember::Get-TargetResource"
    return $targetResource;
}
<#
    Get-TargetResource -DomainName mydomain.com -ADAdmin (Get-Credentials) -AllowReboot $false
    Expected Output: @{
        DesiredDomain: mydomain.com
        IsDomainMember: [$true|$false] - depends on if the script is run on a domain joined machine
        DomainName: [name of domain or workgroup this machine is a member of]
        AllowReboot: $false
    }
#>

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ADAdmin,

        [System.Boolean]
        $AllowReboot = $true
    )

    Write-Debug "Start cADDomainMember:Set-TargetResource"
    $targetResource = Get-TargetResource @PSBoundParameters;

    if($targetResource.isDomainMember -eq $false) {
        if($PSCmdlet.ShouldProcess($DomainName, "Join local machine to Domain")) {
            Write-Verbose "cADDomainMember:Set-TargetResource Machine is not a Domain Member, attempting to join domain $DomainName"
            #$domainJoinParams = @{
            #    DomainName = $DomainName;
            #    Credential = $ADAdmin;
            #    Restart = $AllowReboot;
            #}
            # Attempted to use the parameters above, however the Credential portion would not pass successfully.
            Add-Computer -DomainName $DomainName -Credential $ADAdmin -Restart:$AllowReboot
            Write-Debug "cADDomainMember:Set-TargetResource Add Computer was called to join the domain."
        }
        else {
            Write-Debug "cADDomainMember:Set-TargetResource ShouldProcess:$false Domain Join arguments DomainName: $DomainName Credential: {hidden} AllowReboot: $AllowReboot"
        }
    }
    else {
        Write-Verbose "cADDomainMember:Set-TargetResource Machine is already a domain member"
    }

    Write-Debug "End cADDomainMember:Set-TargetResource"

    #Include this line if the resource requires a system reboot.
    if($AllowReboot -eq $false){
        Write-Verbose "cADDomainMember:Set-TargetResource Setting DSC Machine Status to 1 to indicate it requires a reboot"
        $global:DSCMachineStatus = 1
    }
}
<#
    Set-TargetResource -DomainName mydomain.com -ADAdmin (Get-Credentials) -AllowReboot $true
    Expected Outcome: The computer will attempt to join the domain and once joined, it will reboot
#>


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ADAdmin,

        [System.Boolean]
        $AllowReboot = $true
    )

    Write-Debug "Start cADDomainMember:Test-TargetResource"

    $targetResources = Get-TargetResource @PSBoundParameters;
    $isDomainMember = $targetResources.isDomainMember;
    Write-Verbose "cADDomainMember:Test-TargetResource will return IsDomainMember $isDomainMember"

    Write-Debug "End cADDomainMember:Test-TargetResource"
    return $isDomainMember;
}
<#
    Test-TargetResource -DomainName mydomain.com -ADAdmin (Get-Credentials) -AllowReboot $true
    Expected Result:
        $true if the machine is a member of the provided domain
        $false if the machine is not domain joined
#>

Export-ModuleMember -Function *-TargetResource

