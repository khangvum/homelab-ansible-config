# Windows Configuration Automation with Ansible

A **_Windows configuration automation_** solution powered by **_Ansible_**, containerized with **_Docker_**. This setup simplifies the Windows systems management by leveraging Ansible's **_idempotent_** and **_declarative configuration_** approach, streamlining **_Infrastructure as Code_** (**_IaC_**) principles for Windows environments.

## Features

-   **_Agentless_** architecture powered by **_Ansible_**, utilizing **_SSH_**.
-   **_Docker-based controller_** for environment consistency across platforms.
-   **_Modular role-based_** configuration and **_tag-based_** execution for targeted provisioning.
-   **_Centralized variable management_** using external YAML files.

## Roles

Role                    |Description
:----------------------:|:----------------------------------
`hostname_configuration`|Sets the **_hostname_** of Windows machines
`ntp_configuration`     |Configures **_NTP settings_** for time synchronization
`system_configuration`  |Applies **_system-wide settings_**
`user_configuration`    |Manages **_local user accounts_** and **_passwords_**
`windows_updates`       |Performs **_Windows updates_**

## Prerequisites

-   **_[OpenSSH Server](https://github.com/PowerShell/Win32-OpenSSH/releases/latest)_** installed on the targeted hosts.
-   **_SSH Service_** enabled on the targeted hosts:

    ```powershell
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    ```

-   **_SSH_** allowed through the **_firewall_**:

    ```powershell
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -Profile Any
    ```

-   **_SSH connection_** verified **_once_** from the controller to each host:

    ```bash
    ssh administrator@<IP_ADDRESS>
    ```

    **_Accept the host key_** on first connection by typing `yes` when prompted.

