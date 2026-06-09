# Grafana-Authentik Integration Guide

A comprehensive guide to **_integrating Authentik OIDC_** with a **_Grafana_** instance in a homelab environment.

## 1. Authentik Configuration

### Provider Setup

- Navigate to **Applications** > **Providers** and create an **_OAuth2/OpenID Provider_**.
- Fill out the details:

  |           Field           | Setting                                                                   |
  | :-----------------------: | ------------------------------------------------------------------------- |
  |         **Name**          | `Grafana - OIDC`                                                          |
  |  **Authorization Flow**   | `default-provider-authorization-explicit-consent (Authorize Application)` |
  |      **Client Type**      | `Confidential`                                                            |
  | **Redirect URIs/Origins** | `http://grafana.khangvum.lab/login/generic_oauth`                         |

> [!IMPORTANT]
> Copy your **_Client ID_** and **_Client Secret_**, which are needed for Grafana environment variables later.

### Application Setup

- Navigate to **Applications** > **Applications** and create a **_New Application_**:
- Fill out the details:

  |     Field      | Setting                       |
  | :------------: | ----------------------------- |
  |    **Name**    | `Grafana`                     |
  |  **Provider**  | Select `Grafana - OIDC`       |
  | **Launch URL** | `http://grafana.khangvum.lab` |

## 2. Grafana Configuration

Grafana is configured via **_environment variables_** in the `docker-compose.yml` file. Add the following to the Grafana container definition:

```yaml
---
services:
  grafana:
    ...
    environment:
      # General OAuth Settings
      GF_AUTH_GENERIC_OAUTH_ENABLED: "true"
      GF_AUTH_GENERIC_OAUTH_NAME: "authentik"

      # Automatically create users in Grafana when they log in via Authentik
      GF_AUTH_GENERIC_OAUTH_AUTO_SIGNUP: "true"
      GF_AUTH_GENERIC_OAUTH_EMAIL_ATTRIBUTE_NAME: "email"
      GF_AUTH_GENERIC_OAUTH_LOGIN_ATTRIBUTE_PATH: "preferred_username"
      GF_AUTH_GENERIC_OAUTH_CLIENT_ID: "<CLIENT_ID>"
      GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET: "<CLIENT_SECRET>"

      # 'groups' scope is required for role mapping
      GF_AUTH_GENERIC_OAUTH_SCOPES: "openid profile email groups"
      
      # Authentik OIDC Endpoints
      GF_AUTH_GENERIC_OAUTH_AUTH_URL: "http://authentik.khangvum.lab/application/o/authorize/"
      GF_AUTH_GENERIC_OAUTH_TOKEN_URL: "http://authentik.khangvum.lab/application/o/token/"
      GF_AUTH_GENERIC_OAUTH_API_URL: "http://authentik.khangvum.lab/application/o/userinfo/"
      
      # Logout configuration
      GF_AUTH_SIGNOUT_REDIRECT_URL: "http://authentik.khangvum.lab/application/o/grafana/end-session/"
      
      # Optional: Auto-login (Bypasses Grafana login screen and sends user straight to Authentik)
      GF_AUTH_OAUTH_AUTO_LOGIN: "false"
      
      # Required for reverse proxy (NPM)
      GF_SERVER_ROOT_URL: "http://grafana.khangvum.lab"
    ...
```

## References

[Integrate with Grafana](https://integrations.goauthentik.io/monitoring/grafana/)