# This section suppresses rules PsScriptAnalyzer may catch in stub functions.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUserNameAndPassWordParams', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('MN-AnalyzerRules\Measure-CmdletBindingAttribute', '', Justification='ModuleStub')]
param ()

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Add-ADCentralAccessPolicyMember
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessPolicy]
        $Identity,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessRule[]]
        $Members,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Add-ADComputerServiceAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADComputer]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADServiceAccount[]]
        $ServiceAccount
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Add-ADDomainControllerPasswordReplicationPolicy
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'AllowedPRP')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $AllowedList,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'DeniedPRP')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $DeniedList,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADDomainController]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Add-ADFineGrainedPasswordPolicySubject
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADFineGrainedPasswordPolicy]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $Subjects
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Add-ADGroupMember
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADGroup]
        $Identity,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $Members,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Add-ADPrincipalGroupMembership
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $Identity,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADGroup[]]
        $MemberOf,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Add-ADResourcePropertyListMember
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADResourcePropertyList]
        $Identity,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADResourceProperty[]]
        $Members,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Clear-ADAccountExpiration
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Clear-ADClaimTransformLink
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADTrust]
        $Identity,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADClaimTransformPolicy]
        $Policy,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADTrustRole]
        $TrustRole
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Disable-ADAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Disable-ADOptionalFeature
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADOptionalFeature]
        $Identity,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADOptionalFeatureScope]
        $Scope,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADEntity]
        $Target
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Enable-ADAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Enable-ADOptionalFeature
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADOptionalFeature]
        $Identity,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADOptionalFeatureScope]
        $Scope,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADEntity]
        $Target
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADAccountAuthorizationGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADAccountResultantPasswordReplicationPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADDomainController]
        $DomainController,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADAuthenticationPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADAuthenticationPolicySilo
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADCentralAccessPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessPolicy]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADCentralAccessRule
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessRule]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADClaimTransformPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADClaimTransformPolicy]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADClaimType
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADClaimType]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADComputer
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADComputer]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [string]
        $SearchBase,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [Microsoft.ActiveDirectory.Management.ADSearchScope]
        $SearchScope,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADComputerServiceAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADComputer]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADDCCloningExcludedApplicationList
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Xml')]
        [switch]
        $Force,

        [Parameter(Mandatory = $true, ParameterSetName = 'Xml')]
        [switch]
        $GenerateXml,

        [Parameter(ParameterSetName = 'Xml')]
        [string]
        $Path
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADDefaultDomainPasswordPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Current')]
        [Microsoft.ActiveDirectory.Management.Commands.ADCurrentDomainType]
        $Current,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADDefaultDomainPasswordPolicy]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADDomain
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Current')]
        [Microsoft.ActiveDirectory.Management.Commands.ADCurrentDomainType]
        $Current,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADDomain]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADDomainController
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'DiscoverByService')]
        [switch]
        $AvoidSelf,

        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'Filter')]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'DiscoverByService')]
        [switch]
        $Discover,

        [Parameter(ParameterSetName = 'DiscoverByService')]
        [string]
        $DomainName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(ParameterSetName = 'DiscoverByService')]
        [switch]
        $ForceDiscover,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADDomainController]
        $Identity,

        [Parameter(ParameterSetName = 'DiscoverByService')]
        [Microsoft.ActiveDirectory.Management.Commands.ADMinimumDirectoryServiceVersion]
        $MinimumDirectoryServiceVersion,

        [Parameter(ParameterSetName = 'DiscoverByService')]
        [switch]
        $NextClosestSite,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'DiscoverByService')]
        [Microsoft.ActiveDirectory.Management.Commands.ADDiscoverableService[]]
        $Service,

        [Parameter(ParameterSetName = 'DiscoverByService')]
        [string]
        $SiteName,

        [Parameter(ParameterSetName = 'DiscoverByService')]
        [switch]
        $Writable
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADDomainControllerPasswordReplicationPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'AllowedPRP')]
        [switch]
        $Allowed,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'DeniedPRP')]
        [switch]
        $Denied,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADDomainController]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADDomainControllerPasswordReplicationPolicyUsage
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'AuthenticatedAccounts')]
        [switch]
        $AuthenticatedAccounts,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADDomainController]
        $Identity,

        [Parameter(ParameterSetName = 'RevealedAccounts')]
        [switch]
        $RevealedAccounts,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADFineGrainedPasswordPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADFineGrainedPasswordPolicy]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [string]
        $SearchBase,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [Microsoft.ActiveDirectory.Management.ADSearchScope]
        $SearchScope,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADFineGrainedPasswordPolicySubject
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADFineGrainedPasswordPolicy]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADForest
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Current')]
        [Microsoft.ActiveDirectory.Management.Commands.ADCurrentForestType]
        $Current,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADForest]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADGroup]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [string]
        $SearchBase,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [Microsoft.ActiveDirectory.Management.ADSearchScope]
        $SearchScope,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADGroupMember
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADGroup]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $Recursive,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADObject
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADObject]
        $Identity,

        [Parameter()]
        [switch]
        $IncludeDeletedObjects,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [string]
        $SearchBase,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [Microsoft.ActiveDirectory.Management.ADSearchScope]
        $SearchScope,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADOptionalFeature
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADOptionalFeature]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [string]
        $SearchBase,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [Microsoft.ActiveDirectory.Management.ADSearchScope]
        $SearchScope,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADOrganizationalUnit
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [string]
        $SearchBase,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [Microsoft.ActiveDirectory.Management.ADSearchScope]
        $SearchScope,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADPrincipalGroupMembership
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [string]
        $ResourceContextPartition,

        [Parameter()]
        [string]
        $ResourceContextServer,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADReplicationAttributeMetadata
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Filter,

        [Parameter()]
        [switch]
        $IncludeDeletedObjects,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADObject]
        $Object,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(Mandatory = $true)]
        [string]
        $Server,

        [Parameter()]
        [switch]
        $ShowAllLinkedValues
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADReplicationConnection
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationConnection]
        $Identity,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADReplicationFailure
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $EnumeratingServer,

        [Parameter()]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Scope')]
        [Microsoft.ActiveDirectory.Management.Commands.ADScopeType]
        $Scope,

        [Parameter(Mandatory = $true, ParameterSetName = 'Target')]
        [Parameter(ParameterSetName = 'Scope')]
        [System.Object[]]
        $Target
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADReplicationPartnerMetadata
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $EnumerationServer,

        [Parameter()]
        [string]
        $Filter,

        [Parameter()]
        [string[]]
        $Partition,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.Commands.ADPartnerType]
        $PartnerType,

        [Parameter(Mandatory = $true, ParameterSetName = 'Scope')]
        [Microsoft.ActiveDirectory.Management.Commands.ADScopeType]
        $Scope,

        [Parameter(Mandatory = $true, ParameterSetName = 'Target')]
        [Parameter(ParameterSetName = 'Scope')]
        [System.Object[]]
        $Target
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADReplicationQueueOperation
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [string]
        $Server,

        [Parameter()]
        [string]
        $Filter,

        [Parameter()]
        [string[]]
        $Partition
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADReplicationSite
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSite]
        $Identity,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADReplicationSiteLink
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSiteLink]
        $Identity,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADReplicationSiteLinkBridge
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSiteLinkBridge]
        $Identity,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADReplicationSubnet
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSubnet]
        $Identity,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADReplicationUpToDatenessVectorTable
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $EnumerationServer,

        [Parameter()]
        [string]
        $Filter,

        [Parameter()]
        [string[]]
        $Partition,

        [Parameter(Mandatory = $true, ParameterSetName = 'Scope')]
        [Microsoft.ActiveDirectory.Management.Commands.ADScopeType]
        $Scope,

        [Parameter(ParameterSetName = 'Scope')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Target')]
        [System.Object[]]
        $Target
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADResourceProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADResourceProperty]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADResourcePropertyList
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADResourcePropertyList]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADResourcePropertyValueType
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADResourcePropertyValueType]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADRootDSE
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADServiceAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADServiceAccount]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [string]
        $SearchBase,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [Microsoft.ActiveDirectory.Management.ADSearchScope]
        $SearchScope,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADTrust
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADTrust]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'InputObject')]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADUser
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'LdapFilter')]
        [string]
        $LDAPFilter,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [int]
        $ResultPageSize,

        [Parameter(ParameterSetName = 'LdapFilter')]
        [Parameter(ParameterSetName = 'Filter')]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [string]
        $SearchBase,

        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'LdapFilter')]
        [Microsoft.ActiveDirectory.Management.ADSearchScope]
        $SearchScope,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-ADUserResultantPasswordPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Grant-ADAuthenticationPolicySiloAccess
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Account,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $Identity,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Install-ADServiceAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [securestring]
        $AccountPassword,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [switch]
        $Force,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADServiceAccount]
        $Identity,

        [Parameter()]
        [switch]
        $PromptForPassword
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Move-ADDirectoryServer
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADDirectoryServer]
        $Identity,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADReplicationSite]
        $Site
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Move-ADDirectoryServerOperationMasterRole
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [PSObject]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [switch]
        $Force,

        [Parameter(Mandatory = $true)]
        [PSObject]
        $Identity,

        [Parameter(Mandatory = $true)]
        [PSObject[]]
        $OperationMasterRole,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Move-ADObject
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADObject]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [string]
        $TargetPath,

        [Parameter()]
        [string]
        $TargetServer
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADAuthenticationPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [string]
        $ComputerAllowedToAuthenticateTo,

        [Parameter()]
        [System.Nullable[int]]
        $ComputerTGTLifetimeMins,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [switch]
        $Enforce,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $Instance,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [hashtable]
        $OtherAttributes,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [string]
        $ServiceAllowedToAuthenticateFrom,

        [Parameter()]
        [string]
        $ServiceAllowedToAuthenticateTo,

        [Parameter()]
        [System.Nullable[int]]
        $ServiceTGTLifetimeMins,

        [Parameter()]
        [string]
        $UserAllowedToAuthenticateFrom,

        [Parameter()]
        [string]
        $UserAllowedToAuthenticateTo,

        [Parameter()]
        [System.Nullable[int]]
        $UserTGTLifetimeMins
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADAuthenticationPolicySilo
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $ComputerAuthenticationPolicy,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [switch]
        $Enforce,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $Instance,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [hashtable]
        $OtherAttributes,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $ServiceAuthenticationPolicy,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $UserAuthenticationPolicy
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADCentralAccessPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessPolicy]
        $Instance,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADCentralAccessRule
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $CurrentAcl,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessRule]
        $Instance,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $ProposedAcl,

        [Parameter()]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter()]
        [string]
        $ResourceCondition,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADClaimTransformPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'AllowAll')]
        [switch]
        $AllowAll,

        [Parameter(Mandatory = $true, ParameterSetName = 'AllowAllExcept')]
        [Microsoft.ActiveDirectory.Management.ADClaimType[]]
        $AllowAllExcept,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'DenyAll')]
        [switch]
        $DenyAll,

        [Parameter(Mandatory = $true, ParameterSetName = 'DenyAllExcept')]
        [Microsoft.ActiveDirectory.Management.ADClaimType[]]
        $DenyAllExcept,

        [Parameter()]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADClaimTransformPolicy]
        $Instance,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [string]
        $Rule,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADClaimType
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string[]]
        $AppliesToClasses,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter(Mandatory = $true)]
        [string]
        $DisplayName,

        [Parameter()]
        [bool]
        $Enabled,

        [Parameter()]
        [string]
        $ID,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADClaimType]
        $Instance,

        [Parameter()]
        [bool]
        $IsSingleValued,

        [Parameter()]
        [hashtable]
        $OtherAttributes,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter()]
        [bool]
        $RestrictValues,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = 'SourceAttribute')]
        [string]
        $SourceAttribute,

        [Parameter(Mandatory = $true, ParameterSetName = 'SourceOID')]
        [string]
        $SourceOID,

        [Parameter(Mandatory = $true, ParameterSetName = 'SourceTransformPolicy')]
        [switch]
        $SourceTransformPolicy,

        [Parameter(ParameterSetName = 'SourceAttribute')]
        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [Microsoft.ActiveDirectory.Management.ADSuggestedValueEntry[]]
        $SuggestedValues,

        [Parameter(Mandatory = $true, ParameterSetName = 'SourceTransformPolicy')]
        [Microsoft.ActiveDirectory.Management.ADClaimValueType]
        $ValueType
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADComputer
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Nullable[datetime]]
        $AccountExpirationDate,

        [Parameter()]
        [System.Nullable[bool]]
        $AccountNotDelegated,

        [Parameter()]
        [securestring]
        $AccountPassword,

        [Parameter()]
        [System.Nullable[bool]]
        $AllowReversiblePasswordEncryption,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $AuthenticationPolicy,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $AuthenticationPolicySilo,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [System.Nullable[bool]]
        $CannotChangePassword,

        [Parameter()]
        [X509Certificate[]]
        $Certificates,

        [Parameter()]
        [System.Nullable[bool]]
        $ChangePasswordAtLogon,

        [Parameter()]
        [System.Nullable[bool]]
        $CompoundIdentitySupported,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string]
        $DisplayName,

        [Parameter()]
        [string]
        $DNSHostName,

        [Parameter()]
        [System.Nullable[bool]]
        $Enabled,

        [Parameter()]
        [string]
        $HomePage,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADComputer]
        $Instance,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADKerberosEncryptionType]
        $KerberosEncryptionType,

        [Parameter()]
        [string]
        $Location,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $ManagedBy,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [string]
        $OperatingSystem,

        [Parameter()]
        [string]
        $OperatingSystemHotfix,

        [Parameter()]
        [string]
        $OperatingSystemServicePack,

        [Parameter()]
        [string]
        $OperatingSystemVersion,

        [Parameter()]
        [hashtable]
        $OtherAttributes,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [System.Nullable[bool]]
        $PasswordNeverExpires,

        [Parameter()]
        [System.Nullable[bool]]
        $PasswordNotRequired,

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $PrincipalsAllowedToDelegateToAccount,

        [Parameter()]
        [string]
        $SAMAccountName,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [string[]]
        $ServicePrincipalNames,

        [Parameter()]
        [System.Nullable[bool]]
        $TrustedForDelegation,

        [Parameter()]
        [string]
        $UserPrincipalName
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADDCCloneConfigFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'IPv4StaticSettings')]
        [Parameter(ParameterSetName = 'OfflineExecution')]
        [string]
        $AlternateWINSServer,

        [Parameter()]
        [string]
        $CloneComputerName,

        [Parameter(Mandatory = $true, ParameterSetName = 'IPv4StaticSettings')]
        [Parameter(ParameterSetName = 'OfflineExecution')]
        [string]
        $IPv4Address,

        [Parameter(ParameterSetName = 'OfflineExecution')]
        [Parameter(ParameterSetName = 'IPv4StaticSettings')]
        [string]
        $IPv4DefaultGateway,

        [Parameter(ParameterSetName = 'OfflineExecution')]
        [Parameter(ParameterSetName = 'IPv4DynamicSettings')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IPv4StaticSettings')]
        [string[]]
        $IPv4DNSResolver,

        [Parameter(Mandatory = $true, ParameterSetName = 'IPv4StaticSettings')]
        [Parameter(ParameterSetName = 'OfflineExecution')]
        [string]
        $IPv4SubnetMask,

        [Parameter(ParameterSetName = 'OfflineExecution')]
        [Parameter(ParameterSetName = 'IPv6DynamicSettings')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IPv6StaticSettings')]
        [string[]]
        $IPv6DNSResolver,

        [Parameter(Mandatory = $true, ParameterSetName = 'OfflineExecution')]
        [switch]
        $Offline,

        [Parameter(ParameterSetName = 'IPv6DynamicSettings')]
        [Parameter(Mandatory = $true, ParameterSetName = 'OfflineExecution')]
        [Parameter(ParameterSetName = 'IPv4DynamicSettings')]
        [Parameter(ParameterSetName = 'IPv4StaticSettings')]
        [Parameter(ParameterSetName = 'IPv6StaticSettings')]
        [string]
        $Path,

        [Parameter(ParameterSetName = 'IPv4StaticSettings')]
        [Parameter(ParameterSetName = 'OfflineExecution')]
        [string]
        $PreferredWINSServer,

        [Parameter()]
        [string]
        $SiteName,

        [Parameter(ParameterSetName = 'OfflineExecution')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IPv6StaticSettings')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IPv4StaticSettings')]
        [switch]
        $Static
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADFineGrainedPasswordPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [System.Nullable[bool]]
        $ComplexityEnabled,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string]
        $DisplayName,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADFineGrainedPasswordPolicy]
        $Instance,

        [Parameter()]
        [System.Nullable[timespan]]
        $LockoutDuration,

        [Parameter()]
        [System.Nullable[timespan]]
        $LockoutObservationWindow,

        [Parameter()]
        [System.Nullable[int]]
        $LockoutThreshold,

        [Parameter()]
        [System.Nullable[timespan]]
        $MaxPasswordAge,

        [Parameter()]
        [System.Nullable[timespan]]
        $MinPasswordAge,

        [Parameter()]
        [System.Nullable[int]]
        $MinPasswordLength,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [hashtable]
        $OtherAttributes,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [System.Nullable[int]]
        $PasswordHistoryCount,

        [Parameter(Mandatory = $true)]
        [System.Nullable[int]]
        $Precedence,

        [Parameter()]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter()]
        [System.Nullable[bool]]
        $ReversibleEncryptionEnabled,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string]
        $DisplayName,

        [Parameter()]
        [System.Nullable[Microsoft.ActiveDirectory.Management.ADGroupCategory]]
        $GroupCategory,

        [Parameter(Mandatory = $true)]
        [System.Nullable[Microsoft.ActiveDirectory.Management.ADGroupScope]]
        $GroupScope,

        [Parameter()]
        [string]
        $HomePage,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADGroup]
        $Instance,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $ManagedBy,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [hashtable]
        $OtherAttributes,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [string]
        $SamAccountName,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADObject
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string]
        $DisplayName,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADObject]
        $Instance,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [hashtable]
        $OtherAttributes,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [string]
        $Type
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADOrganizationalUnit
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [string]
        $City,

        [Parameter()]
        [string]
        $Country,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string]
        $DisplayName,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit]
        $Instance,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $ManagedBy,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [hashtable]
        $OtherAttributes,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [string]
        $PostalCode,

        [Parameter()]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [string]
        $State,

        [Parameter()]
        [string]
        $StreetAddress
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADReplicationSite
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $AutomaticInterSiteTopologyGenerationEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $AutomaticTopologyGenerationEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSite]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADDirectoryServer]
        $InterSiteTopologyGenerator,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $ManagedBy,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $OtherAttributes,

        [Parameter(ParameterSetName = 'Identity')]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $RedundantServerTopologyEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.DirectoryServices.ActiveDirectory.ActiveDirectorySchedule]
        $ReplicationSchedule,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ScheduleHashingEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $TopologyCleanupEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $TopologyDetectStaleEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $TopologyMinimumHopsEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $UniversalGroupCachingEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSite]
        $UniversalGroupCachingRefreshSite,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $WindowsServer2000BridgeheadSelectionMethodEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $WindowsServer2000KCCISTGSelectionBehaviorEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $WindowsServer2003KCCBehaviorEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $WindowsServer2003KCCIgnoreScheduleEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $WindowsServer2003KCCSiteLinkBridgingEnabled
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADReplicationSiteLink
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[int]]
        $Cost,

        [Parameter(ParameterSetName = 'Identity')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSiteLink]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[Microsoft.ActiveDirectory.Management.ADInterSiteTransportProtocolType]]
        $InterSiteTransportProtocol,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $OtherAttributes,

        [Parameter(ParameterSetName = 'Identity')]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[int]]
        $ReplicationFrequencyInMinutes,

        [Parameter(ParameterSetName = 'Identity')]
        [System.DirectoryServices.ActiveDirectory.ActiveDirectorySchedule]
        $ReplicationSchedule,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSite[]]
        $SitesIncluded
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADReplicationSiteLinkBridge
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSiteLinkBridge]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[Microsoft.ActiveDirectory.Management.ADInterSiteTransportProtocolType]]
        $InterSiteTransportProtocol,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $OtherAttributes,

        [Parameter(ParameterSetName = 'Identity')]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSiteLink[]]
        $SiteLinksIncluded
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADReplicationSubnet
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSubnet]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Location,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $OtherAttributes,

        [Parameter(ParameterSetName = 'Identity')]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSite]
        $Site
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADResourceProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string[]]
        $AppliesToResourceTypes,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter(Mandatory = $true)]
        [string]
        $DisplayName,

        [Parameter()]
        [bool]
        $Enabled,

        [Parameter()]
        [string]
        $ID,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADResourceProperty]
        $Instance,

        [Parameter()]
        [bool]
        $IsSecured,

        [Parameter()]
        [hashtable]
        $OtherAttributes,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADResourcePropertyValueType]
        $ResourcePropertyValueType,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADClaimType]
        $SharesValuesWith,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADSuggestedValueEntry[]]
        $SuggestedValues
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADResourcePropertyList
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADResourcePropertyList]
        $Instance,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADServiceAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Nullable[datetime]]
        $AccountExpirationDate,

        [Parameter()]
        [System.Nullable[bool]]
        $AccountNotDelegated,

        [Parameter(ParameterSetName = 'RestrictedToSingleComputer')]
        [securestring]
        $AccountPassword,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $AuthenticationPolicy,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $AuthenticationPolicySilo,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [string[]]
        $Certificates,

        [Parameter(ParameterSetName = 'Group')]
        [System.Nullable[bool]]
        $CompoundIdentitySupported,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string]
        $DisplayName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Group')]
        [string]
        $DNSHostName,

        [Parameter()]
        [System.Nullable[bool]]
        $Enabled,

        [Parameter()]
        [string]
        $HomePage,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADServiceAccount]
        $Instance,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADKerberosEncryptionType]
        $KerberosEncryptionType,

        [Parameter(ParameterSetName = 'Group')]
        [System.Nullable[int]]
        $ManagedPasswordIntervalInDays,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [hashtable]
        $OtherAttributes,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Path,

        [Parameter(ParameterSetName = 'Group')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $PrincipalsAllowedToDelegateToAccount,

        [Parameter(ParameterSetName = 'Group')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $PrincipalsAllowedToRetrieveManagedPassword,

        [Parameter(Mandatory = $true, ParameterSetName = 'RestrictedToOutboundAuthenticationOnly')]
        [switch]
        $RestrictToOutboundAuthenticationOnly,

        [Parameter(Mandatory = $true, ParameterSetName = 'RestrictedToSingleComputer')]
        [switch]
        $RestrictToSingleComputer,

        [Parameter()]
        [string]
        $SamAccountName,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [string[]]
        $ServicePrincipalNames,

        [Parameter()]
        [System.Nullable[bool]]
        $TrustedForDelegation
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function New-ADUser
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Nullable[datetime]]
        $AccountExpirationDate,

        [Parameter()]
        [System.Nullable[bool]]
        $AccountNotDelegated,

        [Parameter()]
        [securestring]
        $AccountPassword,

        [Parameter()]
        [System.Nullable[bool]]
        $AllowReversiblePasswordEncryption,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $AuthenticationPolicy,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $AuthenticationPolicySilo,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [System.Nullable[bool]]
        $CannotChangePassword,

        [Parameter()]
        [X509Certificate[]]
        $Certificates,

        [Parameter()]
        [System.Nullable[bool]]
        $ChangePasswordAtLogon,

        [Parameter()]
        [string]
        $City,

        [Parameter()]
        [string]
        $Company,

        [Parameter()]
        [System.Nullable[bool]]
        $CompoundIdentitySupported,

        [Parameter()]
        [string]
        $Country,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Department,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string]
        $DisplayName,

        [Parameter()]
        [string]
        $Division,

        [Parameter()]
        [string]
        $EmailAddress,

        [Parameter()]
        [string]
        $EmployeeID,

        [Parameter()]
        [string]
        $EmployeeNumber,

        [Parameter()]
        [System.Nullable[bool]]
        $Enabled,

        [Parameter()]
        [string]
        $Fax,

        [Parameter()]
        [string]
        $GivenName,

        [Parameter()]
        [string]
        $HomeDirectory,

        [Parameter()]
        [string]
        $HomeDrive,

        [Parameter()]
        [string]
        $HomePage,

        [Parameter()]
        [string]
        $HomePhone,

        [Parameter()]
        [string]
        $Initials,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $Instance,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADKerberosEncryptionType]
        $KerberosEncryptionType,

        [Parameter()]
        [string]
        $LogonWorkstations,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $Manager,

        [Parameter()]
        [string]
        $MobilePhone,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Office,

        [Parameter()]
        [string]
        $OfficePhone,

        [Parameter()]
        [string]
        $Organization,

        [Parameter()]
        [hashtable]
        $OtherAttributes,

        [Parameter()]
        [string]
        $OtherName,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [System.Nullable[bool]]
        $PasswordNeverExpires,

        [Parameter()]
        [System.Nullable[bool]]
        $PasswordNotRequired,

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [string]
        $POBox,

        [Parameter()]
        [string]
        $PostalCode,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $PrincipalsAllowedToDelegateToAccount,

        [Parameter()]
        [string]
        $ProfilePath,

        [Parameter()]
        [string]
        $SamAccountName,

        [Parameter()]
        [string]
        $ScriptPath,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [string[]]
        $ServicePrincipalNames,

        [Parameter()]
        [System.Nullable[bool]]
        $SmartcardLogonRequired,

        [Parameter()]
        [string]
        $State,

        [Parameter()]
        [string]
        $StreetAddress,

        [Parameter()]
        [string]
        $Surname,

        [Parameter()]
        [string]
        $Title,

        [Parameter()]
        [System.Nullable[bool]]
        $TrustedForDelegation,

        [Parameter()]
        [string]
        $Type,

        [Parameter()]
        [string]
        $UserPrincipalName
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADAuthenticationPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADAuthenticationPolicySilo
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADCentralAccessPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessPolicy]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADCentralAccessPolicyMember
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessPolicy]
        $Identity,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessRule[]]
        $Members,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADCentralAccessRule
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessRule]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADClaimTransformPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADClaimTransformPolicy]
        $Identity,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADClaimType
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [switch]
        $Force,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADClaimType]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADComputer
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADComputer]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [boolean]
        $Confirm
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADComputerServiceAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADComputer]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADServiceAccount[]]
        $ServiceAccount
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADDomainControllerPasswordReplicationPolicy
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'AllowedPRP')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $AllowedList,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'DeniedPRP')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $DeniedList,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADDomainController]
        $Identity,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADFineGrainedPasswordPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADFineGrainedPasswordPolicy]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADFineGrainedPasswordPolicySubject
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADFineGrainedPasswordPolicy]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $Subjects
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADGroup]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADGroupMember
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADGroup]
        $Identity,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $Members,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADObject
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADObject]
        $Identity,

        [Parameter()]
        [switch]
        $IncludeDeletedObjects,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $Recursive,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADOrganizationalUnit
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $Recursive,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADPrincipalGroupMembership
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $Identity,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADGroup[]]
        $MemberOf,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADReplicationSite
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSite]
        $Identity,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADReplicationSiteLink
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSiteLink]
        $Identity,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADReplicationSiteLinkBridge
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSiteLinkBridge]
        $Identity,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADReplicationSubnet
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSubnet]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADResourceProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADResourceProperty]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADResourcePropertyList
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADResourcePropertyList]
        $Identity,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADResourcePropertyListMember
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADResourcePropertyList]
        $Identity,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADResourceProperty[]]
        $Members,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADServiceAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADServiceAccount]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-ADUser
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Rename-ADObject
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADObject]
        $Identity,

        [Parameter(Mandatory = $true)]
        [string]
        $NewName,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Reset-ADServiceAccountPassword
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADServiceAccount]
        $Identity,

        [Parameter()]
        [string]
        $Partition
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Restore-ADObject
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADObject]
        $Identity,

        [Parameter()]
        [string]
        $NewName,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [string]
        $TargetPath
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Revoke-ADAuthenticationPolicySiloAccess
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Account,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $Identity,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Search-ADAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'AccountDisabled')]
        [switch]
        $AccountDisabled,

        [Parameter(Mandatory = $true, ParameterSetName = 'AccountExpired')]
        [switch]
        $AccountExpired,

        [Parameter(Mandatory = $true, ParameterSetName = 'AccountExpiring')]
        [switch]
        $AccountExpiring,

        [Parameter(Mandatory = $true, ParameterSetName = 'AccountInactive')]
        [switch]
        $AccountInactive,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [switch]
        $ComputersOnly,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'AccountExpiring')]
        [Parameter(ParameterSetName = 'AccountInactive')]
        [datetime]
        $DateTime,

        [Parameter(Mandatory = $true, ParameterSetName = 'LockedOut')]
        [switch]
        $LockedOut,

        [Parameter(Mandatory = $true, ParameterSetName = 'PasswordExpired')]
        [switch]
        $PasswordExpired,

        [Parameter(Mandatory = $true, ParameterSetName = 'PasswordNeverExpires')]
        [switch]
        $PasswordNeverExpires,

        [Parameter()]
        [int]
        $ResultPageSize,

        [Parameter()]
        [System.Nullable[int]]
        $ResultSetSize,

        [Parameter()]
        [string]
        $SearchBase,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADSearchScope]
        $SearchScope,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'AccountExpiring')]
        [Parameter(ParameterSetName = 'AccountInactive')]
        [timespan]
        $TimeSpan,

        [Parameter()]
        [switch]
        $UsersOnly
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADAccountAuthenticationPolicySilo
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $AuthenticationPolicy,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $AuthenticationPolicySilo,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Identity,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADAccountControl
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [bool]
        $AccountNotDelegated,

        [Parameter()]
        [bool]
        $AllowReversiblePasswordEncryption,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [bool]
        $CannotChangePassword,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [bool]
        $DoesNotRequirePreAuth,

        [Parameter()]
        [bool]
        $Enabled,

        [Parameter()]
        [bool]
        $HomedirRequired,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Identity,

        [Parameter()]
        [bool]
        $MNSLogonAccount,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [bool]
        $PasswordNeverExpires,

        [Parameter()]
        [bool]
        $PasswordNotRequired,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [bool]
        $TrustedForDelegation,

        [Parameter()]
        [bool]
        $TrustedToAuthForDelegation,

        [Parameter()]
        [bool]
        $UseDESKeyOnly
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADAccountExpiration
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [System.Nullable[datetime]]
        $DateTime,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [timespan]
        $TimeSpan
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADAccountPassword
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Identity,

        [Parameter()]
        [securestring]
        $NewPassword,

        [Parameter()]
        [securestring]
        $OldPassword,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [switch]
        $Reset,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADAuthenticationPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $ComputerAllowedToAuthenticateTo,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[int]]
        $ComputerTGTLifetimeMins,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [bool]
        $Enforce,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $Instance,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $ServiceAllowedToAuthenticateFrom,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $ServiceAllowedToAuthenticateTo,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[int]]
        $ServiceTGTLifetimeMins,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $UserAllowedToAuthenticateFrom,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $UserAllowedToAuthenticateTo,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[int]]
        $UserTGTLifetimeMins
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADAuthenticationPolicySilo
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $ComputerAuthenticationPolicy,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [bool]
        $Enforce,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $Instance,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $ServiceAuthenticationPolicy,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $UserAuthenticationPolicy
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADCentralAccessPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessPolicy]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessPolicy]
        $Instance,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADCentralAccessRule
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $CurrentAcl,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessRule]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADCentralAccessRule]
        $Instance,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $ProposedAcl,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $ResourceCondition,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADClaimTransformLink
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADTrust]
        $Identity,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADClaimTransformPolicy]
        $Policy,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADTrustRole]
        $TrustRole
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADClaimTransformPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'AllowAllExcept')]
        [Parameter(ParameterSetName = 'AllowAll')]
        [Parameter(ParameterSetName = 'DenyAll')]
        [Parameter(ParameterSetName = 'DenyAllExcept')]
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter(Mandatory = $true, ParameterSetName = 'AllowAll')]
        [switch]
        $AllowAll,

        [Parameter(Mandatory = $true, ParameterSetName = 'AllowAllExcept')]
        [Microsoft.ActiveDirectory.Management.ADClaimType[]]
        $AllowAllExcept,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'AllowAll')]
        [Parameter(ParameterSetName = 'DenyAll')]
        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'AllowAllExcept')]
        [Parameter(ParameterSetName = 'DenyAllExcept')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'DenyAll')]
        [switch]
        $DenyAll,

        [Parameter(Mandatory = $true, ParameterSetName = 'DenyAllExcept')]
        [Microsoft.ActiveDirectory.Management.ADClaimType[]]
        $DenyAllExcept,

        [Parameter(ParameterSetName = 'AllowAll')]
        [Parameter(ParameterSetName = 'DenyAll')]
        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'DenyAllExcept')]
        [Parameter(ParameterSetName = 'AllowAllExcept')]
        [string]
        $Description,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Parameter(Mandatory = $true, ParameterSetName = 'AllowAll')]
        [Parameter(Mandatory = $true, ParameterSetName = 'AllowAllExcept')]
        [Parameter(Mandatory = $true, ParameterSetName = 'DenyAll')]
        [Parameter(Mandatory = $true, ParameterSetName = 'DenyAllExcept')]
        [Microsoft.ActiveDirectory.Management.ADClaimTransformPolicy]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADClaimTransformPolicy]
        $Instance,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'DenyAllExcept')]
        [Parameter(ParameterSetName = 'AllowAllExcept')]
        [Parameter(ParameterSetName = 'DenyAll')]
        [Parameter(ParameterSetName = 'AllowAll')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'AllowAll')]
        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'AllowAllExcept')]
        [Parameter(ParameterSetName = 'DenyAll')]
        [Parameter(ParameterSetName = 'DenyAllExcept')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'DenyAllExcept')]
        [Parameter(ParameterSetName = 'AllowAll')]
        [Parameter(ParameterSetName = 'AllowAllExcept')]
        [Parameter(ParameterSetName = 'DenyAll')]
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Rule,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADClaimType
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'SourceAttribute')]
        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'SourceOID')]
        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [hashtable]
        $Add,

        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [Parameter(ParameterSetName = 'SourceOID')]
        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'SourceAttribute')]
        [string[]]
        $AppliesToClasses,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'SourceOID')]
        [Parameter(ParameterSetName = 'SourceAttribute')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [Parameter(ParameterSetName = 'SourceOID')]
        [Parameter(ParameterSetName = 'SourceAttribute')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'SourceOID')]
        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'SourceAttribute')]
        [string]
        $DisplayName,

        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [Parameter(ParameterSetName = 'SourceOID')]
        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'SourceAttribute')]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SourceTransformPolicy')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SourceAttribute')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SourceOID')]
        [Microsoft.ActiveDirectory.Management.ADClaimType]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADClaimType]
        $Instance,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'SourceOID')]
        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [Parameter(ParameterSetName = 'SourceAttribute')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [Parameter(ParameterSetName = 'SourceOID')]
        [Parameter(ParameterSetName = 'SourceAttribute')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'SourceOID')]
        [Parameter(ParameterSetName = 'SourceAttribute')]
        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [Parameter(ParameterSetName = 'SourceAttribute')]
        [Parameter(ParameterSetName = 'SourceOID')]
        [Parameter(ParameterSetName = 'Identity')]
        [bool]
        $RestrictValues,

        [Parameter()]
        [string]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = 'SourceAttribute')]
        [string]
        $SourceAttribute,

        [Parameter(Mandatory = $true, ParameterSetName = 'SourceOID')]
        [string]
        $SourceOID,

        [Parameter(Mandatory = $true, ParameterSetName = 'SourceTransformPolicy')]
        [switch]
        $SourceTransformPolicy,

        [Parameter(ParameterSetName = 'Identity')]
        [Parameter(ParameterSetName = 'SourceAttribute')]
        [Parameter(ParameterSetName = 'SourceTransformPolicy')]
        [Microsoft.ActiveDirectory.Management.ADSuggestedValueEntry[]]
        $SuggestedValues
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADComputer
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[datetime]]
        $AccountExpirationDate,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $AccountNotDelegated,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $AllowReversiblePasswordEncryption,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $AuthenticationPolicy,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $AuthenticationPolicySilo,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $CannotChangePassword,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Certificates,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ChangePasswordAtLogon,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $CompoundIdentitySupported,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $DisplayName,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $DNSHostName,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $Enabled,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $HomePage,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADComputer]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADComputer]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADKerberosEncryptionType]
        $KerberosEncryptionType,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Location,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $ManagedBy,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $OperatingSystem,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $OperatingSystemHotfix,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $OperatingSystemServicePack,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $OperatingSystemVersion,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $PasswordNeverExpires,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $PasswordNotRequired,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $PrincipalsAllowedToDelegateToAccount,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $SAMAccountName,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $ServicePrincipalNames,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $TrustedForDelegation,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $UserPrincipalName
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADDefaultDomainPasswordPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [System.Nullable[bool]]
        $ComplexityEnabled,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADDefaultDomainPasswordPolicy]
        $Identity,

        [Parameter()]
        [System.Nullable[timespan]]
        $LockoutDuration,

        [Parameter()]
        [System.Nullable[timespan]]
        $LockoutObservationWindow,

        [Parameter()]
        [System.Nullable[int]]
        $LockoutThreshold,

        [Parameter()]
        [System.Nullable[timespan]]
        $MaxPasswordAge,

        [Parameter()]
        [System.Nullable[timespan]]
        $MinPasswordAge,

        [Parameter()]
        [System.Nullable[int]]
        $MinPasswordLength,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [System.Nullable[int]]
        $PasswordHistoryCount,

        [Parameter()]
        [System.Nullable[bool]]
        $ReversibleEncryptionEnabled,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADDomain
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [hashtable]
        $AllowedDNSSuffixes,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADDomain]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADDomain]
        $Instance,

        [Parameter()]
        [System.Nullable[timespan]]
        $LastLogonReplicationInterval,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $ManagedBy,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADDomainMode
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADDomainMode]
        $DomainMode,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADDomain]
        $Identity,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADFineGrainedPasswordPolicy
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ComplexityEnabled,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $DisplayName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADFineGrainedPasswordPolicy]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADFineGrainedPasswordPolicy]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[timespan]]
        $LockoutDuration,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[timespan]]
        $LockoutObservationWindow,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[int]]
        $LockoutThreshold,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[timespan]]
        $MaxPasswordAge,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[timespan]]
        $MinPasswordAge,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[int]]
        $MinPasswordLength,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[int]]
        $PasswordHistoryCount,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[int]]
        $Precedence,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ReversibleEncryptionEnabled,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADForest
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADForest]
        $Identity,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [hashtable]
        $SPNSuffixes,

        [Parameter()]
        [hashtable]
        $UPNSuffixes
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADForestMode
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADForestMode]
        $ForestMode,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADForest]
        $Identity,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $DisplayName,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[Microsoft.ActiveDirectory.Management.ADGroupCategory]]
        $GroupCategory,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[Microsoft.ActiveDirectory.Management.ADGroupScope]]
        $GroupScope,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $HomePage,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADGroup]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADGroup]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $ManagedBy,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $SamAccountName,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $DisplayName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADObject]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADObject]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADOrganizationalUnit
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $City,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Country,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $DisplayName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $ManagedBy,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $PostalCode,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $State,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $StreetAddress
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADReplicationConnection
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationConnection]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADReplicationConnection]
        $Instance,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADDirectoryServer]
        $ReplicateFromDirectoryServer,

        [Parameter(ParameterSetName = 'Identity')]
        [System.DirectoryServices.ActiveDirectory.ActiveDirectorySchedule]
        $ReplicationSchedule,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADReplicationSite
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $AutomaticInterSiteTopologyGenerationEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $AutomaticTopologyGenerationEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSite]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSite]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADDirectoryServer]
        $InterSiteTopologyGenerator,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal]
        $ManagedBy,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $RedundantServerTopologyEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter(ParameterSetName = 'Identity')]
        [System.DirectoryServices.ActiveDirectory.ActiveDirectorySchedule]
        $ReplicationSchedule,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ScheduleHashingEnabled,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $TopologyCleanupEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $TopologyDetectStaleEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $TopologyMinimumHopsEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $UniversalGroupCachingEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSite]
        $UniversalGroupCachingRefreshSite,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $WindowsServer2000BridgeheadSelectionMethodEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $WindowsServer2000KCCISTGSelectionBehaviorEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $WindowsServer2003KCCBehaviorEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $WindowsServer2003KCCIgnoreScheduleEnabled,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $WindowsServer2003KCCSiteLinkBridgingEnabled
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADReplicationSiteLink
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[int]]
        $Cost,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSiteLink]
        $Identity,

        [Parameter(ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSiteLink]
        $Instance,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter(ParameterSetName = 'Identity')]
        [int]
        $ReplicationFrequencyInMinutes,

        [Parameter(ParameterSetName = 'Identity')]
        [System.DirectoryServices.ActiveDirectory.ActiveDirectorySchedule]
        $ReplicationSchedule,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $SitesIncluded
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADReplicationSiteLinkBridge
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSiteLinkBridge]
        $Identity,

        [Parameter(ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSiteLinkBridge]
        $Instance,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $SiteLinksIncluded
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADReplicationSubnet
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSubnet]
        $Identity,

        [Parameter(ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSubnet]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Location,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADReplicationSite]
        $Site
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADResourceProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $AppliesToResourceTypes,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $DisplayName,

        [Parameter(ParameterSetName = 'Identity')]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADResourceProperty]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADResourceProperty]
        $Instance,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADClaimType]
        $SharesValuesWith,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADSuggestedValueEntry[]]
        $SuggestedValues
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADResourcePropertyList
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADResourcePropertyList]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADResourcePropertyList]
        $Instance,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ProtectedFromAccidentalDeletion,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADServiceAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[datetime]]
        $AccountExpirationDate,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $AccountNotDelegated,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $AuthenticationPolicy,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $AuthenticationPolicySilo,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Certificates,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $CompoundIdentitySupported,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $DisplayName,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $DNSHostName,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $Enabled,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $HomePage,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADServiceAccount]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADServiceAccount]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADKerberosEncryptionType]
        $KerberosEncryptionType,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $PrincipalsAllowedToDelegateToAccount,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $PrincipalsAllowedToRetrieveManagedPassword,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $SamAccountName,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $ServicePrincipalNames,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $TrustedForDelegation
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Set-ADUser
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[datetime]]
        $AccountExpirationDate,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $AccountNotDelegated,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Add,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $AllowReversiblePasswordEncryption,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicy]
        $AuthenticationPolicy,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADAuthenticationPolicySilo]
        $AuthenticationPolicySilo,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $CannotChangePassword,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Certificates,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $ChangePasswordAtLogon,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $City,

        [Parameter(ParameterSetName = 'Identity')]
        [string[]]
        $Clear,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Company,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $CompoundIdentitySupported,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Country,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Department,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $DisplayName,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Division,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $EmailAddress,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $EmployeeID,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $EmployeeNumber,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $Enabled,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Fax,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $GivenName,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $HomeDirectory,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $HomeDrive,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $HomePage,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $HomePhone,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $Identity,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Initials,

        [Parameter(Mandatory = $true, ParameterSetName = 'Instance')]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $Instance,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADKerberosEncryptionType]
        $KerberosEncryptionType,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $LogonWorkstations,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $Manager,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $MobilePhone,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Office,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $OfficePhone,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Organization,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $OtherName,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $PasswordNeverExpires,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $PasswordNotRequired,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $POBox,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $PostalCode,

        [Parameter(ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADPrincipal[]]
        $PrincipalsAllowedToDelegateToAccount,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $ProfilePath,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Remove,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $Replace,

        [Parameter(ParameterSetName = 'Instance')]
        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $SamAccountName,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $ScriptPath,

        [Parameter()]
        [string]
        $Server,

        [Parameter(ParameterSetName = 'Identity')]
        [hashtable]
        $ServicePrincipalNames,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $SmartcardLogonRequired,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $State,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $StreetAddress,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Surname,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $Title,

        [Parameter(ParameterSetName = 'Identity')]
        [System.Nullable[bool]]
        $TrustedForDelegation,

        [Parameter(ParameterSetName = 'Identity')]
        [string]
        $UserPrincipalName
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Show-ADAuthenticationPolicyExpression
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'AllowedToAuthenticateFrom')]
        [switch]
        $AllowedToAuthenticateFrom,

        [Parameter(Mandatory = $true, ParameterSetName = 'AllowedToAuthenticateTo')]
        [switch]
        $AllowedToAuthenticateTo,

        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $SDDL,

        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [string]
        $Title
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Sync-ADObject
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Object')]
        [string]
        $Destination,

        [Parameter(Mandatory = $true, ParameterSetName = 'Object')]
        [Microsoft.ActiveDirectory.Management.ADObject]
        $Object,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = 'Object')]
        [switch]
        $PasswordOnly,

        [Parameter(ParameterSetName = 'Object')]
        [string]
        $Source
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Test-ADServiceAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter(Mandatory = $true, ParameterSetName = 'Identity')]
        [Microsoft.ActiveDirectory.Management.ADServiceAccount]
        $Identity
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Uninstall-ADServiceAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [switch]
        $ForceRemoveLocal,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADServiceAccount]
        $Identity
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ActiveDirectory version: 1.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Unlock-ADAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Microsoft.ActiveDirectory.Management.ADAuthType]
        $AuthType,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $Identity,

        [Parameter()]
        [string]
        $Partition,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [string]
        $Server
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

