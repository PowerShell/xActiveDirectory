@{
    # Set up a mini virtual environment...
    PSDependOptions             = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
        }
    }

    InvokeBuild                 = 'latest'
    PSScriptAnalyzer            = 'latest'
    Pester                      = 'latest'
    Plaster                     = 'latest'
    ModuleBuilder               = '1.0.0'
    ChangelogManagement         = 'latest'
    Sampler                     = 'latest'
    'DscResource.Test'          = 'latest'
    'DscResource.AnalyzerRules' = 'latest'
    xDscResourceDesigner        = 'latest'
    MarkdownLinkCheck           = 'latest'

    # Modules required to compile examples.
    xFailoverCluster            = '1.14.1'

    # Modules required to run integration tests in local lab environment.
    PSDscResources              = '2.12.0.0'
    NetworkingDsc               = '7.4.0.0'
    ComputerManagementDsc       = '8.1.0'
}
