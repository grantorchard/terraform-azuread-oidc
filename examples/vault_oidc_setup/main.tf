provider "vault" {}

## Import OIDC module
module "azuread_oidc" {
	source = "github.com/grantorchard/terraform-azure-oidc.git"

	redirect_uris = [
    "http://localhost:8250/oidc/callback",
    "https://localhost:8200/ui/vault/auth/oidc/oidc/callback"
  ]
	group_membership_claim = "All"
}


## Create JWT auth backed, and a default role
resource "vault_jwt_auth_backend" "this" {
  type               = "oidc"
  path               = "oidc"
  oidc_discovery_url = module.azuread_oidc.oidc_discovery_url
  oidc_client_id     = module.azuread_oidc.application_client_id
  oidc_client_secret = module.azuread_oidc.azuread_application_password
  default_role       = "default"
}

resource "vault_jwt_auth_backend_role" "this" {
  backend        = vault_jwt_auth_backend.this.path
  role_name      = "default"
  token_policies = [
    "default"
  ]
  user_claim   = "email"
  role_type    = "oidc"
	groups_claim = "groups"
	verbose_oidc_logging = true

	allowed_redirect_uris = [
    "http://localhost:8250/oidc/callback",
    "https://localhost:8200/ui/vault/auth/oidc/oidc/callback"
  ]
}