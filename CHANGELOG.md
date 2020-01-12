# Change log for ActiveDirectoryDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For older change log history see the [historic changelog](HISTORIC_CHANGELOG.md).

## [Unreleased]

### Added

- ADServicePrincipalName
  - Added Integration tests ([issue #358](https://github.com/PowerShell/ActiveDirectoryDsc/issues/358)).
- ADManagedServiceAccount
  - Added Integration tests.
- ADKDSKey
  - Added Integration tests ([issue #351](https://github.com/PowerShell/ActiveDirectoryDsc/issues/351)).

### Changed

- ADManagedServiceAccount
  - KerberosEncryptionType property added. ([issue #511](https://github.com/PowerShell/ActiveDirectoryDsc/issues/511)).
  - BREAKING CHANGE: AccountType parameter ValidateSet changed from ('Group', 'Single') to ('Group', 'Standalone') - Standalone is the correct terminology. Ref: [Service Accounts](https://docs.microsoft.com/en-us/windows/security/identity-protection/access-control/service-accounts).
  ([issue #515](https://github.com/PowerShell/ActiveDirectoryDsc/issues/515)).
  - BREAKING CHANGE: AccountType parameter default of Single removed. - Enforce positive choice of account type.
  - BREAKING CHANGE: MembershipAttribute parameter ValidateSet member SID changed to ObjectSid to match result property of Get-AdObject. Previous code does not work if SID is specified.
  - BREAKING CHANGE: AccountTypeForce parameter removed - unnecessary complication.
  - BREAKING CHANGE: Members parameter renamed to ManagedPasswordPrincipals - to closer match Get-AdServiceAccount result property PrincipalsAllowedToRetrieveManagedPassword. This is so that a DelegateToAccountPrincipals parameter can be added later.
  - Common Compare-ResourcePropertyState function used to replace function specific Compare-TargetResourceState and code refactored.
  ([issue #512](https://github.com/PowerShell/ActiveDirectoryDsc/issues/512)).
  - Resource unit tests refactored to use nested contexts and follow the logic of the module.
- ActiveDirectoryDsc
  - Updated PowerShell help files.
  - Updated Wiki link in README.md.

### Fixed

- ADObjectPermissionEntry
  - Updated Assert-ADPSDrive with PSProvider Checks ([issue #527](https://github.com/PowerShell/ActiveDirectoryDsc/issues/527)).
- ADReplicationSite
  - Fixed incorrect evaluation of site configuration state when no description is defined ([issue #534](https://github.com/dsccommunity/ActiveDirectoryDsc/issues/534)).
- ADReplicationSiteLink
  - Fix RemovingSites verbose message ([issue #518](https://github.com/PowerShell/ActiveDirectoryDsc/issues/518)).
- ADComputer
  - Fixed the SamAcountName property description ([issue #529](https://github.com/dsccommunity/ActiveDirectoryDsc/issues/529)).

## 4.2.0.0

### Added

- ADReplicationSite
  - Added 'Description' attribute parameter ([issue #500](https://github.com/PowerShell/ActiveDirectoryDsc/issues/500)).
  - Added Integration testing ([issue #355](https://github.com/PowerShell/ActiveDirectoryDsc/issues/355)).
- ADReplicationSubnet
  - Added 'Description' attribute parameter ([issue #503](https://github.com/PowerShell/ActiveDirectoryDsc/issues/500)).
  - Added Integration testing ([issue #357](https://github.com/PowerShell/ActiveDirectoryDsc/issues/357)).
- ADReplicationSiteLink
  - Added Integration testing ([issue #356](https://github.com/PowerShell/ActiveDirectoryDsc/issues/356)).
  - Added ability to set 'Options' such as Change Notification Replication ([issue #504](https://github.com/PowerShell/ActiveDirectoryDsc/issues/504)).

### Fixed

- ActiveDirectoryDsc
  - Resolved custom Script Analyzer rules that was added to the test framework.
- ActiveDirectoryDsc.Common
  - Fix `Test-DscPropertyState` Failing when Comparing $Null and Arrays. ([issue #513](https://github.com/PowerShell/ActiveDirectoryDsc/issues/513)).
- ADReplicationSite
  - Correct value returned for RenameDefaultFirstSiteName ([issue #502](https://github.com/PowerShell/ActiveDirectoryDsc/issues/502)).
