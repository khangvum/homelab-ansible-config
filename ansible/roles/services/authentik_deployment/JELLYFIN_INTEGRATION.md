# Jellyfin-Authentik Integration Guide

A comprehensive guide to **_integrating Authentik OIDC_** with a **_Jellyfin_** instance in a homelab environment.

## 1. Authentik Configuration

### Provider Setup

- Navigate to **Applications** > **Providers** and create an **_OAuth2/OpenID Provider_**.
- Fill out the details:

  |           Field           | Setting                                                                   |
  | :-----------------------: | ------------------------------------------------------------------------- |
  |         **Name**          | `Jellyfin - OIDC`                                                         |
  |  **Authorization Flow**   | `default-provider-authorization-explicit-consent (Authorize Application)` |
  |      **Client Type**      | `Confidential`                                                            |
  | **Redirect URIs/Origins** | `https://jellyfin.khangvum.com/sso/OID/redirect/authentik`                 |

> [!IMPORTANT]
> Copy your **_Client ID_** and **_Client Secret_**, which are needed for Jellyfin plugin configuration later.

### Application Setup

- Navigate to **Applications** > **Applications** and create a **_New Application_**:
- Fill out the details:

  |     Field      | Setting                        |
  | :------------: | ------------------------------ |
  |    **Name**    | `Jellyfin`                     |
  |  **Provider**  | Select `Jellyfin - OIDC`       |
  | **Launch URL** | `https://jellyfin.khangvum.com` |

## 2. Jellyfin Plugin Configuration

### Plugin Installation

- Log in to Jellyfin instance as **_Administrator_**.
- Navigate to **Dashboard** > **Plugins** > **Manage Repositories**.
- Click **New Repository**, and fill out the details:

  |        Field        | Value                                                                                      |
  | :-----------------: | ------------------------------------------------------------------------------------------ |
  | **Repository Name** | `SSO-Auth`                                                                                 |
  | **Repository URL**  | `https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json` |

- Go back to **Plugins**, search for **_SSO-Auth_**, and click **_Install_**.

> [!IMPORTANT]
> **_Restart Jellyfin_** to initialize the plugin.

### Plugin Settings

Once restarted, click on the **_SSO-Auth_** plugin icon in the installed plugins list to **_configure the connection_**:

|                     Field                     | Value                                                                                   |
| :-------------------------------------------: | --------------------------------------------------------------------------------------- |
|          **Name of OpenID Provider**          | `authentik`                                                                             |
|              **OpenID Endpoint**              | `http://authentik.khangvum.lab/application/o/jellyfin/.well-known/openid-configuration` |
|             **OpenID Client ID**              | (Paste the **_Client ID_** from Authentik)                                              |
|           **OpenID Client Secret**            | (Paste the **_Client Secret_** from Authentik)                                          |
|                  **Enabled**                  | `CHECKED`                                                                               |
|      **Enable Authorization by Plugin**       | `CHECKED`                                                                               |
| **Disable OpenID HTTPS Discovery (Insecure)** | `CHECKED`                                                                               |

> [!IMPORTANT]
> **_Restart Jellyfin_** again after saving these settings for the changes to **_take effect_**.

## 3. Login Branding

To display the **_"Sign in with SSO"_** button, inject this HTML into the **_Login disclaimer_** (found in **Dashboard** > **Branding**):

```html
<form action="https://jellyfin.khangvum.com/sso/OID/start/authentik">
  <button class="raised block emby-button button-submit">
    Sign in with SSO
  </button>
</form>
```

### References

[Integrate with Jellyfin](https://integrations.goauthentik.io/media/jellyfin/)