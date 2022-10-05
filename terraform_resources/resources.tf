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

# Assign the role to the user
resource "azurerm_role_assignment" "builder" {
  scope                = data.azurerm_subscription.sb.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_user.user.object_id
}

# Create the keyvault
module "keyvault" {
  source           = "../../az-terraform-module/keyvault"
  location         = azurerm_resource_group.rg_sb.location
  rg_name          = azurerm_resource_group.rg_sb.name
  principal_id     = data.azuread_user.user.object_id
  project_name     = var.project_name
}

# Generate a password
resource "random_password" "password" {
  length           = 16
  special          = true
}

# Create a secret for the VM
resource "azurerm_key_vault_secret" "vm_password" {
  name          = "vm-password"
  value         = random_password.password
  key_vault_id  = module.keyvault.keyvault_id
}

# Create a vnet
module "vnet" {
  source           = "../../az-terraform-module/vnet"
  location         = azurerm_resource_group.rg_sb.location
  rg_name          = azurerm_resource_group.rg_sb.name
  project_name     = var.project_name
}

# Create a vm-linux
module "vm_linux" {
  source           = "../../az-terraform-module/vm-linux"
  count            = contains(var.modules_list, "vm-linux") ? 1 : 0
  location         = azurerm_resource_group.rg_sb.location
  rg_name          = azurerm_resource_group.rg_sb.name
  subnet_id        = module.vnet.subnet_data_id
  project_name     = var.project_name
  vm_password      = random_password.password
}