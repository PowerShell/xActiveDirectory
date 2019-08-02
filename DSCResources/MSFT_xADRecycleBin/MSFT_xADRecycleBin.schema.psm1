Configuration xADRecycleBin {
    Param(
        [parameter(Mandatory = $true)]
        [System.String]
        $ForestFQDN,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EnterpriseAdministratorCredential
    )


    xADOptionalFeature RecycleBin
    {
        FeatureName = "Recycle Bin Feature"
        EnterpriseAdministratorCredential = $EnterpriseAdministratorCredential
        ForestFQDN = $ForestFQDN
    }
}
