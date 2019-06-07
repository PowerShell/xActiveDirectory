# culture='en-US'
ConvertFrom-StringData @'
    ForestNotFound             = Cannot contact forest '{0}'. Check the spelling of the Forest FQDN and make sure that a domain controller is available on the network.
    CredentialError            = Credential error. Check the username and password used.
    GetUnhandledException      = Unhandled exception getting Recycle Bin status for forest '{0}'.
    SetUnhandledException      = Unhandled exception setting Recycle Bin status for forest '{0}'.
    TestUnhandledException     = Unhandled exception testing Recycle Bin status for forest '{0}'.
    ForestFunctionalLevelError = Forest functional level '{0}' does not meet minimum requirement of Windows2008R2Forest or greater.
    RecycleBinEnabled          = Active Directory Recycle Bin is enabled.
    RecycleBinNotEnabled       = Active Directory Recycle Bin is not enabled.
    EnablingRecycleBin         = Enabling Active Directory Recycle Bin.
'@
