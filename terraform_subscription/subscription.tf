# Get the EA account
data "azurerm_billing_enrollment_account_scope" "ea" {
    billing_account_name    = var.billing_account_name
    enrollment_account_name = var.enrollment_account_name
}

# Create the subscription
resource "azurerm_subscription" "sub" {
  subscription_name = "sb-${var.project_name}"
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.ea.id
     tags = {
         owner = var.owner_name
       }
}