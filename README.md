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
`hyper-v_configuration` |Installs **_Hyper-V_** and configures **_virtual switches_**
`ntp_configuration`     |Configures **_NTP settings_** for time synchronization
`region_configuration`  |Sets **_regional_** and **_locale settings_**
`system_configuration`  |Applies **_system-wide settings_**
`user_configuration`    |Manages **_local user accounts_** and **_passwords_**
`vm_deployment`         |Creates **_VMs_** on **_Hyper-V hosts_**
`windows_updates`       |Performs **_Windows updates_**

## Prerequisites

-   **_[OpenSSH Server](https://github.com/PowerShell/Win32-OpenSSH/releases/latest)_** installed on the targeted hosts. Alternatively, this can be installed via **_PowerShell_**:

    ```powershell
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    ```

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

## Applying Configuration

1.  **Update the inventory and variable files:**

-   Update [`inventory.yml`](ansible-scripts/windows-config/inventory_template.yml) to specify your actual Windows hosts.
-   Update [`vm_var.yml`](ansible-scripts/windows-config/vm_var.yml) to define the VMs and their specifications to be created and configured.
-   Update [`windows_var.yml`](ansible-scripts/windows-config/windows_var_template.yml) to indicate environment-specific variables (_e.g._ usernames, passwords, hostnames, etc.)

2.  **Start the Ansible environment:**

    ```bash
    docker compose up -d
    ```

3.  **Access the running Ansible container:**

    ```bash
    docker exec -it ansible_service /bin/bash
    ```

4.  **Execute the playbook to apply the settings:**

    ```bash
    ansible-playbook site.yml -i inventory.yml
    ```

>   [!NOTE]
>   Use `-t` option to selectively run specific plays:
>
>   ```bash
>   ansible-playbook site.yml -i inventory.yml -t global_configuration
>   ```