# culture="en-US"
ConvertFrom-StringData @'
    QueryingFineGrainedPasswordPolicy               = Querying Active Directory domain '{0}' fine grained password policy. (ADFGPP0001)
    UpdatingFineGrainedPasswordPolicy               = Updating Active Directory domain '{0}' fine grained password policy. (ADFGPP0002)
    CreatingFineGrainedPasswordPolicy               = Creating Active Directory domain '{0}' fine grained password policy. (ADFGPP0003)
    RemovingFineGrainedPasswordPolicy               = Removing Active Directory domain '{0}' fine grained password policy. (ADFGPP0004)
    SettingPasswordPolicyValue                      = Setting fine grained password policy '{0}' property to '{1}'. (ADFGPP0005)
    ResourceInDesiredState                          = Resource '{0}' is in the desired state. (ADFGPP0006)
    ResourceNotInDesiredState                       = Resource '{0}' is NOT in the desired state. (ADFGPP0007)
    ResourceConfigurationError                      = Error setting resource '{0}'. (ADFGPP0008)
    RetrieveFineGrainedPasswordPolicyError          = Error retrieving fine grained password policy '{0}'. (ADFGPP0009)
    RetrieveFineGrainedPasswordPolicySubjectError   = Error retrieving fine grained password policy subject '{0}'. (ADFGPP0010)
    ResourceExistsButShouldNotMessage               = Fine grained password policy '{0}' exists but should not. (ADFGPP0011)
    ResourceDoesNotExistButShouldMessage            = Fine grained password policy '{0}' does not exist but should. (ADFGPP0012)
    ProtectedFromAccidentalDeletionRemove           = Attempting to remove the protection for accidental deletion. (ADFGPP0013)
    ProtectedFromAccidentalDeletionUndefined        = ProtectedFromAccidentalDeletion is not defined to false, delete may fail if not explicitly set false. (ADFGPP0014)
    AddingNewSubjects                               = Adding new subjects to policy '{0}', count '{1}'. (ADFGPP0015)
    RemovingExistingSubjects                        = Removing existing subjects from policy '{0}', count '{1}'. (ADFGPP0016)
'@
