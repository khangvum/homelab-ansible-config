# Web Page Deployment on IIS

An **_Ansible role_** facilitates the **_web page deployment_** process for **_Windows Server 2025_** (_e.g.,_ `KVM-WEB01`)

## Supported Deployment Stacks

### 1. .NET, Vue, and SQL Server

- **Pattern**: Integrated IIS hosting using the .NET Hosting Bundle.
- **Database**: SQL Server 2022 hosted on `KVM-DB01`.
- **Documentation**: [.NET Deployment Documentation](./DOTNET_DEPLOYMENT.md)

### 2. Node.js, React, and

- **Pattern**: IIS as a Reverse Proxy with [PM2](https://www.npmjs.com/package/pm2) process management.
- **Database**: Supabase.
- **Documentation**: [Node.js Deployment Documentation](./NODEJS_DEPLOYMENT.md)

> [!TIP]
> To simulate **_production domains_**, a new **_Forward Lookup Zone_** can be created on the **_DNS server_** (_e.g.,_ **_`KVM-DC01`_**)and linked via **_IIS Bindings_**:
>
> 1. DNS Configuration:
>
> - On the **_DNS server_** (_e.g.,_ **_`KVM-DC01`_**), open **_DNS Manager_** (`dnsmgmt.msc`).
> - Right click on **Forward Lookup Zone** > **New Zone...**.
> - Follow the wizard to create a **_Primary Zone_** for a domain (_e.g.,_ `itinder.com`, `itinder.ca`).
> - Within the new zone, add a new **_A record_** by right-clicking > **New Host (A or AAAA)...**:

>   |    Property    | Value                                |
>   | :------------: | ------------------------------------ |
>   |    **Name**    | (Blank)                              |
>   | **IP address** | The IP of the IIS Server `KVM-WEB01` |
>
> 2. IIS Binding Update:
> 
> - On **_`KVM-WEB01`_**, open **_Internet Information Services (IIS) Manager_** (`inetmgr`).
> - Select the appropriate site (_e.g._ `ITinder`) and click **Bindings...** in the **_Actions_** pane.
> - Click **Add...** and enter the **_new domain_** (_e.g.,_ `itinder.com`) into the **_Host name_** field.
