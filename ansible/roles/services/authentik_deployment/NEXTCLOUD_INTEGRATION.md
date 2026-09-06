# Nextcloud-Authentik Integration Guide

A comprehensive guide to **_integrating Authentik OIDC_** with a **_Nextcloud_** instance in a homelab environment, featuring custom attribute mapping for storage quotas, groups, and direct user ID binding.

## 1. Authentik Configuration

### Custom Scope Mapping

Before creating the provider, set up a custom scope mapping to pass **_Nextcloud-specific attributes_**:

- Navigate to **Customization** > **Property Mappings**.
- Click **New Property Mapping**.
- Fill out the details:
  - **Name**: `Nextcloud Profile`
  - **Scope name**: `nextcloud`
  - **Expression**:

    ```python
    groups = [
        entitlement.name
        for entitlement in request.user.app_entitlements(provider.application)
    ]
    quota = (
        request.user.app_entitlements_attributes(provider.application).get("nextcloud_quota")
        or request.user.group_attributes().get("nextcloud_quota")
    )

    return {
        "name": request.user.name,
        "groups": groups,
        "quota": quota,
        "user_id": request.user.username,
    }
    ```

### Provider Setup

- Navigate to **Applications** > **Providers** and create an **_OAuth2/OpenID Provider_**.
- Fill out the details:

|                   Field                   | Setting                                                                   |
| :---------------------------------------: | :------------------------------------------------------------------------ |
|                 **Name**                  | `Nextcloud - OIDC`                                                        |
|          **Authorization Flow**           | `default-provider-authorization-explicit-consent (Authorize Application)` |
|              **Client Type**              | `Confidential`                                                            |
| **Redirect URIs/Origins (Authorization)** | `https://nextcloud.khangvum.com/apps/user_oidc/code`                      |
|  **Redirect URIs/Origins (Post Logout)**  | `https://nextcloud.khangvum.com`                                          |
|             **Subject Mode**              | `Based on the User's UUID`                                                |
|            **Selected Scopes**            | Include `Nextcloud Profile`                                               |

> [!IMPORTANT]
> Copy your **_Client ID_** and **_Client Secret_**, which are needed for Nextcloud configuration later.

### Application Setup

- Navigate to **Applications** > **Applications** and create a **_New Application_**:
- Fill out the details:

|     Field      | Setting                          |
| :------------: | :------------------------------- |
|    **Name**    | `Nextcloud`                      |
|  **Provider**  | Select `Nextcloud - OIDC`        |
| **Launch URL** | `https://nextcloud.khangvum.com` |

## 2. Nextcloud Configuration

### App Installation

- Log in to your Nextcloud instance as an **_Administrator_**.
- Navigate to **Apps**, search for the **_OpenID Connect user backend_** (`user_oidc`), and click **_Download and install_**.

### OIDC Settings

- Navigate to **Administration settings** > **OpenID Connect**.
- Under the **Registered Providers** section, click the **+** button and configure the provider settings:

|         Field          | Value                                                                                     |
| :--------------------: | :---------------------------------------------------------------------------------------- |
|     **Identifier**     | `authentik`                                                                               |
|     **Client ID**      | (Paste the **_Client ID_** from Authentik)                                                |
|   **Client secret**    | (Paste the **_Client Secret_** from Authentik)                                            |
| **Discovery endpoint** | `https://authentik.khangvum.com/application/o/nextcloud/.well-known/openid-configuration` |
|       **Scope**        | `email profile openid nextcloud`                                                          |

### Attribute Mapping

Configure the mapping fields under the OpenID Connect settings panel:

|          Field           | Value       |
| :----------------------: | :---------- |
|   **User ID mapping**    | `user_id`   |
|    **Quota mapping**     | `quota`     |
|    **Groups mapping**    | `groups`    |
| **Display name mapping** | `name`      |
|    **Email mapping**     | `email`     |
|  **Use unique user ID**  | `UNCHECKED` |

> [!IMPORTANT]
> Ensure **Use unique user ID** option is **_unchecked_** so that Nextcloud **_matches incoming usernames_** directly to the **_existing account names_**.

## 3. Fallback & Local Server Access

### Direct Login Fallback

If an **_OIDC_** configuration issue **_locks you out_**, **_bypass SSO_** by navigating to your direct login endpoint: https://nextcloud.khangvum.com/login?direct=1

### References

[Integrate with Nextcloud](https://integrations.goauthentik.io/chat-communication-collaboration/nextcloud/)
