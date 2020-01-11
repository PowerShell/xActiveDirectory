@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'ActiveDirectoryDsc.Common.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0'

    # ID used to uniquely identify this module
    GUID              = 'a4af6d71-e828-4ec3-8a05-6083b8d5d4c2'

    # Author of this module
    Author            = 'DSC Community'

    # Company or vendor of this module
    CompanyName       = 'DSC Community'

    # Copyright statement for this module
    Copyright         = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Functions used by the DSC resources in ActiveDirectoryDsc.'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'New-InvalidArgumentException'
        'New-InvalidOperationException'
        'New-ObjectNotFoundException'
        'New-InvalidResultException'
        'Get-LocalizedData'
        'Start-ProcessWithTimeout'
        'Assert-Module'
        'Test-DomainMember'
        'Get-DomainName'
        'Resolve-DomainFQDN'
        'Get-ADObjectParentDN'
        'Assert-MemberParameters'
        'Remove-DuplicateMembers'
        'Test-Members'
        'ConvertTo-TimeSpan'
        'ConvertFrom-TimeSpan'
        'Get-ADCommonParameters'
        'Test-ADReplicationSite'
        'ConvertTo-DeploymentForestMode'
        'ConvertTo-DeploymentDomainMode'
        'Restore-ADCommonObject'
        'Get-ADDomainNameFromDistinguishedName'
        'Add-ADCommonGroupMember'
        'Get-DomainControllerObject'
        'Test-IsDomainController'
        'Convert-PropertyMapToObjectProperties'
        'Compare-ResourcePropertyState'
        'Test-DscPropertyState'
        'Assert-ADPSDrive'
        'Set-DscADComputer'
        'New-CimCredentialInstance'
        'Add-TypeAssembly'
        'Get-ADDirectoryContext'
        'Find-DomainController'
        'Get-CurrentUser'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{
        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
