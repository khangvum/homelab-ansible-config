# Create the Cloudflare Zero Trust Tunnel
# Reference: https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zero_trust_tunnel_cloudflared
resource "cloudflare_zero_trust_tunnel_cloudflared" "homelab_tunnel" {
  account_id = var.cloudflare_account_id
  name       = var.tunnel_name
  config_src = "cloudflare"
}

# Create the Cloudflare Zero Trust Tunnel configuration for ingress rules
# Reference: https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zero_trust_tunnel_cloudflared_config
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "homelab_ingress" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id

  config = {
    ingress = concat(
      [
        for service in var.services : {
          hostname = "${service.subdomain}.${var.domain}"
          service  = "${service.scheme}://${service.ip}:${service.port}"
          origin_request = service.scheme == "https" ? {
            no_tls_verify = true
          } : null
        }
      ],
      [
        {
          service = "http_status:404"
        }
      ]
    )
  }
}