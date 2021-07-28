variable azuread_application_password_length {
  type        = number
  default     = 128
  description = "Length of the password to be created for the Service Principal. Must be between 8 and 256 characters."
  validation {
    condition     = var.azuread_application_password_length >= 8 && var.azuread_application_password_length <= 256
    error_message = "The password length must be between 8 and 256 characters."
  }
}

variable azuread_application_password_special_chars {
  type        = bool
  default     = true
  description = "Whether to use special characters in the Service Principal password."
}

variable azuread_application_display_name {
  type        = string
  default     = ""
  description = "The name of the Service Principal/Enterprise Application that will be created in Azure Active Directory."
}

variable reset_azuread_application_password {
  type    = bool
  default = false
}

variable groups_claim {
  type        = string
  description = ""
  default     = "roles"
}

variable user_type {
  type        = string
  description = "The attribute of the JWT to use for user."
  default     = "email"
}

variable reply_urls {
	type = list
	description = "The URL to redirect the user back to after authentication succeeds."
	default = []
}

variable app_resource_permission {
	type = string
	description = "The permissions required by this application. 'GroupMember.Read.All' is used by Vault and Terraform Cloud to understand the group membership of the user signing in."
	default = "GroupMember.Read.All"
}