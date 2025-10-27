param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("present", "absent")]
    [string]$State,

    [Parameter(Mandatory = $true)]
    [string]$Hostname,

    [Parameter(Mandatory = $true)]
    [int]$CPU,

    [Parameter(Mandatory = $true)]
    [UInt64]$Memory,   # GB

    [Parameter(Mandatory = $true)]
    [UInt64]$Storage,  # GB

    [Parameter(Mandatory = $true)]
    [int]$Generation,

    [Parameter(Mandatory = $false)]
    [bool]$TPM = $false,

    [Parameter(Mandatory = $true)]
    [string]$ParentDir,

    [Parameter(Mandatory = $false)]
    [string]$ISODestination,

    [Parameter(Mandatory = $false)]
    [string]$SecureBootTemplate = "MicrosoftWindows",

    [Parameter(Mandatory = $false)]
    [array]$Switches = @(
        @{ name = 'KVM-SRV01-SW01'; adapter = 'Wi-Fi' },
        @{ name = 'KVM-SRV01-SW02'; adapter = 'Ethernet' }
    )
)

# Initialize variables from the parameters
$changed = $false
$state = $State.ToLower()
$existingVM = Get-VM -Name $Hostname -ErrorAction SilentlyContinue

if ($state -eq "present") {
    $vmName = $Hostname
    $vmPath = "$ParentDir\$vmName"
    $vmDisk = "$vmPath\$vmName.vhdx"
    $vmISO  = "$vmPath\$ISODestination"
    $enableTPM = "$TPM".ToLower()

    # If the VM does not exist, create it
    if (-not $existingVM) {
        New-VM -Name $vmName -MemoryStartupBytes $Memory -BootDevice CD -NoVHD -Path $vmPath -Generation $Generation

        # Remove the default network adapter
        Remove-VMNetworkAdapter -VMName $vmName -Name "Network Adapter"

        # Attach all switches from the list
        $allSwitches = $Switches
        foreach ($switch in $allSwitches) {
            Add-VMNetworkAdapter -VMName $vmName -SwitchName $switch.name -Name $switch.adapter
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
            New-VHD -Path $vmDisk -SizeBytes $Storage -Dynamic
            Add-VMHardDiskDrive -VMName $vmName -Path $vmDisk
        } 

        # Attach the ISO file if available
        if (Test-Path $vmISO) {
            Set-VMDvdDrive -VMName $vmName -Path $vmISO
        }

        # Set the CPU
        Set-VMProcessor -VMName $vmName -Count $CPU

        # Set secure boot template
        Set-VMFirmware -VMName $vmName -SecureBootTemplate $SecureBootTemplate

        $changed = $true
    }
    # If the VM already exists, update the specs
    else {
        $wasRunning = $false
        $needsShutdown = $false
        
        # Check if any changes require VM shutdown
        if ($existingVM.ProcessorCount -ne $CPU) {
            $needsShutdown = $true
        }
        
        $currentTPM = (Get-VMSecurity $vmName).TPMEnabled.ToString().ToLower()
        if (($enableTPM -eq "true" -and $currentTPM -eq "false") -or ($enableTPM -eq "false" -and $currentTPM -eq "true")) {
            $needsShutdown = $true
        }
        
        $currentVHD = Get-VMHardDiskDrive -VMName $vmName
        if ($currentVHD.Path -ne $vmDisk) {
            $needsShutdown = $true
        }
        
        $currentSwitches = (Get-VMNetworkAdapter -VMName $vmName).SwitchName
        $allSwitches = $Switches
        foreach ($switch in $allSwitches) {
            if ($currentSwitches -notcontains $switch.name) {
                $needsShutdown = $true
                break
            }
        }
        
        if ((Get-VMFirmware -VMName $vmName).SecureBootTemplate -ne $SecureBootTemplate) {
            $needsShutdown = $true
        }
        
        # Shutdown VM if needed
        if ($needsShutdown -and $existingVM.State -eq "Running") {
            Write-Host "Stopping $vmName for configuration changes..."
            Stop-VM -Name $vmName -Force
            $wasRunning = $true
        }

        # Update the CPU
        if ($existingVM.ProcessorCount -ne $CPU) {
            Set-VMProcessor -VMName $vmName -Count $CPU
            $changed = $true
        }

        # Update the memory (can be done while running)
        if (((Get-VMMemory -VMName $vmName).Startup / 1GB) -ne $Memory) {
            Set-VMMemory -VMName $vmName -StartupBytes $Memory -DynamicMemoryEnabled $false
            $changed = $true
        }

        # Enable TPM if specified
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
        if ($currentVHD.Path -ne $vmDisk) {
            Remove-VMHardDiskDrive -VMName $vmName -ControllerType $currentVHD.ControllerType -ControllerNumber $currentVHD.ControllerNumber -ControllerLocation $currentVHD.ControllerLocation

            # Use an existing VHD if available
            if (Test-Path $vmDisk) {
                Add-VMHardDiskDrive -VMName $vmName -Path $vmDisk
            } 
            # Otherwise, create a new VHD
            else {
                New-VHD -Path $vmDisk -SizeBytes $Storage -Dynamic
                Add-VMHardDiskDrive -VMName $vmName -Path $vmDisk
            }

            $changed = $true
        }

        # Update the vSwitch
        foreach ($switch in $allSwitches) {
            if ($currentSwitches -notcontains $switch.name) {
                Connect-VMNetworkAdapter -VMName $vmName -SwitchName $switch.name -Name $switch.adapter
                $changed = $true
            }
        }

        # Update the ISO file (can be done while running)
        $currentDVDDrive = Get-VMDvdDrive -VMName $vmName
        if ($currentDVDDrive -and $currentDVDDrive.Path -ne $vmISO -and (Test-Path $vmISO)) {
            Set-VMDvdDrive -VMName $vmName -Path $vmISO
            $changed = $true
        }

        # Set secure boot template
        if ((Get-VMFirmware -VMName $vmName).SecureBootTemplate -ne $SecureBootTemplate) {
            Set-VMFirmware -VMName $vmName -SecureBootTemplate $SecureBootTemplate
            $changed = $true
        }
        
        # Start the VM if it was running before being stopped
        if ($wasRunning) {
            Write-Host "Starting $vmName..."
            Start-VM -Name $vmName
        }
    }
}
elseif ($state -eq "absent") {
    if ($existingVM) {
        # Stop the VM if it is running
        if ($existingVM.State -eq "Running") {
            Stop-VM -Name $vmName -Force
        }

        Remove-VM -Name $vmName -Force
        $changed = $true
    }

    # Remove the VM's files
    Get-ChildItem -Path "$ParentDir\$vmName" -Recurse -Force |
    Where-Object { $_.Name -like "*$vmName*" } |
    ForEach-Object {
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}
else {
    Write-Error "Invalid state: $state. Use 'present' or 'absent'."
}