provider "boundary" {
  addr             = "http://127.0.0.1:9200"
  recovery_kms_hcl = <<EOT
kms "aead" {
  purpose = "recovery"
  aead_type = "aes-gcm"
  key = "nFfS3zkhfgf5iDMGiTO/U+5/Ux/ubdUlFpYO6LtwPvs="
  key_id = "global_recovery"
}
EOT
}

locals {
	org_scope_id = "o_1234567890"
	project_scope_id = "p_1234567890"
}


module "azuread_oidc" {
	source = "github.com/grantorchard/terraform-azure-oidc.git"

	reply_uris = [
    "http://localhost:9200/v1/auth-methods/oidc:authenticate:callback"
  ]
	app_resource_permissions = [
		"GroupMember.Read.All", 
		"User.Read.All"
	]
	group_membership_claim = "All"
}

data "azuread_group" "boundary_admins" {
	display_name = "Boundary Admins"
}

resource "boundary_role" "scope_admin" {
  scope_id       = "global"
  grant_scope_id = "global"
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = []
}

resource "boundary_auth_method_oidc" "this" {
  name                = "azuread_oidc"
  scope_id            = "global"
	state               = "active-public"
	is_primary_for_scope = true
	callback_url        = "http://localhost:9200/v1/auth-methods/oidc:authenticate:callback"
  issuer              = "https://sts.windows.net/${module.azuread_oidc.azuread_tenant_id}/"
  client_id           = module.azuread_oidc.application_client_id
  client_secret       = module.azuread_oidc.azuread_application_password
  signing_algorithms  = [ "RS256" ]
  api_url_prefix      = "http://localhost:9200"
	account_claim_maps  = []
	claims_scopes       = []
}