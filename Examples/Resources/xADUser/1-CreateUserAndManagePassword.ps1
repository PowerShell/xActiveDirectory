<#
    .EXAMPLE
        In this example we will create a user with a managed password.
        This might be used to manage the lifecycle of a service account.
#>

configuration CreateUserAndManagePassword
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
            Ensure     = 'Present'
            UserName   = "ExampleUser"
            Password   = $Password
            DomainName = "contoso.com"
            Path       = "CN=Users,DC=contoso,DC=com"
        }
    }
}
