<#
    .EXAMPLE
        In this example we will create a user with a password and then ignore when the password has changed.
        This might be used with a traditional user account where a managed password is not desired.
#>

configuration CreateUserAndIgnorePasswordChanges
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Password
    )

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADUser Contoso\ExampleUser
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
