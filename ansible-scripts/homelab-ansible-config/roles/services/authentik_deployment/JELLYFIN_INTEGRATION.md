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
  | **Redirect URIs/Origins** | `http://jellyfin.khangvum.lab/sso/OID/redirect/authentik`                 |

> [!IMPORTANT]
> Copy your **_Client ID_** and **_Client Secret_**, which are needed for Jellyfin plugin configuration later.

### Application Setup

- Navigate to **Applications** > **Applications** and create a **_New Application_**:
- Fill out the details:

  |     Field      | Setting                        |
  | :------------: | ------------------------------ |
  |    **Name**    | `Jellyfin`                     |
  |  **Provider**  | Select `Jellyfin - OIDC`       |
  | **Launch URL** | `http://jellyfin.khangvum.lab` |

