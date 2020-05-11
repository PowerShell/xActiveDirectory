$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'ActiveDirectoryDsc.Common'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'ActiveDirectoryDsc.Common.psm1')

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        Returns the current state of an Active Directory fine-grained password
        policy.

    .PARAMETER Name
        Specifies an Active Directory fine-grained password policy object name.

    .PARAMETER Precedence
        The rank the policy is to be applied.

    .PARAMETER SubjectsToInclude
        The ADPrinciple names to add to the policy, does not overwrite.

    .PARAMETER SubjectsToExclude
        The ADPrinciple names to remove from the policy, does not overwrite.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $Precedence,

        [Parameter()]
        [System.String[]]
        $Subjects,

        [Parameter()]
        [System.String[]]
        $SubjectsToInclude,

        [Parameter()]
        [System.String[]]
        $SubjectsToExclude
    )

    Assert-Module -ModuleName 'ActiveDirectory'

    Write-Verbose -Message ($script:localizedData.QueryingFineGrainedPasswordPolicy -f $Name)

    $SubjectsDifferent = $false

    try
    {
        $policy = Get-ADFineGrainedPasswordPolicy -Filter { name -eq $Name }
    }
    catch
    {
        $errorMessage = $script:localizedData.RetrieveFineGrainedPasswordPolicyError -f $Name
        New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
    }

    try
    {
        $policySubjects = (Get-ADFineGrainedPasswordPolicySubject -Identity $Name).Name
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        Write-Verbose -Message ($script:localizedData.FineGrainedPasswordPolicySubjectNotFoundMessage -f $Name)
        $policySubjects = $null
    }
    catch
    {
        $errorMessage = $script:localizedData.RetrieveFineGrainedPasswordPolicySubjectError -f $Name
        New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
    }


    if ($PSBoundParameters.ContainsKey('Subjects') -and -not [System.String]::IsNullOrEmpty($Subjects))
    {
        $SubjectsDifferent = $true
    }

    if ($PSBoundParameters.ContainsKey('SubjectsToInclude') -and `
        -not [System.String]::IsNullOrEmpty($SubjectsToInclude))
    {
        if (Compare-Object -ReferenceObject $SubjectsToInclude -DifferenceObject $policySubjects `
            -IncludeEqual | Where-Object `
            {
                $_.SideIndicator -eq "<="
            })
        {
            $SubjectsDifferent = $true
        }
    }

    if ($PSBoundParameters.ContainsKey('SubjectsToExclude') -and `
        -not [System.String]::IsNullOrEmpty($SubjectsToExclude))
    {
        if (Compare-Object -ReferenceObject $SubjectsToExclude -DifferenceObject $policySubjects `
            -IncludeEqual | Where-Object `
            {
                $_.SideIndicator -eq "=="
            })
        {
            $SubjectsDifferent = $true
        }
    }

    if ($policy)
    {
        return @{
            Name                        = $Name
            ComplexityEnabled           = $policy.ComplexityEnabled
            LockoutDuration             = $policy.LockoutDuration
            LockoutObservationWindow    = $policy.LockoutObservationWindow
            LockoutThreshold            = $policy.LockoutThreshold
            MinPasswordAge              = $policy.MinPasswordAge
            MaxPasswordAge              = $policy.MaxPasswordAge
            MinPasswordLength           = $policy.MinPasswordLength
            PasswordHistoryCount        = $policy.PasswordHistoryCount
            ReversibleEncryptionEnabled = $policy.ReversibleEncryptionEnabled
            Precedence                  = $policy.Precedence
            Ensure                      = 'Present'
            SubjectsDifferent           = $SubjectsDifferent
        }
    }
    else
    {
        return @{
            Name                        = $Name
            ComplexityEnabled           = $null
            LockoutDuration             = $null
            LockoutObservationWindow    = $null
            LockoutThreshold            = $null
            MinPasswordAge              = $null
            MaxPasswordAge              = $null
            MinPasswordLength           = $null
            PasswordHistoryCount        = $null
            ReversibleEncryptionEnabled = $null
            Precedence                  = $null
            Ensure                      = 'Absent'
            SubjectsDifferent           = $false
        }
    }
} #end Get-TargetResource

