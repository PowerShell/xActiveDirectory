<#
    .EXAMPLE
        In this example we will remove the last KDS root key. Use with caution. If you have
        gMSAs installed on the network, they will not be able to reset the their passwords
        and it may cause services to come down
#>

configuration CreateKDSRootKeyRemoveLastKey
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADKDSKey ExampleKDSRootKeyForceRemove
        {
            Ensure        = 'Absent'
            EffectiveTime = '1/1/2030 13:00'
            ForceRemove   = $true # This will allow you to remove the key if it's the last one
        }
    }
}
