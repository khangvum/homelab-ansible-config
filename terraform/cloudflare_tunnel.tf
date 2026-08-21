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
        for svc in var.services : {
          hostname = "${svc.subdomain}.${var.domain}"
          service  = "${svc.scheme}://${svc.ip}:${svc.port}"
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