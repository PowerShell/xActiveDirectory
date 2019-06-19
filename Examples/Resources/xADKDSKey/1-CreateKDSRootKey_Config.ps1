<#PSScriptInfo
.VERSION 1.0
.GUID 6c3b1da3-f139-42e5-89e9-b9c9986122c8
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT (c) Microsoft Corporation. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/PowerShell/xActiveDirectory/blob/master/LICENSE
.PROJECTURI https://github.com/PowerShell/xActiveDirectory
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
.PRIVATEDATA
#>

#Requires -module xActiveDirectory

<#
    .DESCRIPTION
        This configuration will create a KDS root key. If the date is set to a time
        slightly ahead in the future, the key won't be usable for at least 10 hours
        from the creation time.
#>

Configuration CreateKDSRootKey_Config
{
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADKDSKey 'ExampleKDSRootKey'
        {
            Ensure        = 'Present'
            EffectiveTime = '1/1/2030 13:00'
            # Date must be set to at time in the future
        }
    }
}
