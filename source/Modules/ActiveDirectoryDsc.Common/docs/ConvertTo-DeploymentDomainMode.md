---
external help file: ActiveDirectoryDsc.Common-help.xml
Module Name: ActiveDirectoryDsc.Common
online version:
schema: 2.0.0
---

# ConvertTo-DeploymentDomainMode

## SYNOPSIS
Converts a ModeId or ADDomainMode object to a DomainMode object.

## SYNTAX

### ById
```
ConvertTo-DeploymentDomainMode -ModeId <UInt16> [<CommonParameters>]
```

### ByName
```
ConvertTo-DeploymentDomainMode -Mode <ADDomainMode> [<CommonParameters>]
```

## DESCRIPTION
The ConvertTo-DeploymentDomainMode function is used to convert a ModeId or
Microsoft.ActiveDirectory.Management.ADDomainMode object to a
Microsoft.DirectoryServices.Deployment.Types.DomainMode object.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Mode
The Microsoft.ActiveDirectory.Management.ADDomainMode value to convert to a
Microsoft.DirectoryServices.Deployment.Types.DomainMode type.

```yaml
Type: System.Nullable`1[Microsoft.ActiveDirectory.Management.ADDomainMode]
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModeId
The ModeId value to convert to a Microsoft.DirectoryServices.Deployment.Types.DomainMode type.

```yaml
Type: System.UInt16
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### Microsoft.DirectoryServices.Deployment.Types.DomainMode
## NOTES

## RELATED LINKS