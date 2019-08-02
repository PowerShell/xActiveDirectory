New-xDscResource -Name MSFT_xADOptionalFeature -FriendlyName xADOptionalFeature -ModuleName xActiveDirectory -Path . -Force -Property @(
    New-xDscResourceProperty -Name ForestFQDN -Type String -Attribute Key
    New-xDscResourceProperty -Name FeatureName -Type String -Attribute Key
    New-xDscResourceProperty -Name EnterpriseAdministratorCredential -Type PSCredential -Attribute Required
    New-xDscResourceProperty -Name Enabled -Type Boolean -Attribute Read
    New-xDscResourceProperty -Name ForestMode -Type String -Attribute Read
)
