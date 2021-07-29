output "managed_group_command" {
	value = "boundary managed-groups create oidc -name \"boundary_admins\" -auth-method-id ${boundary_auth_method_oidc.this.id} -filter='\"${data.azuread_group.boundary_admins.id}\" in \"userinfo/groups\"'"
}