<#
    .SYNOPSIS
        Determines if the Active Directory default domain password policy is in
        the desired state

    .PARAMETER Name
        Name of the fine grained password policy to be applied. Name must be exactly
        matching the subject to be applied to.

    .PARAMETER DisplayName
        Display name of the fine grained password policy to be applied.

    .PARAMETER Subjects
        The ADPrinciple names the policy is to be applied to, overwrites all existing
        and overrides SubjectsToInclude and SubjectsToExclude.

    .PARAMETER SubjectsToInclude
        The ADPrinciple names to add to the policy, does not overwrite.

    .PARAMETER SubjectsToExclude
        The ADPrinciple names to remove from the policy, does not overwrite.

    .PARAMETER Ensure
        Specifies whether the fine grained password policy should be present or absent. Default value is 'Present'.

    .PARAMETER ComplexityEnabled
        Whether password complexity is enabled for the password policy.

    .PARAMETER LockoutDuration
        Length of time that an account is locked after the number of failed login attempts (minutes).

    .PARAMETER LockoutObservationWindow
        Maximum time between two unsuccessful login attempts before the counter is reset to 0 (minutes).

    .PARAMETER LockoutThreshold
        Number of unsuccessful login attempts that are permitted before an account is locked out.

    .PARAMETER MinPasswordAge
        Minimum length of time that you can have the same password (days).

    .PARAMETER MaxPasswordAge
        Maximum length of time that you can have the same password (days).

    .PARAMETER MinPasswordLength
        Minimum number of characters that a password must contain.

    .PARAMETER PasswordHistoryCount
        Number of previous passwords to remember.

    .PARAMETER ReversibleEncryptionEnabled
        Whether the directory must store passwords using reversible encryption.

    .PARAMETER ProtectedFromAccidentalDeletion
        Whether to protect the poliicy from accidental deletion.

    .PARAMETER Precedence
        The rank the policy is to be applied.

    .NOTES
        Used Functions:
            Name                          | Module
            ------------------------------|--------------------------
            Compare-ResourcePropertyState | ActiveDirectoryDsc.Common
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String[]]
        $Subjects,

        [Parameter()]
        [System.String[]]
        $SubjectsToInclude,

        [Parameter()]
        [System.String[]]
        $SubjectsToExclude,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $ComplexityEnabled,

        [Parameter()]
        [ValidateScript({
            ([ValidateRange(1, 30)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String]
        $LockoutDuration,

        [Parameter()]
        [ValidateScript({
            ([ValidateRange(1, 30)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String]
        $LockoutObservationWindow,

        [Parameter()]
        [System.UInt32]
        $LockoutThreshold,

        [Parameter()]
        [ValidateScript({
            ([ValidateRange(1, 10675199)]$valueInDays = [TimeSpan]::Parse($_).TotalDays); $?
        })]
        [String]
        $MinPasswordAge,

        [Parameter()]
        [ValidateScript({
            ([ValidateRange(1, 10675199)]$valueInDays = [TimeSpan]::Parse($_).TotalDays); $?
        })]
        [String]
        $MaxPasswordAge,

        [Parameter()]
        [System.UInt32]
        $MinPasswordLength,

        [Parameter()]
        [System.UInt32]
        $PasswordHistoryCount,

        [Parameter()]
        [System.Boolean]
        $ReversibleEncryptionEnabled,

        [Parameter()]
        [System.Boolean]
        $ProtectedFromAccidentalDeletion,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $Precedence,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    # Need to set these parameters to compare if users are using the default parameter values
    [HashTable] $parameters = $PSBoundParameters

    $getTargetResourceParams = @{
        Name       = $Name
        Precedence = $Precedence
    }

    # Build parameters needed to get resource properties
    if ($parameters.ContainsKey('Subjects') -and -not [System.String]::IsNullOrEmpty($Subjects))
    {
        $getTargetResourceParams['Subjects'] = $Subjects
    }

    if ($parameters.ContainsKey('SubjectsToInclude') -and -not [System.String]::IsNullOrEmpty($SubjectsToInclude))
    {
        $getTargetResourceParams['SubjectsToInclude'] = $SubjectsToInclude
    }

    if ($parameters.ContainsKey('SubjectsToExclude') -and -not [System.String]::IsNullOrEmpty($SubjectsToExclude))
    {
        $getTargetResourceParams['SubjectsToExclude'] = $SubjectsToExclude
    }

    $getTargetResourceResult = Get-TargetResource @getTargetResourceParams
    $inDesiredState = $true

    if ($getTargetResourceResult.Ensure -eq 'Present')
    {
        if ($Ensure -eq 'Present')
        {
            # Resource should exist
            $propertiesNotInDesiredState = (
                Compare-ResourcePropertyState -CurrentValues $getTargetResourceResult -DesiredValues $parameters `
                    -IgnoreProperties 'DisplayName', 'Subjects', 'SubjectsToInclude', 'SubjectsToExclude', `
                        'SubjectsDifferent', 'ProtectedFromAccidentalDeletion' | `
                            Where-Object -Property InDesiredState -eq $false)

            if ($propertiesNotInDesiredState)
            {
                $inDesiredState = $false
            }
            else
            {
                # Resource is in desired state
                Write-Verbose -Message ($script:localizedData.ResourceInDesiredState -f
                    $Name)
                $inDesiredState = $true
            }
        }
        else
        {
            # Resource should not exist
            Write-Verbose -Message ($script:localizedData.ResourceExistsButShouldNotMessage -f
                $Name)
            $inDesiredState = $false
        }
    }
    else
    {
        # Resource does not exist
        if ($Ensure -eq 'Present')
        {
            # Resource should exist
            Write-Verbose -Message ($script:localizedData.ResourceDoesNotExistButShouldMessage -f $Name)
            $inDesiredState = $false
        }
        else
        {
            # Resource should not exist
            $inDesiredState = $true
        }
    }

    if ($getTargetResourceResult.SubjectsDifferent)
    {
        Write-Verbose -Message ($script:localizedData.ResourcePropertyValueIncorrect -f `
        'Subjects are different', $false, $getTargetResourceResult.SubjectsDifferent)
        $inDesiredState = $false
    }

    if ($inDesiredState)
    {
        Write-Verbose -Message ($script:localizedData.ResourceInDesiredState -f $Name)
        return $true
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ResourceNotInDesiredState -f $Name)
        return $false
    }
} #end Test-TargetResource

<#
    .SYNOPSIS
        Modifies the Active Directory fine grained password policy. Name must be exactly matching
        the subject to be applied to.

    .PARAMETER Name
        Name of the fine grained password policy to be applied.

    .PARAMETER DisplayName
        Display name of the fine grained password policy to be applied.

    .PARAMETER Subjects
        The ADPrinciple names the policy is to be applied to, overwrites all existing and overrides
        SubjectsToInclude and SubjectsToExclude.

    .PARAMETER SubjectsToInclude
        The ADPrinciple names to add to the policy, does not overwrite.

    .PARAMETER SubjectsToExclude
        The ADPrinciple names to remove from the policy, does not overwrite.

    .PARAMETER Ensure
        Specifies whether the fine grained password policy should be present or absent. Default value is 'Present'.

    .PARAMETER ComplexityEnabled
        Whether password complexity is enabled for the password policy.

    .PARAMETER LockoutDuration
        Length of time that an account is locked after the number of failed login attempts (minutes).

    .PARAMETER LockoutObservationWindow
        Maximum time between two unsuccessful login attempts before the counter is reset to 0 (minutes).

    .PARAMETER LockoutThreshold
        Number of unsuccessful login attempts that are permitted before an account is locked out.

    .PARAMETER MinPasswordAge
        Minimum length of time that you can have the same password (days).

    .PARAMETER MaxPasswordAge
        Maximum length of time that you can have the same password (days).

    .PARAMETER MinPasswordLength
        Minimum number of characters that a password must contain.

    .PARAMETER PasswordHistoryCount
        Number of previous passwords to remember.

    .PARAMETER ReversibleEncryptionEnabled
        Whether the directory must store passwords using reversible encryption.

    .PARAMETER ProtectedFromAccidentalDeletion
        Whether to protect the poliicy from accidental deletion.

    .PARAMETER Precedence
        The rank the policy is to be applied.

    .PARAMETER DomainController
        Active Directory domain controller to enact the change upon.

    .PARAMETER Credential
        Credentials used to access the domain.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String[]]
        $Subjects,

        [Parameter()]
        [System.String[]]
        $SubjectsToInclude,

        [Parameter()]
        [System.String[]]
        $SubjectsToExclude,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $ComplexityEnabled,

        [Parameter()]
        [ValidateScript({
            ([ValidateRange(1, 30)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String]
        $LockoutDuration,

        [Parameter()]
        [ValidateScript({
            ([ValidateRange(1, 30)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String]
        $LockoutObservationWindow,

        [Parameter()]
        [System.UInt32]
        $LockoutThreshold,

        [Parameter()]
        [ValidateScript({
            ([ValidateRange(1, 10675199)]$valueInDays = [TimeSpan]::Parse($_).TotalDays); $?
        })]
        [String]
        $MinPasswordAge,

        [Parameter()]
        [ValidateScript({
            ([ValidateRange(1, 10675199)]$valueInDays = [TimeSpan]::Parse($_).TotalDays); $?
        })]
        [String]
        $MaxPasswordAge,

        [Parameter()]
        [System.UInt32]
        $MinPasswordLength,

        [Parameter()]
        [System.UInt32]
        $PasswordHistoryCount,

        [Parameter()]
        [System.Boolean]
        $ReversibleEncryptionEnabled,

        [Parameter()]
        [System.Boolean]
        $ProtectedFromAccidentalDeletion,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $Precedence,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    # Need to set these to compare if not specified since user is using defaults
    [HashTable] $parameters = $PSBoundParameters

    Assert-Module -ModuleName 'ActiveDirectory'

    $getTargetResourceParams = @{
        Name       = $Name
        Precedence = $Precedence
    }

    # Build parameters needed to get resource properties
    if ($parameters.ContainsKey('SubjectsToInclude') -and -not [System.String]::IsNullOrEmpty($SubjectsToInclude))
    {
        $getTargetResourceParams['SubjectsToInclude'] = $SubjectsToInclude
    }

    if ($parameters.ContainsKey('SubjectsToExclude') -and -not [System.String]::IsNullOrEmpty($SubjectsToExclude))
    {
        $getTargetResourceParams['SubjectsToExclude'] = $SubjectsToExclude
    }

    $getTargetResourceResult = Get-TargetResource @getTargetResourceParams

    $parameters['Identity'] = $Name

    if ($getTargetResourceResult.Ensure -eq 'Present')
    {
        $setADFineGrainedPasswordPolicyParams = Get-ADCommonParameters @parameters
    }
    else
    {
        $setADFineGrainedPasswordPolicyParams = Get-ADCommonParameters @parameters -UseNameParameter
    }

    # Build parameters needed to set resource properties
    if ($parameters.ContainsKey('ComplexityEnabled') -and `
        -not [System.String]::IsNullOrEmpty($ComplexityEnabled))
    {
        $setADFineGrainedPasswordPolicyParams['ComplexityEnabled'] = $ComplexityEnabled
        Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f `
            'ComplexityEnabled', $ComplexityEnabled)
    }

    if ($parameters.ContainsKey('LockoutDuration') -and `
        -not [System.String]::IsNullOrEmpty($LockoutDuration))
    {
        $setADFineGrainedPasswordPolicyParams['LockoutDuration'] = $LockoutDuration
        Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f `
            'LockoutDuration', $LockoutDuration)
    }

    if ($parameters.ContainsKey('LockoutObservationWindow') -and `
        -not [System.String]::IsNullOrEmpty($LockoutObservationWindow))
    {
        $setADFineGrainedPasswordPolicyParams['LockoutObservationWindow'] = $LockoutObservationWindow
        Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f `
            'LockoutObservationWindow', $LockoutObservationWindow)
    }

    if ($parameters.ContainsKey('LockoutThreshold') -and `
        -not [System.String]::IsNullOrEmpty($LockoutThreshold))
    {
        $setADFineGrainedPasswordPolicyParams['LockoutThreshold'] = $LockoutThreshold
        Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f `
            'LockoutThreshold', $LockoutThreshold)
    }

    if ($parameters.ContainsKey('MinPasswordAge') -and `
        -not [System.String]::IsNullOrEmpty($MinPasswordAge))
    {
        $setADFineGrainedPasswordPolicyParams['MinPasswordAge'] = $MinPasswordAge
        Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f `
            'MinPasswordAge', $MinPasswordAge)
    }

    if ($parameters.ContainsKey('MaxPasswordAge') -and `
        -not [System.String]::IsNullOrEmpty($MaxPasswordAge))
    {
        $setADFineGrainedPasswordPolicyParams['MaxPasswordAge'] = $MaxPasswordAge
        Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f `
            'MaxPasswordAge', $MaxPasswordAge)
    }

    if ($parameters.ContainsKey('MinPasswordLength') -and `
        -not [System.String]::IsNullOrEmpty($MinPasswordLength))
    {
        $setADFineGrainedPasswordPolicyParams['MinPasswordLength'] = $MinPasswordLength
        Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f `
            'MinPasswordLength', $MinPasswordLength)
    }

    if ($parameters.ContainsKey('PasswordHistoryCount') -and `
        -not [System.String]::IsNullOrEmpty($PasswordHistoryCount))
    {
        $setADFineGrainedPasswordPolicyParams['PasswordHistoryCount'] = $PasswordHistoryCount
        Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f `
            'PasswordHistoryCount', $PasswordHistoryCount)
    }

    if ($parameters.ContainsKey('ReversibleEncryptionEnabled') -and `
        -not [System.String]::IsNullOrEmpty($ReversibleEncryptionEnabled))
    {
        $setADFineGrainedPasswordPolicyParams['ReversibleEncryptionEnabled'] = $ReversibleEncryptionEnabled
        Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f `
            'ReversibleEncryptionEnabled', $ReversibleEncryptionEnabled)
    }

    if ($parameters.ContainsKey('ProtectedFromAccidentalDeletion') -and -not [System.String]::IsNullOrEmpty($ProtectedFromAccidentalDeletion))
    {
        $setADFineGrainedPasswordPolicyParams['ProtectedFromAccidentalDeletion'] = $ProtectedFromAccidentalDeletion
        Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f `
            'ProtectedFromAccidentalDeletion', $ProtectedFromAccidentalDeletion)
    }

    if ($parameters.ContainsKey('Precedence') -and -not [System.String]::IsNullOrEmpty($Precedence))
    {
        $setADFineGrainedPasswordPolicyParams['Precedence'] = $Precedence
        Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f `
            'Precedence', $Precedence)
    }

    if ($parameters.ContainsKey('Credential') -and -not [System.String]::IsNullOrEmpty($Credential))
    {
        $setADFineGrainedPasswordPolicyParams['Credential'] = $Credential
    }

    if ($parameters.ContainsKey('DomainController') -and `
        -not [System.String]::IsNullOrEmpty($DomainController))
    {
        $setADFineGrainedPasswordPolicyParams['Server'] = $DomainController
    }

    # Resource is absent and should be present
    if (($getTargetResourceResult.Ensure -eq 'Absent') -and ($Ensure -eq 'Present'))
    {
        Write-Verbose -Message ($script:localizedData.CreatingFineGrainedPasswordPolicy -f $Name)

        try
        {
            [ref] $null = New-ADFineGrainedPasswordPolicy @setADFineGrainedPasswordPolicyParams

            if ($parameters.ContainsKey('Subjects') -and -not [System.String]::IsNullOrEmpty($Subjects))
            {
                [ref] $null = Add-ADFineGrainedPasswordPolicySubject -Identity $Name -Subjects $Subjects
            }
        }
        catch
        {
            Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, $_)
        }
    }
    # Resource is present not in desired state
    elseif (($getTargetResourceResult.Ensure -eq 'Present') -and ($Ensure -eq 'Present'))
    {
        Write-Verbose -Message ($script:localizedData.UpdatingFineGrainedPasswordPolicy -f $Name)

        try
        {
            [ref] $null = Set-ADFineGrainedPasswordPolicy @setADFineGrainedPasswordPolicyParams

            # Add the exclusive subjects to policy (removes all others)
            if ($parameters.ContainsKey('Subjects') -and -not [System.String]::IsNullOrEmpty($Subjects))
            {
                $getExistingSubjectsToRemove = Get-ADFineGrainedPasswordPolicySubject -Identity $Name

                if ($getExistingSubjectsToRemove)
                {
                    Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, `
                    "Removing existing subjects count: $($getExistingSubjectsToRemove.Count)")

                    try
                    {
                        [ref] $null = Remove-ADFineGrainedPasswordPolicySubject -Identity $Name -Subjects `
                            $getExistingSubjectsToRemove -Confirm:$false
                    }
                    catch
                    {
                        Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, $_)
                    }
                }

                foreach ($subject in $Subjects)
                {
                    try
                    {
                        Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, `
                        "Adding new subject: $($subject)")

                        [ref] $null = Add-ADFineGrainedPasswordPolicySubject -Identity $Name -Subjects $subject
                    }
                    catch
                    {
                        Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $subject, $_)
                    }
                }
            }

            # Add the specific subjects to policy
            if ($parameters.ContainsKey('SubjectsToInclude') -and [System.String]::IsNullOrEmpty($Subjects))
            {
                foreach ($subject in $SubjectsToInclude)
                {
                    try
                    {
                        Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, `
                        "Adding new subject: $($subject)")

                        [ref] $null = Add-ADFineGrainedPasswordPolicySubject -Identity $Name -Subjects $subject
                    }
                    catch
                    {
                        Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $subject, $_)
                    }
                }
            }

            # Remove the specific subjects from policy
            if ($parameters.ContainsKey('SubjectsToExclude') -and [System.String]::IsNullOrEmpty($Subjects))
            {
                foreach ($subject in $SubjectsToExclude)
                {
                    try
                    {
                        Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, `
                        "Removing subject: $($subject)")

                        [ref] $null = Remove-ADFineGrainedPasswordPolicySubject -Identity $Name -Subjects $subject `
                            -Confirm:$false
                    }
                    catch
                    {
                        Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $subject, $_)
                    }
                }
            }
        }
        catch
        {
            Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, $_)
        }
    }
    # Resource is present but should be absent
    elseif (($getTargetResourceResult.Ensure -eq 'Present') -and ($Ensure -eq 'Absent'))
    {
        Write-Verbose -Message ($script:localizedData.RemovingFineGrainedPasswordPolicy -f $Name)

        try
        {
            if ($parameters.ContainsKey('ProtectedFromAccidentalDeletion') -and `
                -not $ProtectedFromAccidentalDeletion)
            {
                Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, `
                'Attempting to remove the protection for accidental deletion')
                [ref] $null = Set-ADFineGrainedPasswordPolicy @setADFineGrainedPasswordPolicyParams
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, `
                'ProtectedFromAccidentalDeletion is not defined to false, delete may fail if not explicitly set false')
            }

            [ref] $null = Remove-ADFineGrainedPasswordPolicy -Identity $Name
        }
        catch
        {
            Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, $_)
        }
    }
} #end Set-TargetResource

Export-ModuleMember -Function *-TargetResource