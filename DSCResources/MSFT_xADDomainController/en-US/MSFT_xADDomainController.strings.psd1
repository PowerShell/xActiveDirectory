ConvertFrom-StringData @'
    ResolveDomainName = Resolving the domain name '{0}'. (ADDC0001)
    DomainPresent = The domain '{0}' is present. Looking for domain controllers.
    FoundDomainController = Found the domain controller '{0}' in the domain '{1}'.
    AlreadyDomainController = The current node '{0}' is already a domain controller for the domain '{1}'.
    FailedEvaluatingDomainController = Could not evaluate if the node is a domain controller.
    NotDomainController = The current node '{0}' is not a domain controller.
    IsDomainController = The current node '{0}' is a domain controller for the domain '{1}'.
    MissingDomain = Current node could not find the domain '{0}'.
    Promoting = Promoting the current node to be a domain controller for the domain '{1}'.
    Promoted = The current node '{0}' has been promoted to a domain controller for the domain '{1}'.
    AddGlobalCatalog = Adding Global Catalog to the domain controller.
    RemoveGlobalCatalog = Removing Global Catalog from the domain controller.
    MovingDomainController = Moving Domain Controller from site '{0}' to site '{1}'.
    FailedToFindSite = The site '{0}' could not be found in the domain '{1}'.
    TestingConfiguration = Determine the state of the domain controller on the current node '{0}' in the domain '{1}'.
    WrongSite = The domain controller is in the site '{0}', but expected it to be in the site '{1}'.
'@
