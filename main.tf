# -----------------------------------------------------------------------------
# Lab 04: Infrastructure as Code with Terraform on Azure
# Builds: Resource Group -> Virtual Network -> Subnet, plus a Network Security Group
# -----------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # any 3.x release, below 4.0
    }
  }
}

provider "azurerm" {
  features {}

  # Skip bulk registration of every Azure resource provider on first run.
  # Without this, `terraform plan` can hang on student or restricted subscriptions.
  # Register Microsoft.Network once yourself instead (see README, step 3).
  skip_provider_registration = true
}

# Every Azure resource lives inside a resource group.
# CHANGE "anwar" to your own first name: resource group names must be unique in your subscription.
resource "azurerm_resource_group" "rg" {
  name     = "rg-lab04-tf-anwar"
  location = "East US 2" # must be a region your subscription's policy allows
}

# The VNet references the resource group, so Terraform creates the group first.
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-terraform"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# 10.0.1.0/24 is one slice of the 10.0.0.0/16 VNet address space.
resource "azurerm_subnet" "subnet" {
  name                 = "snet-backend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Added in Phase 5 to show an incremental change to a live environment.
# Empty NSG: no rules, and not yet associated with the subnet.
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
