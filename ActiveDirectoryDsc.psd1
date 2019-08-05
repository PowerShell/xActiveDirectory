@{
# Version number of this module.
moduleVersion = '3.0.0.0'

# ID used to uniquely identify this module
GUID = '9FECD4F6-8F02-4707-99B3-539E940E9FF5'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2019 Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
Description = 'The ActiveDirectoryDsc module contains DSC resources for deployment and configuration of Active Directory.

These DSC resources allow you to configure new domains, child domains, and high availability domain controllers, establish cross-domain trusts and manage users, groups and OUs.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Nested modules to load when this module is imported.
NestedModules = 'Modules\ActiveDirectoryDsc.Common\ActiveDirectoryDsc.Common.psm1'

# Functions to export from this module
FunctionsToExport = @(
  # Exported so that WaitForADDomain can use this function in a separate scope.
  'Find-DomainController'
)

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/PowerShell/ActiveDirectoryDsc/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/PowerShell/ActiveDirectoryDsc'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '- Changes to ActiveDirectoryDsc
  - Added new helper functions in xADCommon, see each functions comment-based
    help for more information.
    - Convert-PropertyMapToObjectProperties
    - Compare-ResourcePropertyState
    - Test-DscPropertyState
  - Move the examples in the README.md to Examples folder.
  - Fix Script Analyzer rule failures.
  - Opt-in to the following DSC Resource Common Meta Tests:
    - Common Tests - Custom Script Analyzer Rules
    - Common Tests - Required Script Analyzer Rules
    - Common Tests - Flagged Script Analyzer Rules
    - Common Tests - Validate Module Files ([issue 282](https://github.com/PowerShell/ActiveDirectoryDsc/issues/282))
    - Common Tests - Validate Script Files ([issue 283](https://github.com/PowerShell/ActiveDirectoryDsc/issues/283))
    - Common Tests - Relative Path Length ([issue 284](https://github.com/PowerShell/ActiveDirectoryDsc/issues/284))
    - Common Tests - Validate Markdown Links ([issue 280](https://github.com/PowerShell/ActiveDirectoryDsc/issues/280))
    - Common Tests - Validate Localization ([issue 281](https://github.com/PowerShell/ActiveDirectoryDsc/issues/281))
    - Common Tests - Validate Example Files ([issue 279](https://github.com/PowerShell/ActiveDirectoryDsc/issues/279))
    - Common Tests - Validate Example Files To Be Published ([issue 311](https://github.com/PowerShell/ActiveDirectoryDsc/issues/311))
  - Move resource descriptions to Wiki using auto-documentation ([issue 289](https://github.com/PowerShell/ActiveDirectoryDsc/issues/289))
  - Move helper functions from MSFT_xADCommon to the module
    ActiveDirectoryDsc.Common ([issue 288](https://github.com/PowerShell/ActiveDirectoryDsc/issues/288)).
    - Removed helper function `Test-ADDomain` since it was not used. The
      helper function had design flaws too.
    - Now the helper function `Test-Members` outputs all the members that
      are not in desired state when verbose output is enabled.
  - Update all unit tests to latest unit test template.
  - Deleted the obsolete xActiveDirectory_TechNetDocumentation.html file.
  - Added new resource xADObjectEnabledState. This resource should be
    used to enforce the `Enabled` property of computer accounts. This
    resource replaces the deprecated `Enabled` property in the resource
    xADComputer.
  - Cleanup of code
    - Removed semicolon throughout where it is not needed.
    - Migrate tests to Pester syntax v4.x ([issue 322](https://github.com/PowerShell/ActiveDirectoryDsc/issues/322)).
    - Removed `-MockWith {}` in unit tests.
    - Use fully qualified type names for parameters and variables
      ([issue 374](https://github.com/PowerShell/ActiveDirectoryDsc/issues/374)).
  - Removed unused legacy test files from the root of the repository.
  - Updated Example List README with missing resources.
  - Added missing examples for xADReplicationSubnet, xADServicePrincipalName and xWaitForADDomain. ([issue 395](https://github.com/PowerShell/ActiveDirectoryDsc/issues/395)).
- Changes to xADComputer
  - Refactored the resource and the unit tests.
  - BREAKING CHANGE: The `Enabled` property is **DEPRECATED** and is no
    longer set or enforces with this resource. _If this parameter is_
    _used in a configuration a warning message will be outputted saying_
    _that the `Enabled` parameter has been deprecated_. The new resource
    [xADObjectEnabledState](https://github.com/PowerShell/xActiveDirectoryxadobjectenabledstate)
    can be used to enforce the `Enabled` property.
  - BREAKING CHANGE: The default value of the enabled property of the
    computer account will be set to the default value of the cmdlet
    `New-ADComputer`.
  - A new parameter was added called `EnabledOnCreation` that will control
    if the computer account is created enabled or disabled.
  - Moved examples from the README.md to separate example files in the
    Examples folder.
  - Fix the RestoreFromRecycleBin description.
  - Fix unnecessary cast in `Test-TargetResource` ([issue 295](https://github.com/PowerShell/ActiveDirectoryDsc/issues/295)).
  - Fix ServicePrincipalNames property empty string exception ([issue 382](https://github.com/PowerShell/ActiveDirectoryDsc/issues/382)).
- Changes to xADGroup
  - Change the description of the property RestoreFromRecycleBin.
  - Code cleanup.
- Changes to xADObjectPermissionEntry
  - Change the description of the property IdentityReference.
  - Fix failure when applied in the same configuration as xADDomain.
  - Localize and Improve verbose messaging.
  - Code cleanup.
- Changes to xADOrganizationalUnit
  - Change the description of the property RestoreFromRecycleBin.
  - Code cleanup.
  - Fix incorrect verbose message when this resource has Ensure set to Absent ([issue 276](https://github.com/PowerShell/ActiveDirectoryDsc/issues/276)).
- Changes to xADUser
  - Change the description of the property RestoreFromRecycleBin.
  - Added ServicePrincipalNames property ([issue 153](https://github.com/PowerShell/ActiveDirectoryDsc/issues/153)).
  - Added ChangePasswordAtLogon property ([issue 246](https://github.com/PowerShell/ActiveDirectoryDsc/issues/246)).
  - Code cleanup.
  - Added LogonWorkstations property
  - Added Organization property
  - Added OtherName property
  - Added AccountNotDelegated property
  - Added AllowReversiblePasswordEncryption property
  - Added CompoundIdentitySupported property
  - Added PasswordNotRequired property
  - Added SmartcardLogonRequired property
  - Added ProxyAddresses property ([Issue 254](https://github.com/PowerShell/ActiveDirectoryDsc/issues/254)).
  - Fix Password property being updated whenever another property is changed
    ([issue 384](https://github.com/PowerShell/ActiveDirectoryDsc/issues/384)).
  - Replace Write-Error with the correct helper function ([Issue 331](https://github.com/PowerShell/ActiveDirectoryDsc/issues/331)).
- Changes to xADDomainController
  - Change the `Requires` statement in the Examples to require the correct
    module.
  - Suppressing the Script Analyzer rule `PSAvoidGlobalVars` since the
    resource is using the `$global:DSCMachineStatus` variable to trigger
    a reboot.
  - Code cleanup.
- Changes to xADDomain
  - Suppressing the Script Analyzer rule `PSAvoidGlobalVars` since the
    resource is using the `$global:DSCMachineStatus` variable to trigger
    a reboot.
  - Code cleanup.
- Changes to xADDomainTrust
  - Replaced New-TerminatingError with Standard Function.
  - Code cleanup.
- Changes to xWaitForADDomain
  - Suppressing the Script Analyzer rule `PSAvoidGlobalVars` since the
    resource is using the `$global:DSCMachineStatus` variable to trigger
    a reboot.
  - Added missing property schema descriptions ([issue 369](https://github.com/PowerShell/ActiveDirectoryDsc/issues/369)).
  - Code cleanup.
- Changes to xADRecycleBin
  - Remove unneeded example and resource designer files.
  - Added missing property schema descriptions ([issue 368](https://github.com/PowerShell/ActiveDirectoryDsc/issues/368)).
  - Code cleanup.
  - It now sets back the `$ErrorActionPreference` that was set prior to
    setting it to `"Stop"`.
  - Replace Write-Error with the correct helper function ([issue 327](https://github.com/PowerShell/ActiveDirectoryDsc/issues/327)).
- Changes to xADReplicationSiteLink
  - Fix ADIdentityNotFoundException when creating a new site link.
  - Code cleanup.
- Changes to xADReplicationSubnet
  - Remove `{ *Present* | Absent }` from the property schema descriptions
    which were causing corruption in the Wiki documentation.
- Changes to xADServicePrincipalNames
  - Remove `{ *Present* | Absent }` from the property schema descriptions
    which were causing corruption in the Wiki documentation.
- Changes to xADDomainDefaultPasswordPolicy
  - Code cleanup.
- Changes to xADForestProperties
  - Minor style cleanup.
- Changes to xADReplicationSubnet
  - Code cleanup.
- Changes to xADKDSKey
  - Code cleanup.
- Changes to xADManagedServiceAccount
  - Code cleanup.
- Changes to xADServicePrincipalName
  - Code cleanup.

'

    } # End of PSData hashtable

} # End of PrivateData hashtable
}

















