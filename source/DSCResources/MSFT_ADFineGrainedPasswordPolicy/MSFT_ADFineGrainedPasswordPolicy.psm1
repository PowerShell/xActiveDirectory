$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'ActiveDirectoryDsc.Common'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'ActiveDirectoryDsc.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_ADFineGrainedPasswordPolicy'

# List of changeable policy properties
$mutablePropertyMap = @(
    @{
        Name = 'ComplexityEnabled'
    }
    @{
        Name = 'LockoutDuration'
    }
    @{
        Name = 'LockoutObservationWindow'
    }
    @{
        Name = 'LockoutThreshold'
    }
    @{
        Name = 'MinPasswordAge'
    }
    @{
        Name = 'MaxPasswordAge'
    }
    @{
        Name = 'MinPasswordLength'
    }
    @{
        Name = 'PasswordHistoryCount'
    }
    @{
        Name = 'ReversibleEncryptionEnabled'
    }
    @{
        Name = 'Precedence'
    }
)

<#
    .SYNOPSIS
        Returns the current state of an Active Directory fine grained password
        policy.

    .PARAMETER Name
        Name of the fine grained password policy to be applied. Name must be
        exactly matching the subject to be applied to.

    .PARAMETER Precedence
        The rank the policy is to be applied.

    .PARAMETER SubjectsToInclude
        The ADPrinciple names to add to the policy, does not overwrite.

    .PARAMETER SubjectsToExclude
        The ADPrinciple names to remove from the policy, does not overwrite.

    .PARAMETER DomainController
        Active Directory domain controller to enact the change upon.

    .PARAMETER Credential
        Credentials used to access the domain.
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
        $SubjectsToExclude,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    Assert-Module -ModuleName 'ActiveDirectory'

    Write-Verbose -Message ($script:localizedData.QueryingFineGrainedPasswordPolicy -f $Name)

    $SubjectsDifferent = $false
    $getTargetResourceParams = @{
        Identity = $Name
    }

    if ($PSBoundParameters.ContainsKey('Credential'))
    {
        $getTargetResourceParams['Credential'] = $Credential
    }

    if ($PSBoundParameters.ContainsKey('DomainController'))
    {
        $getTargetResourceParams['DomainController'] = $DomainController
    }

    $policy = Get-ADFineGrainedPasswordPolicy -Filter { name -eq $Name }
    $subjects = (Get-ADFineGrainedPasswordPolicySubject -Identity $Name).Name

    if ($PSBoundParameters.ContainsKey('Subjects') -and -not [System.String]::IsNullOrEmpty($Subjects))
    {
        $SubjectsDifferent = $true
    }

    if ($PSBoundParameters.ContainsKey('SubjectsToInclude') -and -not [System.String]::IsNullOrEmpty($SubjectsToInclude))
    {
        if (Compare-Object -ReferenceObject $SubjectsToInclude -DifferenceObject $subjects -IncludeEqual | `
            Where-Object { $_.SideIndicator -eq "<=" })
        {
            $SubjectsDifferent = $true
        }
    }

    if ($PSBoundParameters.ContainsKey('SubjectsToExclude') -and -not [System.String]::IsNullOrEmpty($SubjectsToExclude))
    {
        if (Compare-Object -ReferenceObject $SubjectsToExclude -DifferenceObject $subjects -IncludeEqual | `
            Where-Object { $_.SideIndicator -eq "==" })
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

    .PARAMETER DomainController
        Active Directory domain controller to enact the change upon.

    .PARAMETER Credential
        Credentials used to access the domain.
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

    $getTargetResourceParams = @{
        Name       = $Name
        Precedence = $Precedence
    }

    if ($PSBoundParameters.ContainsKey('Credential'))
    {
        $getTargetResourceParams['Credential'] = $Credential
    }

    if ($PSBoundParameters.ContainsKey('DomainController'))
    {
        $getTargetResourceParams['DomainController'] = $DomainController
    }

    if ($PSBoundParameters.ContainsKey('Subjects') -and -not [System.String]::IsNullOrEmpty($Subjects))
    {
        $getTargetResourceParams['Subjects'] = $Subjects
    }

    if ($PSBoundParameters.ContainsKey('SubjectsToInclude') -and -not [System.String]::IsNullOrEmpty($SubjectsToInclude))
    {
        $getTargetResourceParams['SubjectsToInclude'] = $SubjectsToInclude
    }

    if ($PSBoundParameters.ContainsKey('SubjectsToExclude') -and -not [System.String]::IsNullOrEmpty($SubjectsToExclude))
    {
        $getTargetResourceParams['SubjectsToExclude'] = $SubjectsToExclude
    }

    $targetResource = Get-TargetResource @getTargetResourceParams
    $inDesiredState = $true

    if ($targetResource.Ensure -ne $Ensure)
    {
        $inDesiredState = $false
    }
    else
    {
        if ($targetResource.Ensure -eq 'Present')
        {
            foreach ($property in $mutablePropertyMap)
            {
                $propertyName = $property.Name

                if ($PSBoundParameters.ContainsKey($propertyName))
                {
                    $expectedValue = $PSBoundParameters[$propertyName]
                    $actualValue = $targetResource[$propertyName]

                    if ($expectedValue -ne $actualValue)
                    {
                        Write-Verbose -Message ($script:localizedData.ResourcePropertyValueIncorrect -f `
                        $propertyName, $expectedValue, $actualValue)
                        $inDesiredState = $false
                    }
                }
            }
        }
    }

    if ($targetResource.SubjectsDifferent)
    {
        Write-Verbose -Message ($script:localizedData.ResourcePropertyValueIncorrect -f `
        'Subjects are different', $false, $targetResource.SubjectsDifferent)
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

    Assert-Module -ModuleName 'ActiveDirectory'

    $getTargetResourceParams = @{
        Name       = $Name
        Precedence = $Precedence
    }

    if ($PSBoundParameters.ContainsKey('Credential'))
    {
        $getTargetResourceParams['Credential'] = $Credential
    }

    if ($PSBoundParameters.ContainsKey('DomainController'))
    {
        $getTargetResourceParams['DomainController'] = $DomainController
    }

    if ($PSBoundParameters.ContainsKey('SubjectsToInclude') -and -not [System.String]::IsNullOrEmpty($SubjectsToInclude))
    {
        $getTargetResourceParams['SubjectsToInclude'] = $SubjectsToInclude
    }

    if ($PSBoundParameters.ContainsKey('SubjectsToExclude') -and -not [System.String]::IsNullOrEmpty($SubjectsToExclude))
    {
        $getTargetResourceParams['SubjectsToExclude'] = $SubjectsToExclude
    }

    $targetResource = Get-TargetResource @getTargetResourceParams

    $PSBoundParameters['Identity'] = $Name

    if ($targetResource.Ensure -eq 'Present')
    {
        $setADFineGrainedPasswordPolicyParams = Get-ADCommonParameters @PSBoundParameters
    }
    else
    {
        $setADFineGrainedPasswordPolicyParams = Get-ADCommonParameters @PSBoundParameters -UseNameParameter
    }

    foreach ($property in $mutablePropertyMap)
    {
        $propertyName = $property.Name

        if ($PSBoundParameters.ContainsKey($propertyName))
        {
            $propertyValue = $PSBoundParameters[$propertyName]

            $setADFineGrainedPasswordPolicyParams[$propertyName] = $propertyValue

            Write-Verbose -Message ($script:localizedData.SettingPasswordPolicyValue -f $propertyName, $propertyValue)
        }
    }

    if (($targetResource.Ensure -eq 'Absent') -and ($Ensure -eq 'Present'))
    {
        Write-Verbose -Message ($script:localizedData.CreatingFineGrainedPasswordPolicy -f $Name)

        try
        {
            [ref] $null = New-ADFineGrainedPasswordPolicy @setADFineGrainedPasswordPolicyParams

            if ($PSBoundParameters.ContainsKey('Subjects') -and -not [System.String]::IsNullOrEmpty($Subjects))
            {
                [ref] $null = Add-ADFineGrainedPasswordPolicySubject -Identity $Name -Subjects $Subjects
            }
        }
        catch
        {
            Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, $_)
        }
    }
    elseif (($targetResource.Ensure -eq 'Present') -and ($Ensure -eq 'Present'))
    {
        Write-Verbose -Message ($script:localizedData.UpdatingFineGrainedPasswordPolicy -f $Name)

        try
        {
            [ref] $null = Set-ADFineGrainedPasswordPolicy @setADFineGrainedPasswordPolicyParams


            if ($PSBoundParameters.ContainsKey('Subjects') -and -not [System.String]::IsNullOrEmpty($Subjects))
            {
                $getExistingSubjectsToRemove = Get-ADFineGrainedPasswordPolicySubject -Identity $Name

                if ($getExistingSubjectsToRemove)
                {
                    Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, `
                    "Removing existing subjects count: $($getExistingSubjectsToRemove.Count)")

                    [ref] $null = Remove-ADFineGrainedPasswordPolicySubject -Identity $Name -Subjects $getExistingSubjectsToRemove -Confirm:$false
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
                        Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $subject, `
                        'ADPrinciple subject not found or other non-fatal error')
                    }
                }
            }

            if ($PSBoundParameters.ContainsKey('SubjectsToInclude') -and [System.String]::IsNullOrEmpty($Subjects))
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
                        Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $subject, `
                        'ADPrinciple subject not found or other non-fatal error')
                    }
                }
            }

            if ($PSBoundParameters.ContainsKey('SubjectsToExclude') -and [System.String]::IsNullOrEmpty($Subjects))
            {
                foreach ($subject in $SubjectsToExclude)
                {
                    try
                    {
                        Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, `
                        "Removing subject: $($subject)")

                        [ref] $null = Remove-ADFineGrainedPasswordPolicySubject -Identity $Name -Subjects $subject -Confirm:$false
                    }
                    catch
                    {
                        Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $subject, `
                        'ADPrinciple subject not found or other non-fatal error')
                    }
                }
            }
        }
        catch
        {
            Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, $_)
        }
    }
    elseif (($targetResource.Ensure -eq 'Present') -and ($Ensure -eq 'Absent'))
    {
        Write-Verbose -Message ($script:localizedData.RemovingFineGrainedPasswordPolicy -f $Name)

        try
        {
            if ($PSBoundParameters.ContainsKey('ProtectedFromAccidentalDeletion') -and (-not $ProtectedFromAccidentalDeletion))
            {
                Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, `
                'Attempting to remove the protection for accidental deletion')
                [ref] $null = Set-ADFineGrainedPasswordPolicy @setADFineGrainedPasswordPolicyParams
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.ResourceConfiguration -f $Name, `
                'ProtectedFromAccidentalDeletion is not defined or set to true, delete may fail if not explicitly set false')
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