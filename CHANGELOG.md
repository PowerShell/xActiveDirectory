# Change log for xActiveDirectory

## Unreleased

- Changes to xActiveDirectory
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
    - Common Tests - Validate Module Files ([issue #282](https://github.com/PowerShell/xActiveDirectory/issues/282))
    - Common Tests - Validate Script Files ([issue #283](https://github.com/PowerShell/xActiveDirectory/issues/283))
    - Common Tests - Relative Path Length ([issue #284](https://github.com/PowerShell/xActiveDirectory/issues/284))
    - Common Tests - Validate Markdown Links ([issue #280](https://github.com/PowerShell/xActiveDirectory/issues/280))
    - Common Tests - Validate Localization ([issue #281](https://github.com/PowerShell/xActiveDirectory/issues/281))
    - Common Tests - Validate Example Files ([issue #279](https://github.com/PowerShell/xActiveDirectory/issues/279))
    - Common Tests - Validate Example Files To Be Published ([issue #311](https://github.com/PowerShell/xActiveDirectory/issues/311))
  - Move resource descriptions to Wiki using auto-documentation ([issue #289](https://github.com/PowerShell/xActiveDirectory/issues/289))
  - Move helper functions from MSFT_xADCommon to the module
    xActiveDirectory.Common ([issue #288](https://github.com/PowerShell/xActiveDirectory/issues/288)).
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
    - Migrate tests to Pester syntax v4.x ([issue #322](https://github.com/PowerShell/xActiveDirectory/issues/322)).
    - Removed `-MockWith {}` in unit tests.
- Changes to xADComputer
  - Refactored the resource and the unit tests.
  - BREAKING CHANGE: The `Enabled` property is **DEPRECATED** and is no
    longer set or enforces with this resource. _If this parameter is_
    _used in a configuration a warning message will be outputted saying_
    _that the `Enabled` parameter has been deprecated_. The new resource
    [xADObjectEnabledState](https://github.com/PowerShell/xActiveDirectory#xadobjectenabledstate)
    can be used to enforce the `Enabled` property.
  - BREAKING CHANGE: The default value of the enabled property of the
    computer account will be set to the default value of the cmdlet
    `New-ADComputer`.
  - A new parameter was added called `EnabledOnCreation` that will control
    if the computer account is created enabled or disabled.
  - Moved examples from the README.md to separate example files in the
    Examples folder.
  - Fix the RestoreFromRecycleBin description.
  - Fix unnecessary cast in `Test-TargetResource` ([issue #295](https://github.com/PowerShell/xActiveDirectory/issues/295)).
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
- Changes to xADUser
  - Change the description of the property RestoreFromRecycleBin.
  - Added ServicePrincipalNames property ([issue #153](https://github.com/PowerShell/xActiveDirectory/issues/153)).
  - Added ChangePasswordAtLogon property ([issue #246](https://github.com/PowerShell/xActiveDirectory/issues/246)).
  - Code cleanup.
  - Added LogonWorkstations property
  - Added Organization property
  - Added OtherName property
  - Added AccountNotDelegated property
  - Added AllowReversiblePasswordEncryption property
  - Added CompoundIdentitySupported property
  - Added PasswordNotRequired property
  - Added SmartcardLogonRequired property
- Changes to xADDomainController
  - Change the `#Requires` statement in the Examples to require the correct
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
  - Added missing property schema descriptions ([issue #369](https://github.com/PowerShell/xActiveDirectory/issues/369)).
  - Code cleanup.
- Changes to xADRecycleBin
  - Remove unneeded example and resource designer files.
  - Added missing property schema descriptions ([issue #368](https://github.com/PowerShell/xActiveDirectory/issues/368)).
  - Code cleanup.
  - It now set back the `$ErrorActionPreference` that was set prior to
    setting it to `'Stop'`.
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

## 2.26.0.0

- Changes to xActiveDirectory
  - Added localization module -DscResource.LocalizationHelper* containing
    the helper functions `Get-LocalizedData`, `New-InvalidArgumentException`,
    `New-InvalidOperationException`, `New-ObjectNotFoundException`, and
    `New-InvalidResultException` ([issue #257](https://github.com/PowerShell/xActiveDirectory/issues/257)).
    For more information around these helper functions and localization
    in resources, see [Localization section in the Style Guideline](https://github.com/PowerShell/DscResources/blob/master/StyleGuidelines.md#localization).
  - Added common module *DscResource.Common* containing the helper function
    `Test-DscParameterState`. The goal is that all resource common functions
    are moved to this module (functions that are or can be used by more
    than one resource) ([issue #257](https://github.com/PowerShell/xActiveDirectory/issues/257)).
  - Added xADManagedServiceAccount resource to manage Managed Service
    Accounts (MSAs). [Andrew Wickham (@awickham10)](https://github.com/awickham10)
    and [@kungfu71186](https://github.com/kungfu71186)
  - Removing the Misc Folder, as it is no longer required.
  - Added xADKDSKey resource to create KDS Root Keys for gMSAs. [@kungfu71186](https://github.com/kungfu71186)
  - Combined DscResource.LocalizationHelper and DscResource.Common Modules into xActiveDirectory.Common
- Changes to xADReplicationSiteLink
  - Make use of the new localization helper functions.
- Changes to xAdDomainController
  - Added new parameter to disable or enable the Global Catalog (GC)
    ([issue #75](https://github.com/PowerShell/xActiveDirectory/issues/75)). [Eric Foskett @Merto410](https://github.com/Merto410)
  - Fixed a bug with the parameter `InstallationMediaPath` that it would
    not be added if it was specified in a configuration. Now the parameter
    `InstallationMediaPath` is correctly passed to `Install-ADDSDomainController`.
  - Refactored the resource with major code cleanup and localization.
  - Updated unit tests to latest unit test template and refactored the
    tests for the function 'Set-TargetResource'.
  - Improved test code coverage.
- Changes to xADComputer
  - Restoring a computer account from the recycle bin no longer fails if
    there is more than one object with the same name in the recycle bin.
    Now it uses the object that was changed last using the property
    `whenChanged` ([issue #271](https://github.com/PowerShell/xActiveDirectory/issues/271)).
- Changes to xADGroup
  - Restoring a group from the recycle bin no longer fails if there is
    more than one object with the same name in the recycle bin. Now it
    uses the object that was changed last using the property `whenChanged`
    ([issue #271](https://github.com/PowerShell/xActiveDirectory/issues/271)).
- Changes to xADOrganizationalUnit
  - Restoring an organizational unit from the recycle bin no longer fails
    if there is more than one object with the same name in the recycle bin.
    Now it uses the object that was changed last using the property `whenChanged`
    ([issue #271](https://github.com/PowerShell/xActiveDirectory/issues/271)).
- Changes to xADUser
  - Restoring a user from the recycle bin no longer fails if there is
    more than one object with the same name in the recycle bin. Now it
    uses the object that was changed last using the property `whenChanged`
    ([issue #271](https://github.com/PowerShell/xActiveDirectory/issues/271)).

## 2.25.0.0

- Added xADReplicationSiteLink
  - New resource added to facilitate replication between AD sites
- Updated xADObjectPermissionEntry to use `AD:` which is more generic when using `Get-Acl` and `Set-Acl` than using `Microsoft.ActiveDirectory.Management\ActiveDirectory:://RootDSE/`
- Changes to xADComputer
  - Minor clean up of unit tests.
- Changes to xADUser
  - Added TrustedForDelegation parameter to xADUser to support enabling/disabling Kerberos delegation
  - Minor clean up of unit tests.
- Added Ensure Read property to xADDomainController to fix Get-TargetResource return bug ([issue #155](https://github.com/PowerShell/xActiveDirectory/issues/155)).
  - Updated readme and add release notes
- Updated xADGroup to support group membership from multiple domains ([issue #152](https://github.com/PowerShell/xActiveDirectory/issues/152)). [Robert Biddle (@robbiddle)](https://github.com/RobBiddle) and [Jan-Hendrik Peters (@nyanhp)](https://github.com/nyanhp)

## 2.24.0.0

- Added parameter to xADDomainController to support InstallationMediaPath ([issue #108](https://github.com/PowerShell/xActiveDirectory/issues/108)).
- Updated xADDomainController schema to be standard and provide Descriptions.

## 2.23.0.0

- Explicitly removed extra hidden files from release package

## 2.22.0.0

- Add PasswordNeverResets parameter to xADUser to facilitate user lifecycle management
- Update appveyor.yml to use the default template.
- Added default template files .gitattributes, and .gitignore, and
  .vscode folder.
- Added xADForestProperties: New resource to manage User and Principal Name Suffixes for a Forest.

## 2.21.0.0

- Added xADObjectPermissionEntry
  - New resource added to control the AD object permissions entries [Claudio Spizzi (@claudiospizzi)](https://github.com/claudiospizzi)
- Changes to xADCommon
  - Assert-Module has been extended with a parameter ImportModule to also import the module ([issue #218](https://github.com/PowerShell/xActiveDirectory/issues/218)). [Jan-Hendrik Peters (@nyanhp)](https://github.com/nyanhp)
- Changes to xADDomain
  - xADDomain makes use of new parameter ImportModule of Assert-Module in order to import the ADDSDeployment module ([issue #218](https://github.com/PowerShell/xActiveDirectory/issues/218)). [Jan-Hendrik Peters (@nyanhp)](https://github.com/nyanhp)
- xADComputer, xADGroup, xADOrganizationalUnit and xADUser now support restoring from AD recycle bin ([Issue #221](https://github.com/PowerShell/xActiveDirectory/issues/211)). [Jan-Hendrik Peters (@nyanhp)](https://github.com/nyanhp)

## 2.20.0.0

- Changes to xActiveDirectory
  - Changed MSFT_xADUser.schema.mof version to "1.0.0.0" to match other resources ([issue #190](https://github.com/PowerShell/xActiveDirectory/issues/190)). [thequietman44 (@thequietman44)](https://github.com/thequietman44)
  - Removed duplicated code from examples in README.md ([issue #198](https://github.com/PowerShell/xActiveDirectory/issues/198)). [thequietman44 (@thequietman44)](https://github.com/thequietman44)
  - xADDomain is now capable of setting the forest and domain functional level ([issue #187](https://github.com/PowerShell/xActiveDirectory/issues/187)). [Jan-Hendrik Peters (@nyanhp)](https://github.com/nyanhp)

## 2.19.0.0

- Changes to xActiveDirectory
  - Activated the GitHub App Stale on the GitHub repository.
  - The resources are now in alphabetical order in the README.md
    ([issue #194](https://github.com/PowerShell/xActiveDirectory/issues/194)).
  - Adding a Branches section to the README.md with Codecov badges for both
    master and dev branch ([issue #192](https://github.com/PowerShell/xActiveDirectory/issues/192)).
  - xADGroup no longer resets GroupScope and Category to default values ([issue #183](https://github.com/PowerShell/xActiveDirectory/issues/183)).
  - The helper function script file MSFT_xADCommon.ps1 was renamed to
    MSFT_xADCommon.psm1 to be a module script file instead. This makes it
    possible to report code coverage for the helper functions ([issue #201](https://github.com/PowerShell/xActiveDirectory/issues/201)).

## 2.18.0.0

- xADReplicationSite: Resource added.
- Added xADReplicationSubnet resource.
- Fixed bug with group members in xADGroup

## 2.17.0.0

- Converted AppVeyor.yml to use DSCResource.tests shared code.
- Opted-In to markdown rule validation.
- Readme.md modified resolve markdown rule violations.
- Added CodeCov.io support.
- Added xADServicePrincipalName resource.

## 2.16.0.0

- xAdDomainController: Update to complete fix for SiteName being required field.
- xADDomain: Added retry logic to prevent FaultException to crash in Get-TargetResource on subsequent reboots after a domain is created because the service is not yet running. This error is mostly occur when the resource is used with the DSCExtension on Azure.

## 2.15.0.0

- xAdDomainController: Fixes SiteName being required field.

## 2.14.0.0

- xADDomainController: Adds Site option.
- xADDomainController: Populate values for DatabasePath, LogPath and SysvolPath during Get-TargetResource.

## 2.13.0.0

- Converted AppVeyor.yml to pull Pester from PSGallery instead of Chocolatey
- xADUser: Adds 'PasswordAuthentication' option when testing user passwords to support NTLM authentication with Active Directory Certificate Services deployments
- xADUser: Adds descriptions to user properties within the schema file.
- xADGroup: Fixes bug when updating groups when alternate Credentials are specified.

## 2.12.0.0

- xADDomainController: Customer identified two cases of incorrect variables being called in Verbose output messages. Corrected.
- xADComputer: New resource added.
- xADComputer: Added RequestFile support.
- Fixed PSScriptAnalyzer Errors with v1.6.0.

## 2.11.0.0

- xWaitForADDomain: Made explicit credentials optional and other various updates

## 2.10.0.0

- xADDomainDefaultPasswordPolicy: New resource added.
- xWaitForADDomain: Updated to make it compatible with systems that don't have the ActiveDirectory module installed, and to allow it to function with domains/forests that don't have a domain controller with Active Directory Web Services running.
- xADGroup: Fixed bug where specified credentials were not used to retrieve existing group membership.
- xADDomain: Added check for Active Directory cmdlets.
- xADDomain: Added additional error trapping, verbose and diagnostic information.
- xADDomain: Added unit test coverage.
- Fixes CredentialAttribute and other PSScriptAnalyzer tests in xADCommon, xADDomin, xADGroup, xADOrganizationalUnit and xADUser resources.

## 2.9.0.0

- xADOrganizationalUnit: Merges xADOrganizationalUnit resource from the PowerShell gallery
- xADGroup: Added Members, MembersToInclude, MembersToExclude and MembershipAttribute properties.
- xADGroup: Added ManagedBy property.
- xADGroup: Added Notes property.
- xADUser: Adds additional property settings.
- xADUser: Adds unit test coverage.

## 2.8.0.0

- Added new resource: xADGroup
- Fixed issue with NewDomainNetbiosName parameter.

## 2.7.0.0

- Added DNS flush in retry loop
- Bug fixes in xADDomain resource

## 2.6.0.0

- Removed xDscResourceDesigner tests (moved to common tests)

## 2.5.0.0

- Updated xADDomainTrust and xADRecycleBin tests

## 2.4.0.0

- Added xADRecycleBin resource
- Minor fixes for xADUser resource

## 2.3

- Added xADRecycleBin.
- Modified xADUser to include a write-verbose after user is removed when Absent.
- Corrected xADUser to successfully create a disabled user without a password.

## 2.2

- Modified xAdDomain and xAdDomainController to support Ensure as Present / Absent, rather than True/False.
  Note: this may cause issues for existing scripts.
- Corrected return value to be a hashtable in both resources.

## 2.1.0.0

- Minor update: Get-TargetResource to use domain name instead of name.

## 2.0.0.0

- Updated release, which added the resource:
  - xADDomainTrust

## 1.0.0.0

- Initial release with the following resources:
  - xADDomain, xADDomainController, xADUser, and xWaitForDomain
