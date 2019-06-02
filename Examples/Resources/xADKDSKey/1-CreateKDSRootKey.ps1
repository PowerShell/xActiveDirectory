<#
    .EXAMPLE
        In this example we will create a KDS root key. If you set the date to a time slightly
        ahead in the future, you won't be able to use the key for at least 10 hours from the creation
        time
#>

configuration CreateKDSRootKey
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADKDSKey ExampleKDSRootKey
        {
            Ensure        = 'Present'
            EffectiveTime = '1/1/2030 13:00'
            # Date must be set to at time in the future
        }
    }
}
