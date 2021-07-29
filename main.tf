# Retrieve connection context so we can programmatically discover tenant_id later.
data "azuread_client_config" "this" {}

## Random naming function for the Enterprise App
resource "random_pet" "this" {
  length = 2
}

resource "random_integer" "this" {
  min = 10000
  max = 99999
}

# Password to connect to the Enterprise App. Set supported special characters per
# https://docs.microsoft.com/en-us/azure/active-directory/authentication/concept-sspr-policy#password-policies-that-only-apply-to-cloud-user-accounts
resource "random_password" "this" {
  length           = var.azuread_application_password_length
  special          = var.azuread_application_password_special_chars
  override_special = "@#$%^&*-_!+=[]{}|\\:',.?/`~\"(); "
}

## Create the AzureAD Enterprise App used by Vault
// Discover the Microsoft Graph service principal so we can pass it to our Enterprise Application.
data "azuread_service_principal" "this" {
  display_name = "Microsoft Graph"
}

resource "azuread_application" "this" {
  display_name = var.azuread_application_display_name != "" ? var.azuread_application_display_name : "${random_pet.this.id}-${random_integer.this.result}"

	group_membership_claims = var.group_membership_claim

	web {
		redirect_uris = var.reply_urls
	}
	# Assign GroupMember.Read.All permissions to the Microsoft Graph
	# per https://www.vaultproject.io/docs/auth/jwt_oidc_providers#azure-active-directory-aad
  required_resource_access {
    resource_app_id = data.azuread_service_principal.this.application_id
    dynamic "resource_access" {
			for_each = toset(var.app_resource_permissions)
			content {
				type = "Role"
				id   = [ for app_role in data.azuread_service_principal.this.app_roles : app_role.id if app_role.value == resource_access.value ][0]
			}
		}
  }
}

resource "azuread_application_password" "this" {
  application_object_id = azuread_application.this.id
  value                 = random_password.this.result
  end_date              = timeadd(timestamp(), "8766h")
	lifecycle {
		ignore_changes = [
			end_date
		]
	}
}
