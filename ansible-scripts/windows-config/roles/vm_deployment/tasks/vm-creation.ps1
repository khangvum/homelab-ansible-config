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
        New-VM -Name $vmName -MemoryStartupBytes <MEMORY>GB -BootDevice CD -NoVHD  -Path $vmPath -Generation <GENERATION>

        # Remove the default network adapter
        Remove-VMNetworkAdapter -VMName $vmName -Name "Network Adapter"

        # Attach all switches from the list
        $allSwitches = @(
            # @{ name = '<SWITCH_NAME>'; adapter = '<ADAPTER_NAME>' }
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
    }
}