# Windows Configuration Automation with Ansible

A **_Windows configuration automation_** solution powered by **_Ansible_**, containerized with **_Docker_**. This setup simplifies the Windows systems management by leveraging Ansible's **_idempotent_** and **_declarative configuration_** approach, streamlining **_Infrastructure as Code_** (**_IaC_**) principles for Windows environments.

## Features

-   **_Agentless_** architecture powered by **_Ansible_**, utilizing **_SSH_**.
-   **_Docker-based controller_** for environment consistency across platforms.
-   **_Modular role-based_** configuration and **_tag-based_** execution for targeted provisioning.
-   **_Centralized variable management_** using external YAML files.

## Filesystem Hierarchy

```
└── windows-config
    ├── ansible-docker-settings
    │   ├── Dockerfile
    │   └── supervisord.conf
    ├── ansible-scripts
    │   ├── windows-config
    │   │   ├── roles
    │   │   │   ├── hostname_configuration
    │   │   │   ├── ntp_configuration
    │   │   │   ├── system_configuration
    │   │   │   ├── user_configuration
    │   │   │   └── windows_updates
    │   │   ├── inventory.yml
    │   │   ├── windows_var.yml
    │   │   ├── site.yml
    │   └── ansible.cfg
    └── docker-compose.yml
```

### ansible-docker-settings

`docker-compose.yml` defines the **_Dockerized Ansible environment_** built with **_Ubuntu-24.04_** to ensure consistency across machines, including:

File                |Description
:------------------:|:----------------------------------
`Dockerfile`        |Builds the container with **_Ansible_**, **_SSH_**, and the required **_Ansible collections_**
`supervisord.conf`  |Keeps **_SSHD active_** using **_Supervisor_** for remote access
`ansible.cfg`       |Defines Ansible's **_default behavior_**, including inventory and path logging

### ansible-scripts

`site.yml` is the main playbook, executing all roles based on, including:

-   `inventory.yml`: Defines the list of **_Windows target hosts_**, grouped by environment or function.
-   `windows_var.yml`: **_Variable declaration file_** used across roles for flexible configuration.
-   Roles:

Role                    |Description
:----------------------:|:----------------------------------
`hostname_configuration`|Sets the **_hostname_** of Windows machines
`ntp_configuration`     |Configures **_NTP settings_** for time synchronization
`system_configuration`  |Applies **_system-wide settings_**
`user_configuration`    |Manages **_local user accounts_** and **_passwords_**
`windows_updates`       |Performs **_Windows updates_**
