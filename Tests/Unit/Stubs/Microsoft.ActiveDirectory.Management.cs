namespace Microsoft.ActiveDirectory.Management
{
    public enum ADDomainMode
    {
        Windows2000Domain,
        Windows2003InterimDomain,
        Windows2003Domain,
        Windows2008Domain,
        Windows2008R2Domain,
        Windows2012Domain,
        Windows2012R2Domain,
        Windows2016Domain,
        UnknownDomain
    }

    public enum ADForestMode
    {
        Windows2000Forest,
        Windows2003InterimForest,
        Windows2003Forest,
        Windows2008Forest,
        Windows2008R2Forest,
        Windows2012Forest,
        Windows2012R2Forest,
        Windows2016Forest,
        UnknownForest
    }

    public enum ADKerberosEncryptionType
    {
        AES128,
        AES256,
        DES,
        None,
        RC4
    }

    public enum ADSearchScope
    {
        Base,
        OneLevel,
        Subtree
    }

    public class ADAuthenticationPolicy
    {
        public ADAuthenticationPolicy():base(){}
        public ADAuthenticationPolicy(System.String Identity):base(){}
    }

    public class ADAuthenticationPolicySilo
    {
        public ADAuthenticationPolicySilo():base(){}
        public ADAuthenticationPolicySilo(System.String Identity):base(){}
    }

    public class ADAuthType
    {
        public ADAuthType():base(){}
    }

    public class ADComputer
    {
        public ADComputer():base(){}
        public ADComputer(System.String Identity):base(){}
    }

    public class ADDomain
    {
        public ADDomain():base(){}
        public ADDomain(System.String Identity):base(){}
    }

    public class ADForest
    {
        public ADForest():base(){}
        public ADForest(System.String Identity):base(){}
    }

    public class ADDomainController
    {
        public ADDomainController():base(){}
        public ADDomainController(System.String Identity):base(){}
        public string Site;
        public string Domain;
        public bool IsGlobalCatalog;
        public bool IsReadOnly;
        public string[] OperationMasterRoles;
    }

    public class ADDirectoryServer
    {
        public ADDirectoryServer():base(){}
        public ADDirectoryServer(System.String Identity):base(){}
    }

    public class ADIdentityNotFoundException : System.Exception
    {
        public ADIdentityNotFoundException():base(){}
    }

    public class ADObject
    {
        public ADObject():base(){}
        public ADObject(System.String Identity):base(){}
    }

    public class ADPrincipal
    {
        public ADPrincipal():base(){}
        public ADPrincipal(System.String Identity):base(){ SamAccountName = Identity; }
        public string SamAccountName { get; set; }

        public override string ToString()
        {
            return this.SamAccountName;
        }
    }

    public class ADReplicationSite
    {
        string site;
        public ADReplicationSite(System.String s){ site = s; }

        // Added so that MSFT_ADDomainController unit test works
        // 'When a domain controller is in the wrong site'
        //     'Should call the correct mocks to move the domain controller to the correct site'

        // The cmdlet Move-ADDirectoryServer accepts a string for the parameter
        // Site, but that string get converted to a ADReplicationSite object.
        // The ADReplicationSite object is what Pester sees and this method is
        // the only one exposed in the real ADReplicationSite object to return
        // the site name.
        public override string ToString()
        {
            return this.site;
        }
    }
}

namespace Microsoft.ActiveDirectory.Management.Commands
{
    public class ADCurrentDomainType
    {
        public ADCurrentDomainType():base(){}
    }

    public class ADMinimumDirectoryServiceVersion
    {
        public ADMinimumDirectoryServiceVersion():base(){}
    }

    public class ADDiscoverableService
    {
        public ADDiscoverableService():base(){}
    }

    public class ADCurrentForestType
    {
        public ADCurrentForestType():base(){}
    }
}
