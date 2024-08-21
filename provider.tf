# Azure Provider configuration
provider "azurerm" {
  features {}
}

provider "azuread" {
  # Optional if azurerm provider manages Azure AD, else required.
}