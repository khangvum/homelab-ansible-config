$changed = $false
$state = "<STATE>".ToLower()
$existingVM = Get-VM -Name "<HOSTNAME>" -ErrorAction SilentlyContinue

if ($state -eq "present") {
    $vmName = "<HOSTNAME>"
    $vmPath = "<PARENT_DIR>\$vmName"
    $vmDisk = "$vmPath\$vmName.vhdx"
    $vmISO  = "$vmPath\<ISO_PATH>"
    $enableTPM = "<TPM>".ToLower()

    # If the VM does not exist, create it
    if (-not $existingVM) {
        New-VM -Name $vmName -MemoryStartupBytes <MEMORY>GB -BootDevice CD -NoVHD -Path $vmPath -Generation <GENERATION>

        # Remove the default network adapter
        Remove-VMNetworkAdapter -VMName $vmName -Name "Network Adapter"

        # Attach all switches from the list
        $allSwitches = @(
            # Example: @{ name = '<SWITCH_NAME>'; adapter = '<ADAPTER_NAME>' }
            @{ name = '<SWITCH1>'; adapter = '<ADAPTER1>' }
            @{ name = '<SWITCH2>'; adapter = '<ADAPTER2>' }
        )
        foreach ($switch in $allSwitches) {
            Add-VMNetworkAdapter -VMName $vmName -SwitchName $switch.name
        }

        # Disable dynamic memory
        Set-VMMemory -VMName $vmName -DynamicMemoryEnabled $false

        # Enable TPM if specified
        if ($enableTPM -eq "true") {
            Set-VMKeyProtector -VMName $vmName -NewLocalKeyProtector
            Enable-VMTPM -VMName $vmName
            $changed = $true
        }

        # Use an existing VHD if available
        if (Test-Path $vmDisk) {
            Add-VMHardDiskDrive -VMName $vmName -Path $vmDisk
        } 
        # Otherwise, create a new VHD
        else {
            New-VHD -Path $vmDisk -SizeBytes <STORAGE>GB -Dynamic
            Add-VMHardDiskDrive -VMName $vmName -Path $vmDisk
        } 

        # Attach the ISO file if available
        if (Test-Path $vmISO) {
            Set-VMDvdDrive -VMName $vmName -Path $vmISO
        }

        # Set the CPU
        Set-VMProcessor -VMName $vmName -Count <CPU>

        # Set secure boot template
        Set-VMFirmware -VMName $vmName -SecureBootTemplate "<SECURE_BOOT_TEMPLATE>"

        $changed = $true
    }
    # If the VM already exists, update the specs
    else {
        # Update the CPU
        if ($existingVM.ProcessorCount -ne <CPU>) {
            Set-VMProcessor -VMName $vmName -Count <CPU>
            $changed = $true
        }

        # Update the memory
        if (((Get-VMMemory -VMName $vmName).Startup / 1GB) -ne <MEMORY>) {
            Set-VMMemory -VMName $vmName -StartupBytes <MEMORY>GB -DynamicMemoryEnabled $false
            $changed = $true
        }

        # Enable TPM if specified
        $currentTPM = (Get-VMSecurity $vmName).TPMEnabled.ToString().ToLower()
        if ($enableTPM -eq "true" -and $currentTPM -eq "false") {
            Set-VMKeyProtector -VMName $vmName -NewLocalKeyProtector
            Enable-VMTPM -VMName $vmName
            $changed = $true
        }
        elseif ($enableTPM -eq "false" -and $currentTPM -eq "true") {
            Disable-VMTPM -VMName $vmName
            $changed = $true
        }

        # Update the VHD path
        $currentVHD = Get-VMHardDiskDrive -VMName $vmName
        if ($currentVHD.Path -ne $vmDisk) {
            Remove-VMHardDiskDrive -VMName $vmName -ControllerType $currentVHD.ControllerType -ControllerNumber $currentVHD.ControllerNumber -ControllerLocation $currentVHD.ControllerLocation

            # Use an existing VHD if available
            if (Test-Path $vmDisk) {
                Add-VMHardDiskDrive -VMName $vmName -Path $vmDisk
            } 
            # Otherwise, create a new VHD
            else {
                New-VHD -Path $vmDisk -SizeBytes <STORAGE>GB -Dynamic
                Add-VMHardDiskDrive -VMName $vmName -Path $vmDisk
            }

            $changed = $true
        }

        # Update the vSwitch
        $currentSwitches = (Get-VMNetworkAdapter -VMName $vmName).SwitchName
        $allSwitches = @(
            # Example: @{ name = '<SWITCH_NAME>'; adapter = '<ADAPTER_NAME>' }
            @{ name = '<SWITCH1>'; adapter = '<ADAPTER1>' }
            @{ name = '<SWITCH2>'; adapter = '<ADAPTER2>' }
        )
        foreach ($switch in $allSwitches) {
            if ($currentSwitches -notcontains $switch.name) {
                Connect-VMNetworkAdapter -VMName $vmName -SwitchName $switch.name
                $changed = $true
            }
        }

        # Update the ISO file
        $currentDVDDrive = Get-VMDvdDrive -VMName $vmName
        if ($currentDVDDrive -and $currentDVDDrive.Path -ne $vmISO -and (Test-Path $vmISO)) {
            Set-VMDvdDrive -VMName $vmName -Path $vmISO
            $changed = $true
        }

        # Set secure boot template
        if ((Get-VMFirmware -VMName $vmName).SecureBootTemplate -ne "<SECURE_BOOT_TEMPLATE>") {
            Set-VMFirmware -VMName $vmName -SecureBootTemplate "<SECURE_BOOT_TEMPLATE>"
            $changed = $true
        }
    }
}
elseif ($state -eq "absent") {
    if ($existingVM) {
        # Stop the VM if it is running
        if ($existingVM.State -eq "Running") {
            Stop-VM -Name "<HOSTNAME>" -Force
        }

        Remove-VM -Name "<HOSTNAME>" -Force
        $changed = $true
    }

    # Remove the VM's files
    Get-ChildItem -Path "<PARENT_DIR>\<HOSTNAME>" -Recurse -Force |
    Where-Object { $_.Name -like "*<HOSTNAME>*" } |
    ForEach-Object {
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}
else {
    Write-Error "Invalid state: $state. Use 'present' or 'absent'."
}