# Immich-Authentik Integration Guide

A comprehensive guide to **_integrating Authentik OIDC_** with an **_Immich_** photo backup instance in a homelab environment.

## 1. Authentik Configuration

### Provider Setup

- Navigate to **Applications** > **Providers** and create an **_OAuth2/OpenID Provider_**.
- Fill out the details:

|                   Field                   | Setting                                                                   |
| :---------------------------------------: | :------------------------------------------------------------------------ |
|                 **Name**                  | `Immich - OIDC`                                                           |
|          **Authorization Flow**           | `default-provider-authorization-explicit-consent (Authorize Application)` |
|              **Client Type**              | `Confidential`                                                            |
| **Redirect URIs/Origins (Authorization)** | `app.immich:///oauth-callback`                                            |
| **Redirect URIs/Origins (Authorization)** | `https://immich.khangvum.com/auth/login`                                  |
| **Redirect URIs/Origins (Authorization)** | `https://immich.khangvum.com/user-settings`                               |

> [!IMPORTANT]
> Copy the generated **_Client ID_** and **_Client Secret_**, which are needed for Immich configuration later.

### Application Setup

- Navigate to **Applications** > **Applications** and create a **_New Application_**:
- Fill out the details:

|     Field      | Setting                       |
| :------------: | :---------------------------- |
|    **Name**    | `Immich`                      |
|  **Provider**  | Select `Immich - OIDC`        |
| **Launch URL** | `https://immich.khangvum.com` |

## 2. Immich OAuth Configuration

### System Settings

- Log in to the Immich instance as an **_Administrator_**.
- Navigate to **Administration** > **Settings** > **Authentication Settings**.
- Locate the **OAuth** section and configure the following parameters:

|         Field         | Value                                                  |
| :-------------------: | :----------------------------------------------------- |
| **Login with OAuth**  | **Enabled**                                            |
|    **issuer_url**     | `https://authentik.khangvum.com/application/o/immich/` |
|     **client_id**     | (Paste the **_Client ID_** from Authentik)             |
|   **Client secret**   | (Paste the **_Client Secret_** from Authentik)         |
|       **Scope**       | `openid email profile`                                 |
|    **Button Text**    | `Sign in with Authentik`                               |
|   **Auto Register**   | `CHECKED`                                              |
|    **Auto Launch**    | `UNCHECKED`                                            |

> [!IMPORTANT]
> Ensure the **Issuer URL** path terminates correctly with the trailing slash or matches the exact Authentik application endpoint provider path.

### References

[Integrate with Immich](https://integrations.goauthentik.io/media/immich/)
