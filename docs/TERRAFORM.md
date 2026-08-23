# Terraform Modules & Deployment

Terraform manages **_cloud networking_**, **_edge ingress rules_**, **_DNS routing_**, and **_Cloudflare Zero Trust Access policies_**.

## Modules

|                          Module                          | Description                                                                                                                                   |
| :------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------------- |
| [`cloudflare_access`](../terraform/cloudflare_access.tf) | Configures **_Cloudflare Zero Trust Access policies_**, **_application rules_**, and **_authentication requirements_** for secure edge access |
|    [`cloudflare_dns`](../terraform/cloudflare_dns.tf)    | Provisions **_DNS CNAME_** and **_A records_** to route traffic across homelab services and external endpoints                                |
| [`cloudflare_tunnel`](../terraform/cloudflare_tunnel.tf) | Creates and manages **_Cloudflared tunnels_** and **_ingress rules_** for secure, outbound-only network exposure                              |

## Configuration Setup

1.  **Initialize Working Directory:**

    ```bash
    terraform init
    ```

2.  **Validate Plan:**

    ```bash
    terraform plan
    ```

3.  **Apply Changes:**

    ```bash
    terraform apply
    ```
