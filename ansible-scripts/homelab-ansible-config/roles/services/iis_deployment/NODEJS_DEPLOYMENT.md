# Node.js Web Page Deployment on IIS

A **_web application deployment_** process for Windows, leveraging **_Internet Information Services_** (**_IIS_**) as a **_reverse proxy_** to host modern web **_React front ends_** (_e.g.,_ Vite), **_Node.js back ends_** (_e.g.,_ Express), and **_Supabase_**.

## 1. Environment Preparation

On `KVM-WEB01`:

- Install **_[Node.js (LTS)](https://nodejs.org/en/download)_**.
- Install **_[URL Rewrite Module](https://www.iis.net/downloads/microsoft/url-rewrite)_**.
- Install **_[Application Request Routing (ARR)](https://www.iis.net/downloads/microsoft/application-request-routing)_**.
- **_Configure ARR_**:
  - Open **_Internet Information Services (IIS) Manager_** (`inetmgr`) > **KVM-WEB01** > **Application Request Routing Cache** > **Server Proxy Settings...**.
  - Check **_Enable proxy_** and click **_Apply_**.

## 2. Process Management (PM2) Installation & Configuration

- Install **_[PM2](https://www.npmjs.com/package/pm2)_** globally to manage the application lifecycle and ensure the Node process remains active:

  ```powershell
  npm install pm2 -g
  ```

- Start the application from the **_project root_** (_e.g.,_ `C:\inetpub\wwwroot\itinder.khangvum.lab`):

  ```powershell
  pm2 start server.js --name "itinder.khangvum.lab"
  ```

- Install and configure the **_Windows service helper_** to ensure the application **_starts automatically on boot_**:

  ```powershell
  npm install pm2-windows-service -g
  pm2-service-install
  pm2 save
  ```

> [!TIP]
>
> - When running `pm2-service-install`, set `PM2_HOME` to **_`C:\pm2`_** (or a similar root-level directory).
> - This allows for **_system-wide access_**, ensuring the service can manage the processes **_regardless_** of **_which user_** is **_logged into the server_**.

## 3. Front End Build (React)

- **_Compile_** the **_React front end_** inside the `/client` directory (this project uses **_Vite_**):

  ```powershell
  npx vite build & xcopy /hiev dist\* ..\server\public\ /Y
  ```

> [!NOTE]
> This command **_compiles the React assets_** and **_synchronizes_** the `/client/dist` contents with the `/server/public` directory.

- **_Copy_** the content of the **_`/server` folder_** into **_`C:\inetpub\wwwroot\itinder.khangvum.lab`_** on **_`KVM-WEB01`_**.
- Open **_Internet Information Services (IIS) Manager_** (`inetmgr`), right-click **Sites** > **Add Website...**:

  |     Property      | Value                                                                                           |
  | :---------------: | ----------------------------------------------------------------------------------------------- |
  |   **Site name**   | `ITinder`                                                                                       |
  | **Physical path** | `C:\inetpub\wwwroot\itinder.khangvum.lab`                                                       |
  |    **Binding**    | Type: `http`<br>IP address: `All Unassigned`<br>Port: `80`<br>Host name: `itinder.khangvum.lab` |
