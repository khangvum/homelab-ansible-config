# Create CNAME records for each service to point to the Cloudflare Tunnel
# Reference: https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record
resource "cloudflare_dns_record" "tunnel_cnames" {
  # Convert list of objects into a map keyed by subdomain
  for_each = { for service in var.services : service.subdomain => service }

  zone_id = var.cloudflare_zone_id
  name    = each.value.subdomain
  content = "${cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true # Required for Zero Trust Access policies to enforce
  ttl     = 1    # Automatic TTL when proxied
}