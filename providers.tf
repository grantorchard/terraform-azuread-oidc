terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.6.0"
    }
  }
	experiments = [module_variable_optional_attrs]
}