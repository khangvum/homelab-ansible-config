# Filter services where enable_access is true
locals {
  protected_services = { for svc in var.services : svc.subdomain => svc if svc.enable_access }
}

# Configure One-Time PIN (OTP) Identity Provider for Cloudflare Zero Trust Access
# Reference: https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zero_trust_access_identity_provider
resource "cloudflare_zero_trust_access_identity_provider" "otp" {
  account_id = var.cloudflare_account_id
  name       = "One-Time PIN"
  type       = "onetimepin"
  config     = {}
}

# Create Cloudflare Zero Trust Access Applications for each protected service
# Reference: https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zero_trust_access_application
resource "cloudflare_zero_trust_access_application" "apps" {
  for_each = local.protected_services

  zone_id          = var.cloudflare_zone_id
  name             = title(each.value.subdomain)
  domain           = "${each.value.subdomain}.${var.domain}"
  type             = "self_hosted"
  session_duration = "720h" # 30 days

  # Inline Access Policy block
  policies = [
    {
      name       = "Allow Personal Emails"
      precedence = 1
      decision   = "allow"

      include = [
        for email_addr in var.allowed_emails : {
          email = {
            email = email_addr
          }
        }
      ]
    }
  ]
}