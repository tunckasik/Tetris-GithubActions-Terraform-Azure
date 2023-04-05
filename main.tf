terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.50.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "github" {
}


terraform {
  backend "azurerm" {
    resource_group_name  = "tf-state-rg"
    storage_account_name = "tfstatecontainerfxfx3223"
    container_name       = "tetris-githubaction-backend"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "rg1" {
  name     = "test1"
  location = "East US"
}

resource "azurerm_container_registry" "acr" {
  name                = "bronze"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_service_plan" "app_plan" {
  name                = "bronze"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "linux_web_app" {
  name                = "bronze"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_service_plan.app_plan.location
  service_plan_id     = azurerm_service_plan.app_plan.id
  site_config {}
}

# GithubAction
resource "github_actions_secret" "github_action_secret" {
  repository      = "tetris-github_action"
  secret_name     = "ACR_PASSWORD"
  plaintext_value = azurerm_container_registry.acr.admin_password
  depends_on = [
    azurerm_container_registry.acr
  ]
}

output "acr_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}