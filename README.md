# xActiveDirectory

The **xActiveDirectory** module contains DSC resources for deployment and
configuration of Active Directory.

These DSC resources allow you to configure new domains, child domains, and high
availability domain controllers, establish cross-domain trusts and manage users,
groups and OUs.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/p4jejr60jrgb8ity/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xActiveDirectory/branch/master)
[![codecov](https://codecov.io/gh/PowerShell/xActiveDirectory/branch/master/graph/badge.svg)](https://codecov.io/gh/PowerShell/xActiveDirectory/branch/master)

This is the branch containing the latest release -
no contributions should be made directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/p4jejr60jrgb8ity/branch/dev?svg=true)](https://ci.appveyor.com/project/PowerShell/xActiveDirectory/branch/dev)
[![codecov](https://codecov.io/gh/PowerShell/xActiveDirectory/branch/dev/graph/badge.svg)](https://codecov.io/gh/PowerShell/xActiveDirectory/branch/dev)

This is the development branch
to which contributions should be proposed by contributors as pull requests.
This development branch will periodically be merged to the master branch,
and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Resource [contributing guidelines](https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md).

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

* [**xADComputer**](#xadcomputer) creates and manages Active Directory computer accounts.
* **xADDomain** creates new Active Directory forest configurations and new Active Directory domain configurations.
* **xADDomainController** installs and configures domain controllers in Active Directory.
* **xADDomainDefaultPasswordPolicy** manages an Active Directory domain's default password policy.
* **xADDomainTrust** establishes cross-domain trusts.
* **xADForestProperties** manages User Principal Name (UPN) suffixes and Service Principal Name (SPN) suffixes in a forest.
* **xADGroup** modifies and removes Active Directory groups.
* **xADManagedServiceAccount** modifies and removes Active Directory Managed Service Accounts (MSA).
* **xADObjectPermissionEntry** modifies the access control list of an Active Directory object.
* **xADOrganizationalUnit** creates and deletes Active Directory OUs.
* **xADRecycleBin** enables or disabled Active Directory Recycle Bin.
* **xADReplicationSite** creates and deletes Active Directory replication sites.
* **xADReplicationSiteLink** creates, deletes and modifies Active Directory replication site links.
* **xADReplicationSubnet** add or removes Active Directory replication subnet.
* **xADServicePrincipalName** adds or removes the SPN to a user or computer account.
* **xADUser** modifies and removes Active Directory Users.
* **xWaitForDomain** waits for new, remote domain to setup.

(Note: the RSAT tools will not be installed when these resources are used to configure AD.)

### **xADComputer**

The xADComputer DSC resource will manage computer accounts within Active Directory.

>**Note:** An Offline Domain Join (ODJ) request file will only be created
>when a computer account is first created in the domain. Setting an Offline
>Domain Join (ODJ) Request file path for a configuration that updates a
>computer account that already exists, or restore it from the recycle bin
>will not cause the Offline Domain Join (ODJ) request file to be created.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.

#### Parameters

* **`[String]` ComputerName** _(Key)_: Specifies the name of the Active
  Directory computer account to manage. You can identify a computer by
  its distinguished name, GUID, security identifier (SID) or Security
  Accounts Manager (SAM) account name.
* **`[String]` Location** _(Write)_: Specifies the location of the computer,
  such as an office number.
* **`[String]` DnsHostName** _(Write)_: Specifies the fully qualified
  domain name (FQDN) of the computer account.
* **`[String]` ServicePrincipalNames** _(Write)_: Specifies the service
  principal names for the computer account.
* **`[String]` UserPrincipalName** _(Write)_: Specifies the UPN assigned
  to the computer account.
* **`[String]` DisplayName** _(Write)_: Specifies the display name of
  the computer account.
* **`[String]` Path** _(Write)_: Specifies the X.500 path of the
  Organizational Unit (OU) or container where the computer is located.
* **`[String]` Description** _(Write)_: Specifies a description of the
  computer account.
* **`[Boolean]` Enabled** _(Write)_: **DEPRECATED - DO NOT USE**. Please
  see the parameter `EnabledOnCreation` in this resource, and the resource
  [xADObjectEnabledState](#xadobjectenabledstate) on how to enforce the
  `Enabled` property. _This parameter no longer sets or enforces the_
   _Enabled property. If this parameter is used then a warning message_
   _will be outputted saying that the `Enabled` parameter has been_
   _deprecated_.
* **`[Boolean]` EnabledOnCreation** _(Write)_: Specifies if the computer
  account is created enabled or disabled. By default the Enabled property
  of the computer account will be set to the default value of the cmdlet
  `New-ADComputer`. This property is ignored if the parameter `RequestFile`
  is specified in the same configuration. _This parameter does not enforce_
  _the property `Enabled`. To enforce the property `Enabled` see the
  _resource [xADObjectEnabledState](#xadobjectenabledstate)._
* **`[String]` Manager** _(Write)_: Specifies the user or group Distinguished
  Name that manages the computer account. Valid values are the user's or
  group's DistinguishedName, ObjectGUID, SID or SamAccountName.
* **`[String]` DomainController** _(Write)_: Specifies the Active Directory
  Domain Services instance to connect to perform the task.
* **`[PSCredential]` DomainAdministratorCredential** _(Write)_: Specifies
  the user account credentials to use to perform the task.
* **`[String]` RequestFile** _(Write)_: Specifies the full path to the
  Offline Domain Join Request file to create.
* **`[String]` Ensure**: Specifies whether the computer account is present
  or absent. Valid values are 'Present' and 'Absent'. The default is 'Present'.
* **`[Boolean]` RestoreFromRecycleBin** _(Write)_: Try to restore the
  organizational unit from the recycle bin before creating a new one.

#### Read-Only Properties from Get-TargetResource

* **`[String]` DistinguishedName** _(Read)_: Returns the X.500 path of
  the computer account.
* **`[String]` SID** _(Read)_: Returns the security identifier of the
  computer account.
* **`[String]` SamAccountName** _(Read)_: Returns the computer account
  Security Accounts Manager (SAM) account name.

#### Examples

* [Add a Active Directory computer account](/Examples/Resources/xADComputer/1-AddComputerAccount_Config.ps1)
* [Add a Active Directory computer account disabled](/Examples/Resources/xADComputer/2-AddComputerAccountDisabled_Config.ps1)
* [Add a Active Directory computer account in a organizational unit](/Examples/Resources/xADComputer/3-AddComputerAccountSpecificPath_Config.ps1)
* [Add a Active Directory computer account and create an offline domain join (ODJ) request file](/Examples/Resources/xADComputer/4-AddComputerAccountAndCreateODJRequest_Config.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/xActiveDirectory/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+xADComputer).

### **xADDomain**

The xADDomain resource creates a new domain in a new forest or a child domain in an existing forest. While it is possible to set the forest functional level and the domain functional level during deployment with this resource the common restrictions apply. For more information see [TechNet](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/active-directory-functional-levels).

* **`[String]` DomainName** _(Key)_: FQDN of the new domain.
  * If no parent name is specified, this is the fully qualified domain name for the first domain in the forest.
* **`[String]` ParentDomainName** _(Write)_: Fully qualified name of the parent domain.
* **`[PSCredential]` DomainAdministratorCredential** _(Required)_: Credentials used to query for domain existence.
  * _Note: These are NOT used during domain creation._ During an Active Directory deployment the local administrator credentials are used for the domain administrator.
* **`[PSCredential]` SafemodeAdministratorPassword** _(Required)_: Password for the administrator account when the computer is started in Safe Mode.
* **`[PSCredential]` DnsDelegationCredential** _(Write)_: Credential used for creating DNS delegation.
* **`[String]` DomainNetBIOSName** _(Write)_: Specifies the NetBIOS name for the new domain.
  * If not specified, then the default is automatically computed from the value of the DomainName parameter.
* **`[String]` DatabasePath** _(Write)_: Specifies the fully qualified, non-Universal Naming Convention (UNC) path to a directory on a fixed disk of the local computer that contains the domain database.
* **`[String]` LogPath** _(Write)_: Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the log file for this operation will be written.
* **`[String]` SysvolPath** _(Write)_: Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the Sysvol file will be written.
* **`[String]` ForestMode** _(Write)_: Specifies the forest mode if a new forest is deployed. ForestMode will not be raised by this resource for existing forests.
  * Valid values are Win2008, Win2008R2, Win2012, Win2012R2 and WinThreshold (for Windows Server 2016 FFL)
* **`[String]` DomainMode** _(Write)_: Specifies the domain mode if a new domain is deployed. DomainMode will not be raised by this resource for existing domains.
  * Valid values are Win2008, Win2008R2, Win2012, Win2012R2 and WinThreshold (for Windows Server 2016 DFL)

### **xADDomainController**

The xADDomainController DSC resource will install and configure domain
controllers in Active Directory.

>**Note:** If the account used for the parameter `DomainAdministratorCredential`
>cannot connect to another domain controller, for example using a credential
>without the domain name, then the cmdlet `Install-ADDSDomainController` will
>seemingly halt (without reporting an error) when trying to replicate
>information from another domain controller.
>Make sure to use a correct domain account with the correct permission as
>the account for the parameter `DomainAdministratorCredential`.

* **`[String]` DomainName** _(Key)_: The fully qualified domain name for the domain where the domain controller will be present.
* **`[PSCredential]` DomainAdministratorCredential** _(Required)_: Specifies
  the credential for the account used to install the domain controller.
  This account must have permission to access the other domain controllers
  in the domain to be able replicate domain information.
* **`[PSCredential]` SafemodeAdministratorPassword** _(Required)_: Password for the administrator account when the computer is started in Safe Mode.
* **`[String]` DatabasePath** _(Write)_: Specifies the fully qualified, non-Universal Naming Convention (UNC) path to a directory on a fixed disk of the local computer that contains the domain database.
* **`[String]` LogPath** _(Write)_: Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the log file for this operation will be written.
* **`[String]` SysvolPath** _(Write)_: Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the Sysvol file will be written.
* **`[String]` SiteName** _(Write)_: Specify the name of an existing site where new domain controller will be placed.
* **`[String]` InstallationMediaPath** _(Write)_: Specify the path of the folder containg the Installation Media created in NTDSutil.
* **`[String]` IsGlobalCatalog** _(Write)_: Specifies if the domain controller will be a Global Catalog (GC).
* **`[String]` Ensure** _(Read)_: The state of the Domain Controller, returned with Get.

### **xADDomainDefaultPasswordPolicy**

The xADDomainDefaultPasswordPolicy DSC resource will manage an Active Directory domain's default password policy.

* **`[String]` DomainName** _(Key)_: Name of the domain to which the password policy will be applied.
* **`[Boolean]` ComplexityEnabled** _(Write)_: Whether password complexity is enabled for the default password policy.
* **`[UInt32]` LockoutDuration** _(Write)_: Length of time that an account is locked after the number of failed login attempts (minutes).
* **`[UInt32]` LockoutObservationWindow** _(Write)_: Maximum time between two unsuccessful login attempts before the counter is reset to 0 (minutes).
* **`[UInt32]` LockoutThreshold** _(Write)_: Number of unsuccessful login attempts that are permitted before an account is locked out.
* **`[UInt32]` MinPasswordAge** _(Write)_: Minimum length of time that you can have the same password (minutes).
* **`[UInt32]` MaxPasswordAge** _(Write)_: Maximum length of time that you can have the same password (minutes).
* **`[UInt32]` MinPasswordLength** _(Write)_: Minimum number of characters that a password must contain.
* **`[UInt32]` PasswordHistoryCount** _(Write)_: Number of previous passwords to remember.
* **`[Boolean]` ReversibleEncryptionEnabled** _(Write)_: Whether the directory must store passwords using reversible encryption.
* **`[String]` DomainController** _(Write)_: An existing Active Directory domain controller used to perform the operation.
* **`[PSCredential]` Credential** _(Write)_: User account credentials used to perform the operation.

### **xADDomainTrust**

* **`[String]` TargetDomainName** _(Key)_: Name of the AD domain that is being trusted
* **`[PSCredential]` TargetDomainAdministratorCredential** _(Required)_: Credentials to authenticate to the target domain
* **`[String]` Ensure** _(Write)_: Specifies whether the domain trust is present or absent
* **`[String]` TrustType** _(Write)_: Type of trust
* **`[String]` TrustDirection** _(Write)_: Direction of trust, the values for which may be Bidirectional,Inbound, or Outbound
* **`[String]` SourceDomainName** _(Write)_: Name of the AD domain that is requesting the trust

### **xADGroup**

The xADGroup DSC resource will manage groups within Active Directory.

* **`[String]` GroupName** _(Key)_: Name of the Active Directory group to manage.
* **`[String]` Category** _(Write)_: This parameter sets the GroupCategory property of the group.
  * Valid values are 'Security' and 'Distribution'.
  * If not specified, it defaults to 'Security'.
* **`[String]` GroupScope** _(Write)_: Specifies the group scope of the group.
  * Valid values are 'DomainLocal', 'Global' and 'Universal'.
  * If not specified, it defaults to 'Global'.
* **`[String]` Path** _(Write)_: Path in Active Directory to place the group, specified as a Distinguished Name (DN).
* **`[String]` Description** _(Write)_: Specifies a description of the group object.
* **`[String]` DisplayName** _(Write)_: Specifies the display name of the group object.
* **`[String[]]` Members** _(Write)_: Specifies the explicit AD objects that should comprise the group membership.
  * If not specified, no group membership changes are made.
  * If specified, all undefined group members will be removed the AD group.
  * This property cannot be specified with either 'MembersToInclude' or 'MembersToExclude'.
  * To use other domain's members, specify the distinguished name of the object.
* **`[String[]]` MembersToInclude** _(Write)_: Specifies AD objects that must be in the group.
  * If not specified, no group membership changes are made.
  * If specified, only the specified members are added to the group.
  * If specified, no users are removed from the group using this parameter.
  * To use other domain's members, specify the distinguished name of the object.
  * This property cannot be specified with the 'Members' parameter.
* **`[String[]]` MembersToExclude** _(Write)_: Specifies AD objects that _must not_ be in the group.
  * If not specified, no group membership changes are made.
  * If specified, only those specified are removed from the group.
  * If specified, no users are added to the group using this parameter.
  * To use other domain's members, specify the distinguished name of the object.
  * This property cannot be specified with the 'Members' parameter.
* **`[String]` MembershipAttribute** _(Write)_: Defines the AD object attribute that is used to determine group membership.
  * Valid values are 'SamAccountName', 'DistinguishedName', 'ObjectGUID' and 'SID'.
  * If not specified, it defaults to 'SamAccountName'.
  * You cannot mix multiple attribute types.
* **`[String]` ManagedBy** _(Write)_: Specifies the user or group that manages the group object.
  * Valid values are the user's or group's DistinguishedName, ObjectGUID, SID or SamAccountName.
* **`[String]` Notes** _(Write)_: The group's info attribute.
* **`[String]` Ensure** _(Write)_: Specifies whether the group is present or absent.
  * Valid values are 'Present' and 'Absent'.
  * It not specified, it defaults to 'Present'.
* **`[String]` DomainController** _(Write)_: An existing Active Directory domain controller used to perform the operation.
  * If not running on a domain controller, this is required.
* **`[PSCredential]` Credential** _(Write)_: User account credentials used to perform the operation.
  * If not running on a domain controller, this is required.
* **`[Boolean]` RestoreFromRecycleBin** _(Write)_: Try to restore the
  organizational unit from the recycle bin before creating a new one.

### **xADKDSKey**

The xADKDSKey DSC resource will manage KDS Root Keys within Active Directory.

* **`[String]` EffectiveTime** _(Key)_: Specifies the Effective time when a KDS root key can be used.
  * There is a 10 hour minimum from creation date to allow active directory to properly replicate across all domain controllers. For this reason, the date must be set in the future for creation.
  * While this parameter accepts a string, it will be converted into a DateTime object. This will also try to take into account cultural settings. This is to disallow things like `(Get-Date).AddHours(-10)`, otherwise we can't find the right KDS key since the effective date will always be changing
    * Example: '05/01/1999 13:00 using default or 'en-US' culture would be May 1st, but using 'de-DE' culture would be 5th of January. The culture is automatically pulled from the operating system and this can be checked using 'Get-Culture'
* **`[String]` Ensure** _(Write)_: Specifies if this KDS Root Key should be present or absent
  * If not specified, this value defaults to Present.
* **`[Boolean]` AllowUnsafeEffectiveTime** _(Write)_: This option will allow you to create a KDS root key if EffectiveTime is set in the past.
  * This may cause issues if you are creating a Group Managed Service Account right after you create the KDS Root Key. In order to get around this, you must create the KDS Root Key using a date in the past. This should be used at your own risk and should only be used in lab environments.
* **`[Boolean]` ForceRemove** _(Write)_: This option will allow you to remove a KDS root key if there is only one key left.
  * It should not break your Group Managed Service Accounts (gMSAs), but if the gMSA password expires and it needs to request a new password, it will not be able to generate a new password until a new KDS Root Key is installed and ready for use. Because of this, the last KDS Root Key will not be removed unless this option is specified
* **`[String]` DistinguishedName** _(Read)_: Specifies the Distinguished Name (DN) of the KDS root key.
  * The KDS Root Key is stored in 'CN=Master Root Keys,CN=Group Key Distribution Service,CN=Services,CN=Configuration' at the Forest level. This is also why replication needs 10 hours to occur before using the KDS Root Key as a safey measure.
  * Cannot be specified in the resource. Returned by Get and Compare.
* **`[DateTime]` CreationTime** _(Read)_: Specifies the Creation date and time of the KDS root key for informational purposes
* **`[String]` KeyId** _(Read)_: Specifies the KeyID of the KDS root key. This is the Common Name (CN) within Active Directory and is required to build the Distinguished Name

### **xADManagedServiceAccount**

The xADManagedServiceAccount DSC resource will manage Managed Service Accounts (MSAs) within Active Directory.

* **`[String]` ServiceAccountName** _(Key)_: Specifies the Security Account Manager (SAM) account name of the managed service account (ldapDisplayName 'sAMAccountName').
  * To be compatible with older operating systems, create a SAM account name that is 20 characters or less.
  * Once created, the user's SamAccountName and CN cannot be changed.
* **`[String]` Ensure** _(Write)_: Specifies whether the user account is created or deleted.
  * If not specified, this value defaults to Present.
* **`[String]` AccountType** _(Write)_: The type of managed service account.
  * Single will create a Single Managed Service Account (sMSA) and Group will create a Group Managed Service Account (gMSA).
  * If not specified, this vaule defaults to Single.
* **`[String]` AccountTypeForce** _(Write)_: Specifies whether or not to remove the service account and recreate it when going from single MSA to group MSA and vice-versa
  * If not specified, this value defaults to False.
* **`[String]` Path** _(Write)_: Specifies the X.500 path of the Organizational Unit (OU) or container where the new object is created. Specified as a Distinguished Name (DN).
* **`[String]` Description** _(Write)_: Specifies a description of the object (ldapDisplayName 'description')
* **`[String]` DisplayName** _(Write)_: Specifies the display name of the object (ldapDisplayName 'displayName')
* **`[String]` Members** _(Write)_: Specifies the members of the object (ldapDisplayName 'PrincipalsAllowedToRetrieveManagedPassword').
  * Only used when 'Group' is selected for 'AccountType'
* **`[String]` MembershipAttribute** _(Write)_: Active Directory attribute used to perform membership operations for Group Managed Service Accounts (gMSAs)
  * If not specified, this value defaults to SamAccountName
  * Only used when 'Group' is selected for 'AccountType'
* **`[PSCredential]` Credential** _(Write)_: Specifies the user account credentials to use to perform this task.
  * This is only required if not executing the task on a domain controller or using the -DomainController parameter.
* **`[String]` DomainController** _(Write)_: Specifies the Active Directory Domain Controller instance to use to perform the task.
  * This is only required if not executing the task on a domain controller.
* **`[String]` Enabled** _(Read)_: Specifies whether the user account is enabled or disabled.
* **`[String]` DistinguishedName** _(Read)_: Specifies the Distinguished Name of the Service Account
  * Cannot be specified in the resource. Returned by Get and Compare.

### **xADObjectPermissionEntry**

The xADObjectPermissionEntry DSC resource will manage access control lists on Active Directory objects. The resource is
designed to to manage just one entry in the list of permissios (ACL) for one AD object. It will only interact with the
one permission and leave all others as they were. The resource can be used multiple times to add multiple entries into
one ACL.

* **Ensure**: Indicates if the access will be added (Present) or will be removed (Absent). Default is 'Present'.
* **Path**: Active Directory path of the object specified as a Distinguished Name.
* **IdentityReference**: Indicates the identity of the principal for the ACE. Use the notation DOMAIN\SamAccountName for the identity.
* **ActiveDirectoryRights**: A combination of one or more of the ActiveDirectoryRights enumeration values that specifies the rights of the access rule. Default is 'GenericAll'. Valid values: { AccessSystemSecurity | CreateChild | Delete | DeleteChild | DeleteTree | ExtendedRight | GenericAll | GenericExecute | GenericRead | GenericWrite | ListChildren | ListObject | ReadControl | ReadProperty | Self | Synchronize | WriteDacl | WriteOwner | WriteProperty }
* **AccessControlType**: Indicates whether to Allow or Deny access to the target object.
* **ObjectType**: The schema GUID of the object to which the access rule applies. If the permission entry shouldn't be restricted to a specific object type, use the zero guid: 00000000-0000-0000-0000-000000000000.
* **ActiveDirectorySecurityInheritance**: One of the 'ActiveDirectorySecurityInheritance' enumeration values that specifies the inheritance type of the access rule. { All | Children | Descendents | None | SelfAndChildren }.
* **InheritedObjectType**: The schema GUID of the child object type that can inherit this access rule. If the permission entry shouldn't be restricted to a specific inherited object type, use the zero guid: 00000000-0000-0000-0000-000000000000.

### **xADOrganizationalUnit**

The xADOrganizational Unit DSC resource will manage OUs within Active Directory.

* **`[String]` Name** _(Key)_: Name of the Active Directory organizational unit to manage.
* **`[String]` Path** _(Key)_: Specified the X500 (DN) path of the organizational unit's parent object.
* **`[String]` Description** _(Write)_: The OU description property.
* **`[Boolean]` ProtectedFromAccidentalDeletion** _(Write)_: Valid values are $true and $false. If not specified, it defaults to $true.
* **`[String]` Ensure** _(Write)_: Specifies whether the OU is present or absent. Valid values are 'Present' and 'Absent'. It not specified, it defaults to 'Present'.
* **`[PSCredential]` Credential** _(Write)_: User account credentials used to perform the operation. Note: _This is required if not running on a domain controller_.
* **`[Boolean]` RestoreFromRecycleBin** _(Write)_: Try to restore the organizational unit from the recycle bin before creating a new one.

### **xADRecycleBin**

The xADRecycleBin DSC resource will enable the Active Directory Recycle Bin feature for the target forest.
This resource first verifies that the forest mode is Windows Server 2008 R2 or greater.  If the forest mode
is insufficient, then the resource will exit with an error message.  The change is executed against the
Domain Naming Master FSMO of the forest.
(Note: This resource is compatible with a Windows 2008 R2 or above target node.)

* **`[String]` ForestFQDN** _(Key)_:  Fully qualified domain name of forest to enable Active Directory Recycle Bin.
* **`[PSCredential]` EnterpriseAdministratorCredential** _(Required)_:  Credential with Enterprise Administrator rights to the forest.
* **`[Boolean]` RecycleBinEnabled** _(Read)_:  Read-only. Returned by Get.
* **`[String]` ForestMode** _(Read)_:  Read-only. Returned by Get.

### **xADReplicationSite**

* **`[String]` Name** _(Key)_: Specifies the name of the AD replication site.
* **`[String]` Ensure** _(Write)_: Specifies if the AD replication site should be added or remove. Default value is 'Present'. { *Present* | Absent }.
* **`[Boolean]` RenameDefaultFirstSiteName** _(Write)_: Specify if the Default-First-Site-Name should be renamed, if it exists. Dafult value is 'false'.

### **xADReplicationSiteLink**

* **`[String]` Name** _(Key)_: Specifies the name of the AD replication site link.
* **`[Sint32]` Cost** _(Write)_: Specifies the cost to be placed on the site link.
* **`[String]` Description** _(Write)_: This parameter sets the value of the Description property for the object.
* **`[Sint32]` ReplicationFrequencyInMinutes** _(Write)_: Species the frequency (in minutes) for which replication will occur where this site link is in use between sites.
* **`[String[]]` SitesIncluded** _(Write)_: Specifies the list of sites included in the site link.
* **`[String[]]` SitesExcluded** _(Write)_: Specifies the list of sites to excluded from the site link.
* **`[String]` Ensure** _(Write)_: Specifies if the site link is created or deleted. Default value is empty.

### **xADReplicationSubnet**

The xADReplicationSubnet DSC resource will manage replication subnets.

* **`[String]` Name** _(Key)_: The name of the AD replication subnet, e.g. 10.0.0.0/24.
* **`[String]` Site** _(Required)_: The name of the assigned AD replication site, e.g. Default-First-Site-Name.
* **`[String]` Ensure** _(Write)_: Specifies if the AD replication subnet should be added or remove. Default value is 'Present'.
* **`[String]` Location** _(Write)_: The location for the AD replication site. Default value is empty.

### **xADServicePrincipalName**

The xADServicePrincipalName DSC resource will manage service principal names.

* **`[String]` ServicePrincipalName** _(Key)_: The full SPN to add or remove, e.g. HOST/LON-DC1.
* **`[String]` Ensure** _(Write)_: Specifies if the service principal name should be added or remove. Default value is 'Present'. { *Present* | Absent }.
* **`[String]` Account** _(Write)_: The user or computer account to add or remove the SPN, e.b. User1 or LON-DC1$. Default value is ''. If Ensure is set to Present, a value must be specified.

### **xADUser**

* **`[String]` DomainName** _(Key)_: Name of the domain to which the user will be added.
  * The Active Directory domain's fully-qualified domain name must be specified, i.e. contoso.com.
  * This parameter is used to query and set the user's account password.
* **`[String]` UserName** _(Key)_: Specifies the Security Account Manager (SAM) account name of the user.
  * To be compatible with older operating systems, create a SAM account name that is 20 characters or less.
  * Once created, the user's SamAccountName and CN cannot be changed.
* **`[PSCredential]` Password** _(Write)_: Password value for the user account.
  * _If the account is enabled (default behaviour) you must specify a password._
  * _You must ensure that the password meets the domain's complexity requirements._
* **`[String]` Ensure** _(Write)_: Specifies whether the given user is present or absent.
  * If not specified, this value defaults to Present.
* **`[String]` DomainController** _(Write)_: Specifies the Active Directory Domain Services instance to connect to.
  * This is only required if not executing the task on a domain controller.
* **`[PSCredential]` DomainAdministratorCredential** _(Write)_: User account credentials used to perform the task.
  * This is only required if not executing the task on a domain controller or using the -DomainController parameter.
* **`[String]` CommonName** _(Write)_: Specifies the user's CN of the user account.
  * If not specified, this defaults to the ___UserName___ value.
* **`[String]` UserPrincipalName** _(Write)_: Each user account has a user principal name (UPN) in the format [user]@[DNS-domain-name].
* **`[String]` DisplayName** _(Write)_: Specifies the display name of the user object.
* **`[String]` Path** _(Write)_: The organizational unit to place the user in.
* **`[String]` GivenName** _(Write)_: Specifies the user's first or given name.
* **`[String]` Initials** _(Write)_: Specifies the initials that represent part of a user's name.
* **`[String]` Surname** _(Write)_: Specifies the user's last name or surname.
* **`[String]` Description** _(Write)_: Specifies a description of the user object.
* **`[String]` StreetAddress** _(Write)_: Specifies the user's street address.
* **`[String]` POBox** _(Write)_: Specifies the user's post office box number.
* **`[String]` City** _(Write)_: Specifies the user's town or city.
* **`[String]` State** _(Write)_: Specifies the user's state or province.
* **`[String]` PostalCode** _(Write)_: Specifies the user's postal code or zip code.
* **`[String]` Country** _(Write)_: Specifies the country or region code for the user's language of choice.
  * This should be specified as the country's two character ISO-3166 code.
* **`[String]` Department** _(Write)_: Specifies the user's department.
* **`[String]` Division** _(Write)_: Specifies the user's division.
* **`[String]` Company** _(Write)_: Specifies the user's company.
* **`[String]` Office** _(Write)_: Specifies the location of the user's office or place of business.
* **`[String]` JobTitle** _(Write)_: Specifies the user's job title.
* **`[String]` EmailAddress** _(Write)_: Specifies the user's e-mail address.
* **`[String]` EmployeeID** _(Write)_: Specifies the user's employee ID.
* **`[String]` EmployeeNumber** _(Write)_: Specifies the user's employee number.
* **`[String]` HomeDirectory** _(Write)_: Specifies a user's home directory path.
* **`[String]` HomeDrive** _(Write)_: Specifies a drive that is associated with the UNC path defined by the HomeDirectory property.
  * The drive letter is specified as "[DriveLetter]:" where [DriveLetter] indicates the letter of the drive to associate.
  * The [DriveLetter] must be a single, uppercase letter and the colon is required.
* **`[String]` HomePage** _(Write)_: Specifies the URL of the home page of the user object.
* **`[String]` ProfilePath** _(Write)_: Specifies a path to the user's profile.
  * This value can be a local absolute path or a Universal Naming Convention (UNC) path.
* **`[String]` LogonScript** _(Write)_: Specifies a path to the user's log on script.
  * This value can be a local absolute path or a Universal Naming Convention (UNC) path.
* **`[String]` Notes** _(Write)_: Sets the notes attribute.
* **`[String]` OfficePhone** _(Write)_: Specifies the user's office telephone number.
* **`[String]` MobilePhone** _(Write)_: Specifies the user's mobile phone number.
* **`[String]` Fax** _(Write)_: Specifies the user's fax phone number.
* **`[String]` Pager** _(Write)_: Specifies the user's pager number.
* **`[String]` IPPhone** _(Write)_: Specifies the user's IP telephony number.
* **`[String]` HomePhone** _(Write)_: Specifies the user's home telephone number.
* **`[Boolean]` Enabled** _(Write)_: Specifies if an account is enabled.
  * An enabled account requires a password.
* **`[String]` Manager** _(Write)_: Specifies the user's manager.
  * This value can be specified as a DN, ObjectGUID, SID or SamAccountName.
* **`[Boolean]` PasswordNeverExpires** _(Write)_: Specifies whether the password of an account can expire.
  * If not specified, this value defaults to False.
* **`[Boolean]` CannotChangePassword** _(Write)_: Specifies whether the account password can be changed.
  * If not specified, this value defaults to False.
* **`[String]` PasswordAuthentication** _(Write)_: Specifies the authentication context used when testing users' passwords.
  * The 'Negotiate' option supports NTLM authentication - which may be required when testing users' passwords when Active Directory Certificate Services (ADCS) is deployed.
* **`[Boolean]` PasswordNeverResets** _(Write)_: Specifies whether existing user's password should be reset (default $false).
* **`[Boolean]` TrustedForDelegation** _(Write)_: Specifies whether an account is trusted for Kerberos delegation (default $false).
* **`[Boolean]` RestoreFromRecycleBin** _(Write)_: Try to restore the user object from the recycle bin before creating a new one.
* **`[String]` DistinguishedName** _(Read)_: The user distinguished name, returned with Get.
* **`[String]` ServicePrincipalNames** _(Write)_: Specifies the service principal names for the user account.

### **xWaitForADDomain**

* **`[String]` DomainName** _(Key)_: Name of the remote domain.
* **`[UInt64]` RetryIntervalSec** _(Write)_: Interval to check for the domain's existence.
* **`[UInt32]` RetryCount** _(Write)_: Maximum number of retries to check for the domain's existence.
* **`[UInt32]` RebootRetryCount** _(Write)_: Maximum number of reboots to process in order to wait for a domain's existence.

### **xADForestProperties**

The xADForestProperties DSC resource will manage User Principal Name (UPN) suffixes and Service Principal Name (SPN) suffixes in a forest.

* **Credential**: (optional) "Specifies the user account credentials to use to perform this task.
* **ForestName**: Specifies the target Active Directory forest for the change.
* **ServicePrincipalNameSuffix**: (optional) The Service Principal Name Suffix(es) to be explicitly defined in the forest and replace existing
    SPNs. Cannot be used with ServicePrincipalNameSuffixToAdd or ServicePrincipalNameSuffixToRemove.
* **ServicePrincipalNameSuffixToAdd**: (optional) The Service Principal Name Suffix(es) to add in the forest. Cannot be used with ServicePrincipalNameSuffix.
* **ServicePrincipalNameSuffixToRemove**: (optional) The Service Principal Name Suffix(es) to remove in the forest. Cannot be used with ServicePrincipalNameSuffix.
* **UserPrincipalNameSuffix**: (optional) The User Principal Name Suffix(es) to be explicitly defined in the forest and replace existing
    UPNs. Cannot be used with UserPrincipalNameSuffixToAdd or UserPrincipalNameSuffixToRemove.
* **UserPrincipalNameSuffixToAdd**: (optional) The User Principal Name Suffix(es) to add in the forest. Cannot be used with UserPrincipalNameSuffix.
* **UserPrincipalNameSuffixToRemove**: (optional) The User Principal Name Suffix(es) to remove in the forest. Cannot be used with UserPrincipalNameSuffix.
