# culture="en-US"
ConvertFrom-StringData @'
    QueryDomain                        = Querying for domain '{0}'. (ADD0001)
    ADServerDown                       = The AD Server for domain '{0}' is currently down. (ADD0002)
    DomainFound                        = Active Directory domain '{0}' found. (ADD0003)
    CreatingChildDomain                = Creating domain '{0}' as a child of domain '{1}'. (ADD0004)
    CreatedChildDomain                 = Child domain '{0}' created. (ADD0005)
    CreatingForest                     = Creating AD forest '{0}'. (ADD0006)
    CreatedForest                      = AD forest '{0}' created. (ADD0007)
    DomainInDesiredState               = The domain '{0}' is in the desired state. (ADD0008)
    DomainNotInDesiredState            = The domain '{0}' is NOT in the desired state. (ADD0009)
    RetryingGetADDomain                = Attempt {0} of {1} to call Get-ADDomain failed, retrying in {2} seconds. (ADD0010)
    SysVolPathDoesNotExistError        = The expected SysVol Path '{0}' does not exist. (ADD0011)
    MaxDomainRetriesReachedError       = Maximum Get-ADDomain retries reached and the domain did not respond. (ADD0012)
    GetAdDomainUnexpectedError         = Error getting AD domain '{0}'. (ADD0013)
    GetAdForestUnexpectedError         = Error getting AD forest '{0}'. (ADD0014)
'@
