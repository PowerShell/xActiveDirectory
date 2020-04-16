# Running Integration Tests

## VMware ESXi

_To be enhanced. Might be able to use [Invoke-VMScript](https://www.vmware.com/support/developer/windowstoolkit/wintk40u1/html/Invoke-VMScript.html)_
_to more resemble the Hyper-V steps._

### Requirements

- This requires a ESXi install on a physical server.

- The virtual machine should have at least 2GB of memory and 25GB of disk.

- The host should also have a disk with enough free
  space for a virtual machine plus snapshots (~30GB should
  suffice).

- The virtual machine need to have internet connectivity.

### Deploy VMware ESXi virtual machine

1. Downloaded the appropriate installation media, for example from
   [Windows Server Evaluations](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019).
1. Configure VM on a VMware ESXi host.
1. Install the server operating system using the downloaded media.
1. Make sure to install the necessary tools to be able to clone and build
   the repository. See the article [Getting Started as a Contributor](https://dsccommunity.org/guidelines/getting-started/)
   for the necessary tools.
1. Clone the repository to the domain controller using `git`.
1. Snapshot the virtual machine so it possible to revert to this state.

### Running the integration tests

1. Change location to the local repository folder.
1. Build the module using `.\build.ps1 -ResolveDependency -Tasks build`.
1. Build the first domain controller by running the integration test
   `Invoke-Pester .\tests\Integration\MSFT_ADDomain.Root.Integration.Tests.ps1`.
   The integration test will require a reboot.
1. Run the any additional integration tests by changing the path to the
   integration test in the previous test.

## Microsoft Hyper-V (PowerShell Direct)

### Requirements

- This requires a host that can run Hyper-V. For example Windows 10
  or Windows Server 2019 on either physical hardware with virtualization
  enabled (BIOS setting) or in a VM that supports nested virtualization.

  > In Azure (for example) the VM size `Standard E8-4s_v3` supports nested
  > virtualization and have 4 vCPUs and 64 GiB memory.

- The host should have enough memory to be able to run at least 4 VMs with
  2GB each simultaneous.
- The host should also have a disk with enough free
  space to hold the template and 4 VM's plus checkpoints (~150GB should
  suffice).

- Internet connectivity is required to create the base VM template (if updates
should be installed), but the lab that runs the integration tests does _not_
need Internet connectivity.

### Create Hyper-V base image template

There are many blog articles explaining this, just search for
"create a hyper-v template" in your favorite search engine.

The basic steps to create a base image template for the PC that should
host the Hyper-V virtual machines are.

1. Create VM with Windows Server 2016 or later (Desktop Experience or
   Server Core).
1. Export the VM.

The below steps will help to create a base image template that will be
used to create the one or more servers to run tests on.

>**Note:** All these steps are expected to be run in the same elevated
>PowerShell prompt. It also expects that you have downloaded the appropriate
>installation media, for example from [Windows Server Evaluations](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019)
>or the [direct link to the ISO](https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso).

<!-- markdownlint-disable MD031 - Fenced code blocks should be surrounded by blank lines -->
1. Create a Hyper-VM (Generation 2). In an elevated PowerShell prompt run
   this:
   ```powershell
   $windowsServerIsoPath = 'C:\_images\17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso'
   if (-not (Test-Path -Path $windowsServerIsoPath))
   {
       throw 'ISO path cannot be found.'
   }

   $virtualHardDiskPath = Get-VMHost | Select-Object -ExpandProperty 'VirtualHardDiskPath'

   $newVmParameters = @{
        Name = 'DSCAD-template'
        BootDevice = 'CD'
        MemoryStartupBytes = 2GB
        NoVHD = $true
        Generation = 2
        SwitchName = 'Default Switch'
    }

    $vm = New-VM @newVmParameters
    Set-VM -VM $vm -AutomaticCheckpointsEnabled $false -DynamicMemory
    $vmDiskPath = Join-Path -Path $virtualHardDiskPath -ChildPath 'DSCAD-template.vhdx'
    $vhd = New-VHD -Path $vmDiskPath -SizeBytes 25GB -Dynamic
    Add-VMHardDiskDrive -VM $vm -Path $vhd.Path
    Get-VMDvdDrive -VM $vm | Set-VMDvdDrive -Path $windowsServerIsoPath
    Start-VM -VM $vm
    ```
1. Continue the installation as normal in the Hyper-V Virtual Machine
   Connection.
   - You don't need to provide a product key.
   - You can set any password you like for the template, it will be re-set
     for each new VM that is deployed later.
1. (Optional) Install any updates.
1. (Optional) Make any personal modifications (if they will stick after
   the SysPrep we will do next).
1. In an elevated PowerShell prompt run this to
  [Sysprep generalize](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation)
  and return the VM (image) to the out-of-the-box-experience.
   ```powershell
   C:\Windows\System32\SysPrep\sysprep.exe /quiet /generalize /oobe /shutdown
   ```
1. Create the folder where we will store the exported image. _This folder can_
   _be located anywhere._
   ```powershell
   $templatesPath = 'C:\Hyper-V\Templates'
   New-Item -Path $templatesPath -ItemType 'Directory' -Force
   ```
1. Export the VM base image template.
   ```powershell
   Export-VM -VM $vm -Path $templatesPath
   ```
1. (Optional) The exported VM can be deleted once the export is finished.
   ```powershell
   Remove-VM -VM $vm -Force
   Remove-Item -Path $vmDiskPath -Force
   ```
<!-- markdownlint-enable MD031 -->

### Deploy Hyper-V virtual machines

This will deploy three virtual machines using the virtual machine template
exported in the previous step. These steps assume you have a PC with enough
memory (~32GB) and disk (~60GB) on the PC that will host the virtual machines.

>You can make changes to memory before starting the virtual machines, or
>change the default memory in the template above before exporting the base
>image template.

<!-- markdownlint-disable MD031 - Fenced code blocks should be surrounded by blank lines -->
1. Create a Hyper-V virtual switch to use for the private network between
   the virtual machines. _**Note:** Running the cmdlet `New-VMSwitch` more_
   _than once will create more than one virtual switch with the same name._
   ```powershell
   $virtualSwitchName = 'DSCADLabPrivate'
   if (-not (Get-VMSwitch -Name $virtualSwitchName -ErrorAction 'SilentlyContinue'))
   {
       New-VMSwitch -Name $virtualSwitchName -SwitchType 'Private'
   }
   ```
1. Deploy three virtual machines that will be used to configure three
   domain controllers.
   ```powershell
   $templateName = 'DSCAD-template'
   $templatesPath = 'C:\Hyper-V\Templates'
   $virtualMachinesPath = 'C:\Hyper-V\Virtual Machines'
   $virtualSwitchName = 'DSCADLabPrivate'

   $vmTemplatePath = (Get-ChildItem -Path (Join-Path -Path $templatesPath -ChildPath $templateName) -Recurse -Filter '*.vmcx').FullName

   $vmNames = @(
       'dc01'
       'dc02'
       'dc03'
   )

   foreach ($vmName in $vmNames)
   {
       $vmPath = Join-Path -Path $virtualMachinesPath -ChildPath $vmName
       $vm = Import-VM -Path $vmTemplatePath -Copy -GenerateNewId -VirtualMachinePath $vmPath -VhdDestinationPath  $vmPath -SnapshotFilePath $vmPath -SmartPagingFilePath $vmPath
       Set-VM -VM $vm -NewVMName $vmName -DynamicMemory
       Set-VM -VM $vm -AutomaticCheckpointsEnabled $false
       # TODO: This can be resolved by removing the ISO prior to exporting the template
       Get-VMDvdDrive -VM $vm | Set-VMDvdDrive -Path $null
       Get-VMNetworkAdapter -VM $vm | Connect-VMNetworkAdapter -SwitchName $virtualSwitchName
   }

   Get-VM -Name $vmNames | Start-VM -Verbose
   ```
1. On each started VM finish the installation by configuring the following
   in the Hyper-V Virtual Machine Connection.
   - Localization
   - (Optional) Product key
   - Accept license terms
   - Set local administrator password to `adminP@ssw0rd1`. _**Note:** This_
     _password **must** be the same as the one used in the integration test._
<!-- markdownlint-enable MD031 -->

### Test prerequisites

The host for the virtual machines must have access the Internet. The
below steps assumes the virtual machines that should run the integration
test are only connected to a private virtual switch and do not have access
to the Internet.

The below steps *must* be run in a elevated PowerShell console.

<!-- markdownlint-disable MD031 - Fenced code blocks should be surrounded by blank lines -->
1. Change directory to the root of your local working repository
   folder, e.g. cd 'c:\source\ActiveDirectoryDsc'.
   ```powershell
   cd c:\source\ActiveDirectoryDsc
   ```
1. Resolve dependencies and build the repository.
   ```powershell
   .\build.ps1 -ResolveDependency -Tasks build
   ```
1. Open a PowerShell Direct session to each virtual machine.
   ```powershell
   $localAdminPassword = ConvertTo-SecureString 'adminP@ssw0rd1' -AsPlainText -Force
   $localAdminUsername = '.\Administrator'

   $newObjectParameters = @{
       TypeName = 'System.Management.Automation.PSCredential'
       ArgumentList = @(
           $localAdminUsername,
           $localAdminPassword
       )
   }

   $localAdminCredential = New-Object @newObjectParameters

   $dc01Session = New-PSSession -VMName 'dc01' -Credential $localAdminCredential
   $dc02Session = New-PSSession -VMName 'dc02' -Credential $localAdminCredential
   $dc03Session = New-PSSession -VMName 'dc03' -Credential $localAdminCredential
   ```
1. Copy the required modules to each of the virtual machines.
   ```powershell
   $dependentModulePaths = @(
       '.\output\RequiredModules\Pester'
       '.\output\RequiredModules\PSDscResources'
       '.\output\RequiredModules\ComputerManagementDsc'
       '.\output\RequiredModules\NetworkingDsc'
   )

   $destinationPath = 'C:\Program Files\WindowsPowerShell\Modules'

   foreach ($dependentModulePath in $dependentModulePaths)
   {
       Copy-Item -ToSession $dc01Session -Path $dependentModulePath -Destination $destinationPath -Recurse -Force
       Copy-Item -ToSession $dc02Session -Path $dependentModulePath -Destination $destinationPath -Recurse -Force
       Copy-Item -ToSession $dc03Session -Path $dependentModulePath -Destination $destinationPath -Recurse -Force
   }
   ```
1. Copy the tests and the required modules to each of the virtual machines.
   ```powershell
   cd 'c:\source\ActiveDirectoryDsc'

   Get-ChildItem -Path '.\tests' | Copy-Item -ToSession $dc01Session -Destination 'c:\projects\ActiveDirectoryDsc\tests' -Recurse -Force
    Get-ChildItem -Path '.\tests' | Copy-Item -ToSession $dc02Session -Destination 'c:\projects\ActiveDirectoryDsc\tests' -Recurse -Force
    Get-ChildItem -Path '.\tests' | Copy-Item -ToSession $dc03Session -Destination 'c:\projects\ActiveDirectoryDsc\tests' -Recurse -Force
   ```
1. Configure prerequisites like computer name, IP address, and Windows features
   that is needed to promote a node to a domain controller. This creates
   the configuration .mof and the metadata .mof file on the respective
   nodes which will be executed in next steps.
   ```powershell
   Invoke-Command -Session $dc01Session -ScriptBlock {
      c:\projects\ActiveDirectoryDsc\tests\TestHelpers\Prepare-DscLab-dc01.ps1
   }

   Invoke-Command -Session $dc02Session -ScriptBlock {
      c:\projects\ActiveDirectoryDsc\tests\TestHelpers\Prepare-DscLab-dc02.ps1
   }

   Invoke-Command -Session $dc03Session -ScriptBlock {
      c:\projects\ActiveDirectoryDsc\tests\TestHelpers\Prepare-DscLab-dc03.ps1
   }
   ```
1. Configure the DSC Local Configuration Manager (LCM) on each virtual
   machine using the metadata .mof created in previous step.
   ```powershell
   $vmPSSessions = @(
      $dc01Session
      $dc02Session
      $dc03Session
   )
   Invoke-Command -Session $vmPSSessions -ScriptBlock {
      Set-DscLocalConfigurationManager -Path 'C:\DSC\Configuration' -ComputerName 'localhost' -Verbose -Force
   }
   ```
1. Run the configuration on each virtual machine to set up all the
   prerequisites. **The virtual machine will reboot during this.**
   ```powershell
   $vmPSSessions = @(
       $dc01Session
       $dc02Session
       $dc03Session
   )

   Invoke-Command -Session $vmPSSessions -ScriptBlock {
       Start-DscConfiguration -Path "C:\DSC\Configuration\" -ComputerName 'localhost' -Wait -Force -Verbose
   }
   ```
   A reboot will be required then the same configuration must be run again.
   Restart the node manually or use this
   ```powershell
   Restart-VM -Name 'dc01','dc02','dc03' -Type Reboot -Wait -For Heartbeat -Force
   ```
1. Wait until the node has been restarted and then verify that the configuration
   has been applied. This should report the status *Success* once the
   configuration is finished. _**Note:** Since the virtual machines rebooted_
   _we need to reconnect to the sessions._
   ```powershell
   $dc01Session = New-PSSession -VMName 'dc01' -Credential $localAdminCredential
   $dc02Session = New-PSSession -VMName 'dc02' -Credential $localAdminCredential
   $dc03Session = New-PSSession -VMName 'dc03' -Credential $localAdminCredential

   $vmPSSessions = @(
       $dc01Session
       $dc02Session
       $dc03Session
   )

   Invoke-Command -Session $vmPSSessions -ScriptBlock {
       Get-DscConfigurationStatus
   }
   ```
1. Set the execution policy to bypass. This makes the script certificate check
   faster when running Pester.
   ```powershell
   $vmPSSessions = @(
       $dc01Session
       $dc02Session
       $dc03Session
   )

   Invoke-Command -Session $vmPSSessions -ScriptBlock {
       Set-ExecutionPolicy -ExecutionPolicy 'Bypass' -Scope 'LocalMachine'
   }
   ```
1. At this point it would be good to checkpoint the servers.
   ```powershell
   Checkpoint-VM -Name 'dc01','dc02','dc03' -SnapshotName 'WithPreReq'
   ```

### Running the integration tests

By reverting to the checkpoint created before, these tests can be run
several times. The integration tests that depend on an already existing
domain can be run several times without reverting to the checkpoint. The
resources that need a clean environment are the resources that configure
the domain, e.g. `ADDomain` and `ADDomainController`.

1. Change directory to the root of your local working repository
   folder, e.g. cd 'c:\source\ActiveDirectoryDsc'.
   ```powershell
   cd 'c:\source\ActiveDirectoryDsc'
   ```
1. Reconnect the sessions after we created the checkpoint which make the
   session to disconnect.
   ```powershell
   $localAdminPassword = ConvertTo-SecureString 'adminP@ssw0rd1' -AsPlainText -Force
   $localAdminUsername = '.\Administrator'

   $newObjectParameters = @{
       TypeName = 'System.Management.Automation.PSCredential'
       ArgumentList = @(
           $localAdminUsername,
           $localAdminPassword
       )
   }

   $localAdminCredential = New-Object @newObjectParameters

   $dc01Session = New-PSSession -VMName 'dc01' -Credential $localAdminCredential
   $dc02Session = New-PSSession -VMName 'dc02' -Credential $localAdminCredential
   $dc03Session = New-PSSession -VMName 'dc03' -Credential $localAdminCredential
   ```
1. Copy the ActiveDirectoryDsc module to each of the virtual machines.
   ```powershell
   cd 'c:\source\ActiveDirectoryDsc'

   $dscModuleOutputPath = '.\output\ActiveDirectoryDsc'
   $destinationPath = 'C:\Program Files\WindowsPowerShell\Modules'

   Copy-Item -ToSession $dc01Session -Path $dscModuleOutputPath -Destination $destinationPath -Recurse -Force
   Copy-Item -ToSession $dc02Session -Path $dscModuleOutputPath -Destination $destinationPath -Recurse -Force
   Copy-Item -ToSession $dc03Session -Path $dscModuleOutputPath -Destination $destinationPath -Recurse -Force
   ```
1. Copy the tests to each of the virtual machines.
   ```powershell
   cd 'c:\source\ActiveDirectoryDsc'

   Get-ChildItem -Path '.\tests' | Copy-Item -ToSession $dc01Session -Destination 'c:\projects\ActiveDirectoryDsc\tests' -Recurse -Force
   Get-ChildItem -Path '.\tests' | Copy-Item -ToSession $dc02Session -Destination 'c:\projects\ActiveDirectoryDsc\tests' -Recurse -Force
   Get-ChildItem -Path '.\tests' | Copy-Item -ToSession $dc03Session -Destination 'c:\projects\ActiveDirectoryDsc\tests' -Recurse -Force
   ```
1. This runs the tests on the first domain controller. This test need to
   run twice because of a required reboot (see next step).
   ```powershell
   Invoke-Command -Session $dc01Session -ScriptBlock {
       cd 'c:\projects\ActiveDirectoryDsc'

       $testParameters = @{
           Verbose = $true
       }

       Invoke-pester -Script @(
           @{
               Path = '.\tests\Integration\MSFT_ADDomain.Root.Integration.Tests.ps1'
               Parameters = $testParameters
           }
       )
   }
   ```
   When the test finishes it will print a warning message asking for a reboot
   of the note. Restart the node manually or use this:
   ```powershell
   Restart-VM -Name 'dc01' -Type Reboot -Wait -For Heartbeat -Force
   ```
   After the node has restarted and finished (takes ~a minute), reconnect
   the session and then run the integration tests again by running the next
   step.
   ```powershell
   $dc01Session = New-PSSession -VMName 'dc01' -Credential $localAdminCredential
   ```
1. This runs the tests on the first domain controller.
   ```powershell
   Invoke-Command -Session $dc01Session -ScriptBlock {
       cd 'c:\projects\ActiveDirectoryDsc'

       $testParameters = @{
           Verbose = $true
       }

       Invoke-pester -Script @(
           @{
               Path = '.\tests\Integration\MSFT_ADDomain.Root.Integration.Tests.ps1'
               Parameters = $testParameters
           }
           @{
               Path = '.\tests\Integration\MSFT_ADOptionalFeature.Integration.Tests.ps1'
               Parameters = $testParameters
           }
           @{
               Path = '.\tests\Integration\MSFT_ADComputer.Integration.Tests.ps1'
               Parameters = $testParameters
           }
           @{
               Path = '.\tests\Integration\MSFT_ADDomainControllerProperties.Integration.Tests.ps1'
               Parameters = $testParameters
           }
       )
   }
   ```
<!-- markdownlint-enable MD031 -->
