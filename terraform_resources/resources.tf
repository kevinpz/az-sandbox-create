# Create the RG
resource "azurerm_resource_group" "rg_sb" {
  name     = "rg-sb-${var.project_name}"
  location = var.location
}

# Get the user information from Azure AD
data "azuread_user" "user" {
  user_principal_name = var.owner_name
}

# Get the current subscription
data "azurerm_subscription" "sb" {}

# Get the current config
data "azurerm_client_config" "current" {}

# Assign the role to the user
resource "azurerm_role_assignment" "builder" {
  scope                = data.azurerm_subscription.sb.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_user.user.object_id
}

# Create a keyvault
resource "azurerm_key_vault" "kv" {
  name                        = "kvkpz${var.project_name}"
  location                    = azurerm_resource_group.rg_sb.location
  resource_group_name         = azurerm_resource_group.rg_sb.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization   = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

# Give to the user the permissions on the keyvault
resource "azurerm_role_assignment" "ra-kv" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_user.user.object_id
}