<#
    .EXAMPLE
        In this example we will create a KDS root key in the past. This will allow you to use the
        key right away, but if all the domain controllers haven't replicated yet, there may be issues
        when retrieving the gMSA password. Use with caution
#>

configuration CreateKDSRootKeyInPast
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADKDSKey ExampleKDSRootKeyInPast
        {
            Ensure                   = 'Present'
            EffectiveTime            = '1/1/1999 13:00'
            AllowUnsafeEffectiveTime = $true # Use with caution
        }
    }
}
