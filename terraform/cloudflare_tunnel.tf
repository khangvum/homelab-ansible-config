resource "cloudflare_zero_trust_tunnel_cloudflared" "homelab_tunnel" {
  account_id = var.cloudflare_account_id
  name       = var.tunnel_name
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "homelab_ingress" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id

  config = {
    ingress = concat(
      [
        for service in var.services : {
          hostname = "${service.subdomain}.${var.domain}"
          service  = "${service.scheme}://${service.ip}:${service.port}"
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