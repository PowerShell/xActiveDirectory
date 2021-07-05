$script:dscModuleName = 'ActiveDirectoryDsc'
$script:dscResourceName = 'MSFT_ADGroup'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

# Begin Testing

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        Set-StrictMode -Version 1.0

        # Load stub cmdlets and classes.
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\ActiveDirectory_2019.psm1') -Force

        $testPresentParams = @{
            GroupName   = 'TestGroup'
            GroupScope  = 'Global'
            Category    = 'Security'
            Path        = 'OU=OU,DC=contoso,DC=com'
            Description = 'Test AD group description'
            DisplayName = 'Test display name'
            SamAccountName = 'TestGroup'
            Ensure      = 'Present'
            Notes       = 'This is a test AD group'
            ManagedBy   = 'CN=User 1,CN=Users,DC=contoso,DC=com'
        }

        $mockGroupName = 'TestGroup'
        $mockGroupPath = 'OU=Test,DC=contoso,DC=com'
        $mockGroupDN = "CN=$mockGroupName,$mockGroupPath"

        $mockADGroupMembersAsADObjects = @(
            @{
                DistinguishedName = 'CN=User 1,CN=Users,DC=contoso,DC=com'
                ObjectGUID        = 'a97cc867-0c9e-4928-8387-0dba0c883b8e'
                SamAccountName    = 'USER1'
                ObjectSID         = 'S-1-5-21-1131554080-2861379300-292325817-1106'
                ObjectClass       = 'user'
            }
            @{
                DistinguishedName = 'CN=Group 1,CN=Users,DC=contoso,DC=com'
                ObjectGUID        = 'e2328767-2673-40b2-b3b7-ce9e6511df06'
                SamAccountName    = 'GROUP1'
                ObjectSID         = 'S-1-5-21-1131554080-2861379300-292325817-1206'
                ObjectClass       = 'group'
            }
            @{
                DistinguishedName = 'CN=Computer 1,CN=Users,DC=contoso,DC=com'
                ObjectGUID        = '42f9d607-0934-4afc-bb91-bdf93e07cbfc'
                SamAccountName    = 'COMPUTER1'
                ObjectSID         = 'S-1-5-21-1131554080-2861379300-292325817-6606'
                ObjectClass       = 'computer'
            }
            # This entry is used to represent a group member from a one-way trusted domain
            @{
                DistinguishedName = 'CN=S-1-5-21-8562719340-2451078396-046517832-2106,CN=ForeignSecurityPrincipals,DC=contoso,DC=com'
                ObjectGUID        = '6df78e9e-c795-4e67-a626-e17f1b4a0d8b'
                SamAccountName    = 'ADATUM\USER1'
                ObjectSID         = 'S-1-5-21-8562719340-2451078396-046517832-2106'
                ObjectClass       = 'foreignSecurityPrincipal'
            }
        )

        $mockADGroup = @{
            GroupName         = $mockGroupName
            GroupScope        = 'Global'
            GroupCategory     = 'Security'
            Path              = $mockGroupPath
            Description       = 'Test AD group description'
            DisplayName       = 'Test display name'
            SamAccountName    = $mockGroupName
            Info              = 'This is a test AD group'
            ManagedBy         = 'CN=User 1,CN=Users,DC=contoso,DC=com'
            DistinguishedName = "CN=$mockGroupName,$mockGroupPath"
            Members           = $mockADGroupMembersAsADObjects.SamAccountName
        }

        $mockADGroupChanged = @{
            GroupScope  = 'Universal'
            Description = 'Test AD group description changed'
            DisplayName = 'Test display name changed'
            SamAccountName = 'TestGroup2'
            ManagedBy   = 'CN=User 2,CN=Users,DC=contoso,DC=com'
        }

        $mockGetTargetResourceResults = @{
            GroupName         = $mockADGroup.GroupName
            GroupScope        = $mockADGroup.GroupScope
            Category          = $mockADGroup.GroupCategory
            Path              = $mockADGroup.Path
            Description       = $mockADGroup.Description
            DisplayName       = $mockADGroup.DisplayName
            SamAccountName    = $mockAdGroup.SamAccountName
            Notes             = $mockADGroup.Info
            ManagedBy         = $mockADGroup.ManagedBy
            DistinguishedName = $mockADGroup.DistinguishedName
            Members           = $mockADGroup.Members
            Ensure            = 'Present'
        }

        $mockGetTargetResourceResultsAbsent = @{
            GroupName         = $mockADGroup.GroupName
            GroupScope        = $null
            GroupCategory     = $null
            Path              = $null
            Description       = $null
            DisplayName       = $null
            SamAccountName    = $null
            Notes             = $null
            ManagedBy         = $null
            DistinguishedName = $null
            Members           = @()
            Ensure            = 'Absent'
        }

        $testDomainController = 'TESTDC'

        $testCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' `
            -ArgumentList 'DummyUser', (ConvertTo-SecureString -String 'DummyPassword' -AsPlainText -Force)

        Describe 'ADGroup\Get-TargetResource' -Tag 'Get' {
            BeforeAll {
                Mock -CommandName Assert-Module

                $getTargetResourceParameters = @{
                    GroupName = $mockADGroup.GroupName
                }
            }

            Context 'When the resource is Present' {
                BeforeAll {
                    Mock -CommandName Get-ADGroup -MockWith { $mockADGroup }
                    Mock -CommandName Get-ADGroupMember -MockWith { $mockADGroupMembersAsADObjects }
                }

                It 'Should return the correct result' {
                    $result = Get-TargetResource @getTargetResourceParameters

                    $result.Ensure | Should -Be 'Present'
                    $result.GroupName | Should -Be $mockADGroup.Name
                    $result.GroupScope | Should -Be $mockADGroup.GroupScope
                    $result.Category | Should -Be $mockADGroup.GroupCategory
                    $result.Path | Should -Be $mockADGroup.Path
                    $result.Description | Should -Be $mockADGroup.Description
                    $result.DisplayName | Should -Be $mockADGroup.DisplayName
                    $result.SamAccountName | Should -Be $mockADGroup.SamAccountName
                    $result.MembersToInclude | Should -BeNullOrEmpty
                    $result.MembersToExclude | Should -BeNullOrEmpty
                    $result.MembershipAttribute | Should -Be 'SamAccountName'
                    $result.ManagedBy | Should -Be $mockADGroup.ManagedBy
                    $result.Notes | Should -Be $mockADGroup.Info
                    $result.DistinguishedName | Should -Be $mockADGroup.DistinguishedName
                    $result.Members | Should -HaveCount $mockADGroupMembersAsADObjects.count
                    foreach ($member in $mockADGroupMembersAsADObjects)
                    {
                        $result.Members | Should -Contain $member.SamAccountName
                    }
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Assert-Module `
                        -ParameterFilter { $ModuleName -eq 'ActiveDirectory' }
                    Assert-MockCalled -CommandName Get-ADGroup `
                        -ParameterFilter { $Identity -eq $getTargetResourceParameters.GroupName } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ADGroupMember `
                        -ParameterFilter { $Identity -eq $getTargetResourceParameters.GroupName } `
                        -Exactly -Times 1
                }

                Context 'When the "Credential" parameter is specified' {
                    It 'Should not throw' {
                        { Get-TargetResource @getTargetResourceParameters -Credential $testCredential } |
                            Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-ADGroup `
                            -ParameterFilter { `
                                $Identity -eq $getTargetResourceParameters.GroupName -and `
                                $Credential -eq $testCredential } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-ADGroupMember `
                            -ParameterFilter { `
                                $Identity -eq $getTargetResourceParameters.GroupName -and `
                                $Credential -eq $testCredential } `
                            -Exactly -Times 1
                    }
                }

                Context 'When the "DomainController" parameter is specified' {
                    It 'Should not throw' {
                        { Get-TargetResource @getTargetResourceParameters -DomainController $testDomainController } |
                            Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-ADGroup `
                            -ParameterFilter { `
                                $Identity -eq $getTargetResourceParameters.GroupName -and `
                                $Server -eq $testDomainController } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Get-ADGroupMember `
                            -ParameterFilter { `
                                $Identity -eq $getTargetResourceParameters.GroupName -and `
                                $Server -eq $testDomainController } `
                            -Exactly -Times 1
                    }
                }

                Context "When 'Get-ADGroupMember' fails due to one-way trust" {
                    BeforeAll {
                        $oneWayTrustFullyQualifiedErrorId = `
                            'ActiveDirectoryServer:0,Microsoft.ActiveDirectory.Management.Commands.GetADGroupMember'

                        Mock -CommandName Get-ADGroupMember -MockWith { throw $oneWayTrustFullyQualifiedErrorId }
                        Mock -CommandName Get-ADObject -MockWith {
                            $memberADObject = $mockADGroupMembersAsADObjects[$script:getADObjectCallCount]
                            $script:getADObjectCallCount++
                            return $memberADObject
                        }
                        Mock -CommandName Resolve-SamAccountName `
                            -MockWith { $mockADGroupMembersAsADObjects[$script:getADObjectCallCount - 1].SamAccountName }
                    }

                    Context "When 'MembershipAttribute' is 'SamAccountName'" {
                        BeforeAll {
                            $script:getADObjectCallCount = 0
                        }

                        It 'Should return the correct result' {
                            $result = Get-TargetResource @getTargetResourceParameters -MembershipAttribute SamAccountName

                            $result.Members | Should -HaveCount $mockADGroupMembersAsADObjects.Count
                            foreach ($member in $result.Members)
                            {
                                $mockADGroupMembersAsADObjects.SamAccountName | Should -Contain $member
                            }
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Assert-Module `
                                -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Get-ADGroup `
                                -ParameterFilter { $Identity -eq $getTargetResourceParameters.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Get-ADGroupMember `
                                -ParameterFilter { $Identity -eq $getTargetResourceParameters.GroupName } `
                                -Exactly -Times 1
                        }
                    }

                    Context "When 'MembershipAttribute' is 'SID'" {
                        BeforeAll {
                            $script:getADObjectCallCount = 0
                        }

                        It 'Should return the correct result' {
                            $result = Get-TargetResource @getTargetResourceParameters -MembershipAttribute SID

                            $result.Members | Should -HaveCount $mockADGroupMembersAsADObjects.Count
                            foreach ($member in $result.Members)
                            {
                                $mockADGroupMembersAsADObjects.ObjectSID | Should -Contain $member
                            }
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Assert-Module `
                                -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Get-ADGroup `
                                -ParameterFilter { $Identity -eq $getTargetResourceParameters.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Get-ADGroupMember `
                                -ParameterFilter { $Identity -eq $getTargetResourceParameters.GroupName } `
                                -Exactly -Times 1
                        }
                    }
                }

                Context "When 'Get-ADGroup' throws an exception" {
                    BeforeAll {
                        Mock -CommandName Get-ADGroup -MockWith { Throw 'Error' }
                    }

                    It 'Should throw the correct error' {
                        { Get-TargetResource @getTargetResourceParameters } |
                            Should -Throw ($script:localizedData.RetrievingGroupADGroupError -f $mockADGroup.GroupName)
                    }
                }

                Context "When 'Get-ADGroupMember' throws an exception" {
                    BeforeAll {
                        Mock -CommandName Get-ADGroupMember -MockWith { Throw 'Error' }
                    }

                    It 'Should throw the correct error' {
                        { Get-TargetResource @getTargetResourceParameters } |
                            Should -Throw ($script:localizedData.RetrievingGroupMembersError -f $mockADGroup.GroupName)
                    }
                }
            }

            Context 'When the resource is Absent' {
                BeforeAll {
                    Mock -CommandName Get-ADGroup -MockWith {
                        throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException
                    }
                    Mock -CommandName Get-ADGroupMember
                }

                It 'Should return the correct result' {
                    $result = Get-TargetResource @getTargetResourceParameters
                    $result.Ensure | Should -Be 'Absent'
                    $result.GroupName | Should -Be $getTargetResourceParameters.GroupName
                    $result.GroupScope | Should -BeNullOrEmpty
                    $result.Category | Should -BeNullOrEmpty
                    $result.Path | Should -BeNullOrEmpty
                    $result.Description | Should -BeNullOrEmpty
                    $result.DisplayName | Should -BeNullOrEmpty
                    $result.SamAccountName | Should -BeNullOrEmpty
                    $result.Members | Should -BeNullOrEmpty
                    $result.MembersToInclude | Should -BeNullOrEmpty
                    $result.MembersToExclude | Should -BeNullOrEmpty
                    $result.MembershipAttribute | Should -Be 'SamAccountName'
                    $result.ManagedBy | Should -BeNullOrEmpty
                    $result.Notes | Should -BeNullOrEmpty
                    $result.DistinguishedName | Should -BeNullOrEmpty
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Assert-Module `
                        -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ADGroup `
                        -ParameterFilter { $Identity -eq $getTargetResourceParameters.GroupName } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName Get-ADGroupMember `
                        -Exactly -Times 0
                }
            }
        }

        Describe 'ADGroup\Test-TargetResource' -Tag 'Test' {
            BeforeAll {
                $testTargetResourceParameters = @{
                    GroupName   = $mockADGroup.GroupName
                    GroupScope  = $mockADGroup.GroupScope
                    Category    = $mockADGroup.GroupCategory
                    Path        = $mockADGroup.Path
                    Description = $mockADGroup.Description
                    DisplayName = $mockADGroup.DisplayName
                    SamAccountName = $mockADGroup.SamAccountName
                    ManagedBy   = $mockADGroup.ManagedBy
                    Notes       = $mockADGroup.Info
                    Members     = $mockADGroup.Members
                    Ensure      = 'Present'
                }

                $testTargetResourceParametersAbsent = $testTargetResourceParameters.Clone()
                $testTargetResourceParametersAbsent.Ensure = 'Absent'
            }

            Context 'When the Resource is Present' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResults }
                }

                Context 'When the Resource should be Present' {
                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParameters }  | Should -Not -Throw
                    }

                    Context 'When the "Credential" parameter is specified' {
                        It 'Should not throw' {
                            { Test-TargetResource @testTargetResourceParameters -Credential $testCredential } |
                                Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { `
                                    $GroupName -eq $testTargetResourceParameters.GroupName -and `
                                    $Credential -eq $testCredential } `
                                -Exactly -Times 1
                        }
                    }

                    Context 'When the "DomainController" parameter is specified' {
                        It 'Should not throw' {
                            { Test-TargetResource @testTargetResourceParameters `
                                    -DomainController $testDomainController } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { `
                                    $GroupName -eq $testTargetResourceParameters.GroupName -and `
                                    $DomainController -eq $testDomainController } `
                                -Exactly -Times 1
                        }
                    }

                    Context 'When all the resource properties are in the desired state' {
                        It 'Should return $true' {
                            Test-TargetResource @testTargetResourceParameters | Should -Be $true
                        }
                    }

                    Context "When the 'MembersToInclude' property is in the desired state" {
                        It 'Should return $true' {
                            $testTargetResourceParametersMembersToInclude = $testTargetResourceParameters.Clone()
                            $testTargetResourceParametersMembersToInclude.Remove('Members')
                            $testTargetResourceParametersMembersToInclude['MembersToInclude'] = $mockAdGroup.Members[0]

                            Test-TargetResource @testTargetResourceParametersMembersToInclude | Should -Be $true
                        }
                    }

                    Context "When the 'MembersToExclude' property is in the desired state" {
                        It 'Should return $true' {
                            $testTargetResourceParametersMembersToExclude = $testTargetResourceParameters.Clone()
                            $testTargetResourceParametersMembersToExclude.Remove('Members')
                            $testTargetResourceParametersMembersToExclude['MembersToExclude'] = 'ExcludedUser'

                            Test-TargetResource @testTargetResourceParametersMembersToExclude | Should -Be $true
                        }
                    }

                    foreach ($property in $mockAdGroupChanged.Keys)
                    {
                        Context "When the '$property' resource property is not in the desired state" {
                            It 'Should return $false' {
                                $testTargetResourceParametersChanged = $testTargetResourceParameters.Clone()
                                $testTargetResourceParametersChanged[$property] = $mockAdGroupChanged.$property

                                Test-TargetResource @testTargetResourceParametersChanged | Should -Be $false
                            }
                        }
                    }

                    Context "When the 'Members' resource property is not in the desired state" {
                        It 'Should return $false' {
                            $testTargetResourceParametersChanged = $testTargetResourceParameters.Clone()
                            $testTargetResourceParametersChanged['Members'] = 'ChangedUser'

                            Test-TargetResource @testTargetResourceParametersChanged | Should -Be $false
                        }
                    }

                    Context "When the 'MemberstoInclude' resource property is not in the desired state" {
                        It 'Should return $false' {
                            $testTargetResourceParametersChanged = $testTargetResourceParameters.Clone()
                            $testTargetResourceParametersChanged.Remove('Members')
                            $testTargetResourceParametersChanged['MembersToInclude'] = 'NotIncludedUser'

                            Test-TargetResource @testTargetResourceParametersChanged | Should -Be $false
                        }
                    }

                    Context "When the 'MemberstoExclude' resource property is not in the desired state" {
                        It 'Should return $false' {
                            $testTargetResourceParametersChanged = $testTargetResourceParameters.Clone()
                            $testTargetResourceParametersChanged.Remove('Members')
                            $testTargetResourceParametersChanged['MembersToExclude'] = $mockADGroup.Members[0]

                            Test-TargetResource @testTargetResourceParametersChanged | Should -Be $false
                        }
                    }
                }

                Context 'When the Resource should be Absent' {
                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParametersAbsent } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { $GroupName -eq $testTargetResourceParametersAbsent.GroupName } `
                            -Exactly -Times 1
                    }

                    It 'Should return $false' {
                        Test-TargetResource @testTargetResourceParametersAbsent | Should -Be $false
                    }
                }
            }

            Context 'When the Resource is Absent' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResultsAbsent }
                }

                Context 'When the Resource should be Present' {
                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParameters } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { $GroupName -eq $testTargetResourceParameters.GroupName } `
                            -Exactly -Times 1
                    }

                    It 'Should return $false' {
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    }
                }

                Context 'When the Resource should be Absent' {
                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParametersAbsent } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { $GroupName -eq $testTargetResourceParametersAbsent.GroupName } `
                            -Exactly -Times 1
                    }

                    It 'Should return $true' {
                        Test-TargetResource @testTargetResourceParametersAbsent | Should -Be $true
                    }
                }
            }
        }

        Describe 'ADGroup\Set-TargetResource' -Tag 'Set' {
            BeforeAll {
                $setTargetResourceParameters = @{
                    GroupName   = $mockADGroup.GroupName
                    GroupScope  = $mockADGroup.GroupScope
                    Category    = $mockADGroup.GroupCategory
                    Path        = $mockADGroup.Path
                    Description = $mockADGroup.Description
                    DisplayName = $mockADGroup.DisplayName
                    SamAccountName = $mockADGroup.SamAccountName
                    ManagedBy   = $mockADGroup.ManagedBy
                    Notes       = $mockADGroup.Info
                    Members     = $mockADGroup.Members
                    Ensure      = 'Present'
                }

                $setTargetResourceParametersAbsent = $setTargetResourceParameters.Clone()
                $setTargetResourceParametersAbsent.Ensure = 'Absent'

                Mock -CommandName New-ADGroup
                Mock -CommandName Set-ADGroup
                Mock -CommandName Remove-ADGroup
                Mock -CommandName Move-ADObject
                Mock -CommandName Set-ADCommonGroupMember
                Mock -CommandName Restore-ADCommonObject
            }

            Context 'When the Resource should be Present' {

                Context 'When the Resource is Present' {
                    BeforeAll {
                        Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResults }
                    }

                    foreach ($propertyName in $mockAdGroupChanged.Keys)
                    {
                        Context "When the '$propertyName' property has changed" {
                            BeforeAll {
                                $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                                $setTargetResourceParametersChangedProperty.$propertyName = `
                                    $mockAdGroupChanged.$propertyName
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceParametersChangedProperty } | Should -Not -Throw
                            }

                            It "Should call the expected mocks" {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { `
                                        $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -ParameterFilter { (Get-Variable -Name $propertyName -ValueOnly) -eq `
                                        $setTargetResourceParametersChangedProperty.$propertyName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Remove-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName New-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Move-ADObject `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                    -Exactly -Times 0
                            }
                        }
                    }

                    Context "When the `Path' property has changed" {
                        BeforeAll {
                            $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                            $setTargetResourceParametersChangedProperty.Path = 'OU=Changed,DC=contoso,DC=com'
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceParametersChangedProperty } | Should -Not -Throw
                        }

                        It "Should call the expected mocks" {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { `
                                    $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Move-ADObject `
                                -ParameterFilter { $TargetPath -eq $setTargetResourceParametersChangedProperty.Path } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Remove-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName New-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                -Exactly -Times 0
                        }

                        Context "When 'Move-ADObject' throws an unexpected exception" {
                            BeforeAll {
                                Mock -CommandName Move-ADObject -MockWith { throw 'UnexpectedError' }
                            }

                            It 'Should throw the correct exception' {
                                { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                    Should -Throw ($script:localizedData.MovingGroupError -f
                                        $setTargetResourceParametersChangedProperty.GroupName,
                                        $mockGetTargetResourceResults.Path,
                                        $setTargetResourceParametersChangedProperty.Path)
                            }
                        }
                    }

                    Context "When the 'Category' property has changed" {
                        BeforeAll {
                            $changedCategory = 'Distribution'

                            $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                            $setTargetResourceParametersChangedProperty.Category = $changedCategory
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceParametersChangedProperty } | Should -Not -Throw
                        }

                        It "Should call the expected mocks" {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { `
                                    $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADGroup `
                                -ParameterFilter { `
                                    $Identity -eq $mockGroupDN -and $GroupCategory -eq $changedCategory } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Remove-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName New-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                -Exactly -Times 0
                        }
                    }

                    Context "When the 'GroupScope' property has changed" {
                        Context "When the `GroupScope' property was 'Global' and has changed to 'Domain Local'" {
                            BeforeAll {
                                $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                                $setTargetResourceParametersChangedProperty.GroupScope = 'DomainLocal'
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceParametersChangedProperty } | Should -Not -Throw
                            }

                            It "Should call the expected mocks" {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { `
                                        $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -ParameterFilter { $Identity -eq $mockGroupDN -and $GroupScope -eq 'Universal' } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -ParameterFilter { $Identity -eq $mockGroupDN -and $GroupScope -eq 'DomainLocal' } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Remove-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName New-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                    -Exactly -Times 0
                            }
                        }

                        Context "When the `GroupScope' property was 'DomainLocal' and has changed to 'Global'" {
                            BeforeAll {
                                $mockGetTargetResourceDomainLocalResults = $mockGetTargetResourceResults.Clone()
                                $mockGetTargetResourceDomainLocalResults.GroupScope = 'DomainLocal'

                                Mock -CommandName Get-TargetResource `
                                    -MockWith { $mockGetTargetResourceDomainLocalResults }

                                $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                                $setTargetResourceParametersChangedProperty.GroupScope = 'Global'
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceParametersChangedProperty } | Should -Not -Throw
                            }

                            It "Should call the expected mocks" {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { `
                                        $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -ParameterFilter { $Identity -eq $mockGroupDN -and $GroupScope -eq 'Universal' } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -ParameterFilter { $Identity -eq $mockGroupDN -and $GroupScope -eq 'Global' } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Remove-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName New-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                    -Exactly -Times 0
                            }

                            Context "When the 'Credential' parameter is specified" {
                                BeforeAll {
                                    $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                                    $setTargetResourceParametersChangedProperty['Description'] = `
                                        $mockAdGroupChanged.Description
                                    $setTargetResourceParametersChangedProperty['Credential'] = `
                                        $testCredential
                                }

                                It 'Should not throw' {
                                    { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                        Should -Not -Throw
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $Credential -eq $testCredential } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Set-ADGroup `
                                        -ParameterFilter {
                                        $Identity -eq $mockGroupDN -and $GroupScope -eq 'Universal' -and `
                                            $Credential -eq $testCredential } `
                                        -Exactly -Times 1
                                }
                            }

                            Context "When the 'DomainController' parameter is specified" {
                                BeforeAll {
                                    $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                                    $setTargetResourceParametersChangedProperty['Description'] = `
                                        $mockAdGroupChanged.Description
                                    $setTargetResourceParametersChangedProperty['DomainController'] = `
                                        $testDomainController
                                }

                                It 'Should not throw' {
                                    { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                        Should -Not -Throw
                                }

                                It 'Should call the expected mocks' {
                                    Assert-MockCalled -CommandName Get-TargetResource `
                                        -ParameterFilter { $DomainController -eq $testDomainController } `
                                        -Exactly -Times 1
                                    Assert-MockCalled -CommandName Set-ADGroup `
                                        -ParameterFilter { `
                                            $Identity -eq $mockGroupDN -and $GroupScope -eq 'Universal' -and `
                                            $Server -eq $testDomainController } `
                                        -Exactly -Times 1
                                }
                            }

                            Context "When 'Set-ADGroup' throws an unexpected exception" {
                                BeforeAll {
                                    Mock -CommandName Set-ADGroup `
                                        -ParameterFilter { $GroupScope -eq 'Universal' } `
                                        -MockWith { throw 'UnexpectedError' }
                                }

                                It 'Should throw the correct exception' {
                                    { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                        Should -Throw ($script:localizedData.SettingGroupError -f
                                            $setTargetResourceParametersChangedProperty.GroupName)
                                }
                            }
                        }
                    }

                    Context "When the 'Notes' property has changed" {
                        BeforeAll {
                            $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                            $setTargetResourceParametersChangedProperty.Notes = 'Changed Notes'
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceParametersChangedProperty } | Should -Not -Throw
                        }

                        It "Should call the expected mocks" {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADGroup `
                                -ParameterFilter { `
                                    $Identity -eq $mockGroupDN -and (Get-Variable -Name Replace -ValueOnly).Info -eq `
                                    $setTargetResourceParametersChangedProperty.Notes } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Remove-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName New-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                -Exactly -Times 0
                        }
                    }

                    Context "When the 'Members' property has changed" {
                        Context "When the 'Members property has members to add" {
                            BeforeAll {
                                $changedMembers = 'ChangedMember1', 'ChangedMember2'
                                $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                                $setTargetResourceParametersChangedProperty.Members += $changedMembers
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceParametersChangedProperty } | Should -Not -Throw
                            }

                            It "Should call the expected mocks" {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                    -ParameterFilter { `
                                        $Members.Count -eq $changedMembers.Count -and `
                                        $Members -contains $changedMembers[0] -and `
                                        $Members -contains $changedMembers[1] -and `
                                        $Action -eq 'Add' } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Remove-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName New-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 0
                            }
                        }

                        Context "When the 'Members' property has members to remove" {
                            BeforeAll {
                                $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                                $setTargetResourceParametersChangedProperty.Members = `
                                    $mockADGroup.Members[0..($mockADGroup.Members.count - 2)]
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceParametersChangedProperty } | Should -Not -Throw
                            }

                            It "Should call the expected mocks" {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                    -ParameterFilter { `
                                        $Members.Count -eq 1 -and `
                                        $Members -contains $mockADGroup.Members[-1] -and `
                                        $Action -eq 'Remove' } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Remove-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName New-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 0
                            }
                        }

                        Context "When the 'Members' property is specified as empty" {
                            BeforeAll {
                                $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                                $setTargetResourceParametersChangedProperty.Members = @()
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceParametersChangedProperty } | Should -Not -Throw
                            }

                            It "Should call the expected mocks" {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                    -ParameterFilter { `
                                        $Members.Count -eq $setTargetResourceParameters.Members.Count -and `
                                        $Members -contains $setTargetResourceParameters.Members[0] -and `
                                        $Members -contains $setTargetResourceParameters.Members[1] -and `
                                        $Members -contains $setTargetResourceParameters.Members[2] -and `
                                        $Members -contains $setTargetResourceParameters.Members[3] -and `
                                        $Action -eq 'Remove' } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Remove-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName New-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 0
                            }
                        }

                        Context "When the resource 'Members' value is empty" {
                            BeforeAll {
                                $mockGetTargetResourceEmptyMembersResults = $mockGetTargetResourceResults.Clone()
                                $mockGetTargetResourceEmptyMembersResults.Members = @()

                                Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceEmptyMembersResults }

                                $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                                $setTargetResourceParametersChangedProperty.Members = $mockADGroup.Members
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceParametersChangedProperty } | Should -Not -Throw
                            }

                            It "Should call the expected mocks" {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                    -ParameterFilter { `
                                        $Members.Count -eq $mockADGroup.Members.Count -and `
                                        $Members -contains $mockADGroup.Members[0] -and `
                                        $Members -contains $mockADGroup.Members[1] -and `
                                        $Members -contains $mockADGroup.Members[2] -and `
                                        $Members -contains $mockADGroup.Members[3] -and `
                                        $Action -eq 'Add' } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Remove-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName New-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 0
                            }
                        }
                    }

                    Context "When the 'MembersToInclude' property is not in the desired state" {
                        BeforeAll {
                            $membersToInclude = 'IncludeUser'
                            $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                            $setTargetResourceParametersChangedProperty.Remove('Members')
                            $setTargetResourceParametersChangedProperty['MembersToInclude'] = $membersToInclude
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                Should -Not -Throw
                        }

                        It "Should call the expected mocks" {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                -ParameterFilter { $Members -contains $membersToInclude -and $Action -eq 'Add' } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Remove-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName New-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                        }

                        Context "When the resource 'Members' value is empty" {
                            BeforeAll {
                                $mockGetTargetResourceEmptyMembersResults = $mockGetTargetResourceResults.Clone()
                                $mockGetTargetResourceEmptyMembersResults.Members = @()

                                Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceEmptyMembersResults }
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                    Should -Not -Throw
                            }

                            It "Should call the expected mocks" {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                    -ParameterFilter { $Members -contains $membersToInclude -and $Action -eq 'Add' } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Remove-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName New-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 0
                            }
                        }
                    }

                    Context "When the 'MembersToExclude' property is not in the desired state" {
                        BeforeAll {
                            $membersToExclude = $mockADGroup.Members[0]
                            $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                            $setTargetResourceParametersChangedProperty.Remove('Members')
                            $setTargetResourceParametersChangedProperty['MembersToExclude'] = $membersToExclude
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                Should -Not -Throw
                        }

                        It "Should call the expected mocks" {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                -ParameterFilter { $Members -contains $membersToExclude -and $Action -eq 'Remove' } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Remove-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName New-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                        }

                        Context "When the resource 'Members' value is empty" {
                            BeforeAll {
                                $mockGetTargetResourceEmptyMembersResults = $mockGetTargetResourceResults.Clone()
                                $mockGetTargetResourceEmptyMembersResults.Members = @()

                                Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceEmptyMembersResults }
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                    Should -Not -Throw
                            }

                            It "Should call the expected mocks" {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Remove-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName New-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -Exactly -Times 0
                            }
                        }
                    }

                    Context "When the 'Credential' parameter is specified" {
                        BeforeAll {
                            $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                            $setTargetResourceParametersChangedProperty['Description'] = $mockAdGroupChanged.Description
                            $setTargetResourceParametersChangedProperty['Credential'] = $testCredential
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $Credential -eq $testCredential } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADGroup `
                                -ParameterFilter { $Credential -eq $testCredential } `
                                -Exactly -Times 1
                        }
                    }

                    Context "When the 'DomainController' parameter is specified" {
                        BeforeAll {
                            $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                            $setTargetResourceParametersChangedProperty['Description'] = $mockAdGroupChanged.Description
                            $setTargetResourceParametersChangedProperty['DomainController'] = $testDomainController
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $DomainController -eq $testDomainController } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADGroup `
                                -ParameterFilter { $Server -eq $testDomainController } `
                                -Exactly -Times 1
                        }
                    }

                    Context "When 'Set-ADGroup' throws an unexpected error" {
                        BeforeAll {
                            $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                            $setTargetResourceParametersChangedProperty.Description = $mockADGroupChanged.Description

                            Mock -CommandName Set-ADGroup -MockWith { throw 'UnexpectedError' }
                        }

                        It 'Should throw the correct exception' {
                            { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                Should -Throw ($script:localizedData.SettingGroupError -f
                                    $setTargetResourceParametersChangedProperty.GroupName)
                        }
                    }

                    Context 'When the Resource is in the desired state' {
                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $GroupName -eq $setTargetResourceParameters.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName New-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Remove-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                -Exactly -Times 0
                        }
                    }
                }

                Context 'When the Resource is Absent' {
                    BeforeAll {
                        Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResultsAbsent }
                    }

                    It 'Should not throw' {
                        { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { $GroupName -eq $mockGetTargetResourceResultsAbsent.GroupName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName New-ADGroup `
                            -ParameterFilter { $Name -eq $setTargetResourceParameters.GroupName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Set-ADGroup `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Remove-ADgroup `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                            -Exactly -Times 0
                    }

                    Context 'When the "RestoreFromRecycleBin" parameter is specified' {
                        BeforeAll {
                            $setTargetResourceRecycleBinParameters = $setTargetResourceParameters.Clone()
                            $setTargetResourceRecycleBinParameters['RestoreFromRecycleBin'] = $true

                            Mock -CommandName Restore-ADCommonObject -MockWith { $true }
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceRecycleBinParameters } | Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $GroupName -eq $setTargetResourceRecycleBinParameters.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -ParameterFilter { $Identity -eq $setTargetResourceRecycleBinParameters.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Remove-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName New-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Set-ADGroup `
                                -Exactly -Times 0
                        }

                        Context "When 'Restore-ADCommonObject' does not return an object" {
                            BeforeAll {
                                Mock -CommandName Restore-ADCommonObject
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceRecycleBinParameters } | Should -Not -Throw
                            }

                            It 'Should call the expected mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { $GroupName -eq $setTargetResourceRecycleBinParameters.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -ParameterFilter { $Identity -eq $setTargetResourceRecycleBinParameters.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName New-ADGroup `
                                    -ParameterFilter { $Name -eq $setTargetResourceParameters.GroupName } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Remove-ADGroup `
                                    -Exactly -Times 0
                                Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Set-ADGroup `
                                    -Exactly -Times 0
                            }
                        }

                        Context "When the 'Credential' parameter is specified" {
                            BeforeAll {
                                $setTargetResourceRecycleBinCredentialParameters = $setTargetResourceRecycleBinParameters.Clone()
                                $setTargetResourceRecycleBinCredentialParameters['Credential'] = $testCredential
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceRecycleBinCredentialParameters } |
                                    Should -Not -Throw
                            }

                            It 'Should call the expected mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { $Credential -eq $testCredential } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -ParameterFilter { $Credential -eq $testCredential } `
                                    -Exactly -Times 1
                            }
                        }

                        Context "When the 'DomainController' parameter is specified" {
                            BeforeAll {
                                $setTargetResourceRecycleBinDomainControllerParameters = $setTargetResourceRecycleBinParameters.Clone()
                                $setTargetResourceRecycleBinDomainControllerParameters['DomainController'] = $testDomainController
                            }

                            It 'Should not throw' {
                                { Set-TargetResource @setTargetResourceRecycleBinDomainControllerParameters } |
                                    Should -Not -Throw
                            }

                            It 'Should call the expected mocks' {
                                Assert-MockCalled -CommandName Get-TargetResource `
                                    -ParameterFilter { $DomainController -eq $testDomainController } `
                                    -Exactly -Times 1
                                Assert-MockCalled -CommandName Restore-ADCommonObject `
                                    -ParameterFilter { $Server -eq $testDomainController } `
                                    -Exactly -Times 1
                            }
                        }
                    }

                    Context "When the 'Credential' parameter is specified" {
                        BeforeAll {
                            $setTargetResourceCredentialParameters = $setTargetResourceParameters.Clone()
                            $setTargetResourceCredentialParameters['Credential'] = $testCredential
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceCredentialParameters } |
                                Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $Credential -eq $testCredential } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName New-ADGroup `
                                -ParameterFilter { $Credential -eq $testCredential } `
                                -Exactly -Times 1
                        }
                    }

                    Context "When the 'DomainController' parameter is specified" {
                        BeforeAll {
                            $setTargetResourceDomainControllerParameters = $setTargetResourceParameters.Clone()
                            $setTargetResourceDomainControllerParameters['DomainController'] = $testDomainController
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceDomainControllerParameters } |
                                Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $DomainController -eq $testDomainController } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName New-ADGroup `
                                -ParameterFilter { $Server -eq $testDomainController } `
                                -Exactly -Times 1
                        }
                    }

                    Context "When 'New-ADGroup' throws an unexpected error" {
                        BeforeAll {
                            Mock -CommandName New-ADGroup -MockWith { throw 'UnexpectedError' }
                        }

                        It 'Should throw the correct exception' {
                            { Set-TargetResource @setTargetResourceParameters } |
                                Should -Throw ($script:localizedData.AddingResourceError -f
                                    $setTargetResourceParameters.GroupName)
                        }
                    }

                    Context "When the 'MembersToInclude' property is specified" {
                        BeforeAll {
                            $membersToInclude = $mockADGroup.Members
                            $setTargetResourceParametersChangedProperty = $setTargetResourceParameters.Clone()
                            $setTargetResourceParametersChangedProperty.Remove('Members')
                            $setTargetResourceParametersChangedProperty['MembersToInclude'] = $membersToInclude
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceParametersChangedProperty } |
                                Should -Not -Throw
                        }

                        It "Should call the expected mocks" {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $GroupName -eq $setTargetResourceParametersChangedProperty.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName New-ADGroup `
                                -ParameterFilter { $Name -eq $setTargetResourceParameters.GroupName } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                                -ParameterFilter {
                                $Members.Count -eq $membersToInclude.Count -and `
                                    $Members -contains $membersToInclude[0] -and `
                                    $Members -contains $membersToInclude[1] -and `
                                    $Members -contains $membersToInclude[2] -and `
                                    $Members -contains $membersToInclude[3] -and `
                                    $Action -eq 'Add' } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Set-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Remove-ADGroup `
                                -Exactly -Times 0
                            Assert-MockCalled -CommandName Restore-ADCommonObject `
                                -Exactly -Times 0
                        }
                    }
                }
            }

            Context 'When the Resource should be Absent' {
                Context 'When the Resource is Present' {
                    BeforeAll {
                        Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResults }
                    }

                    It 'Should not throw' {
                        { Set-TargetResource @setTargetResourceParametersAbsent } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { $GroupName -eq $setTargetResourceParametersAbsent.GroupName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Remove-ADGroup `
                            -ParameterFilter { $Identity -eq $setTargetResourceParametersAbsent.GroupName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName New-ADGroup `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Set-ADGroup `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                            -Exactly -Times 0
                    }

                    Context "When the 'Credential' parameter is specified" {
                        BeforeAll {
                            $setTargetResourceCredentialParametersAbsent = $setTargetResourceParametersAbsent.Clone()
                            $setTargetResourceCredentialParametersAbsent['Credential'] = $testCredential
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceCredentialParametersAbsent } |
                                Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $Credential -eq $testCredential } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Remove-ADGroup `
                                -ParameterFilter { $Credential -eq $testCredential } `
                                -Exactly -Times 1
                        }
                    }

                    Context "When the 'DomainController' parameter is specified" {
                        BeforeAll {
                            $setTargetResourceDomainControllerParametersAbsent = $setTargetResourceParametersAbsent.Clone()
                            $setTargetResourceDomainControllerParametersAbsent['DomainController'] = $testDomainController
                        }

                        It 'Should not throw' {
                            { Set-TargetResource @setTargetResourceDomainControllerParametersAbsent } |
                                Should -Not -Throw
                        }

                        It 'Should call the expected mocks' {
                            Assert-MockCalled -CommandName Get-TargetResource `
                                -ParameterFilter { $DomainController -eq $testDomainController } `
                                -Exactly -Times 1
                            Assert-MockCalled -CommandName Remove-ADGroup `
                                -ParameterFilter { $Server -eq $testDomainController } `
                                -Exactly -Times 1
                        }
                    }

                    Context "When 'Remove-ADGroup' throws an unexpected error" {
                        BeforeAll {
                            Mock -CommandName Remove-ADGroup -MockWith { throw 'UnexpectedError' }
                        }

                        It 'Should throw the correct exception' {
                            { Set-TargetResource @setTargetResourceParametersAbsent } |
                                Should -Throw ($script:localizedData.RemovingResourceError -f
                                    $setTargetResourceParametersAbsent.GroupName)
                        }
                    }
                }

                Context 'When the Resource is Absent' {
                    BeforeAll {
                        Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceResultsAbsent }
                    }

                    It 'Should not throw' {
                        { Set-TargetResource @setTargetResourceParametersAbsent } | Should -Not -Throw
                    }

                    It 'Should call the expected mocks' {
                        Assert-MockCalled -CommandName Get-TargetResource `
                            -ParameterFilter { $GroupName -eq $setTargetResourceParametersAbsent.GroupName } `
                            -Exactly -Times 1
                        Assert-MockCalled -CommandName Set-ADCommonGroupMember `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Remove-ADGroup `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName New-ADGroup `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Set-ADGroup `
                            -Exactly -Times 0
                        Assert-MockCalled -CommandName Restore-ADCommonObject `
                            -Exactly -Times 0
                    }
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
