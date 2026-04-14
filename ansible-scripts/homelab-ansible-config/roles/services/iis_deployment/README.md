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
