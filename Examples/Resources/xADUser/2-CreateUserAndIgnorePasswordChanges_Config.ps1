<#PSScriptInfo
.VERSION 1.0
.GUID b293f599-2660-424d-8200-61d399e44257
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
        This configuration will create a user with a password and then ignore
        when the password has changed. This might be used with a traditional
        user account where a managed password is not desired.
#>

Configuration CreateUserAndIgnorePasswordChanges_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Password
    )

    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        xADUser 'Contoso\ExampleUser'
        {
            Ensure              = 'Present'
            UserName            = "ExampleUser"
            Password            = $Password
            PasswordNeverResets = $true
            DomainName          = "contoso.com"
            Path                = "CN=Users,DC=contoso,DC=com"
        }
    }
}
