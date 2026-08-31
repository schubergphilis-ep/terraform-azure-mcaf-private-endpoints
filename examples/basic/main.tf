terraform {
  required_version = ">= 1.7"

  backend "local" {
    path = "./terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4"
    }
  }
}

locals {
  resource_group_name = "rg-private-endpoints"
  location            = "Sweden Central"
  subnets = {
    "app-subnet" = {
      address_prefixes                              = ["10.0.1.0/24"]
      private_link_service_network_policies_enabled = false
    }
  }
}
resource "azurerm_storage_account" "storage_account" {
  name                     = "storageaccount"
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# A plain resource rather than mcaf-key-vault: this example only needs something to point a
# private endpoint at, and depending on another module couples this repository's CI to that
# module's release cycle -- which is what broke it here.
resource "azurerm_key_vault" "key_vault" {
  name                       = "keyvault"
  tenant_id                  = "00000000-0000-0000-0000-000000000000"
  resource_group_name        = local.resource_group_name
  location                   = local.location
  sku_name                   = "standard"
  purge_protection_enabled   = false
  rbac_authorization_enabled = true

  tags = {
    "Resource Type" = "Key vault"
  }
}

# Plain resources rather than mcaf-network. An example for THIS module should exercise this
# module, not couple the repository's CI to another module's API and release cycle -- which is
# exactly what broke it: the pinned mcaf-network and mcaf-key-vault versions predate azurerm v5.
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/8"]
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = local.subnets["app-subnet"].address_prefixes

  private_link_service_network_policies_enabled = local.subnets["app-subnet"].private_link_service_network_policies_enabled
}

resource "azurerm_private_dns_zone" "this" {
  for_each = toset(["privatelink.vaultcore.azure.net", "privatelink.blob.core.windows.net"])

  name                = each.key
  resource_group_name = local.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = azurerm_private_dns_zone.this

  name                = "${each.value.name}-link"
  private_dns_zone_id = each.value.id
  virtual_network_id  = azurerm_virtual_network.vnet.id
}

resource "azurerm_public_ip" "loadbalancer" {
  name                = "loadbalancer-pip"
  sku                 = "Standard"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "loadbalancer" {
  name                = "loadbalancer"
  sku                 = "Standard"
  location            = local.location
  resource_group_name = local.resource_group_name

  frontend_ip_configuration {
    name                 = "loadbalancer-frontend"
    public_ip_address_id = azurerm_public_ip.loadbalancer.id
  }
}

module "private_endpoints" {
  source = "../.."

  resource_group_name = local.resource_group_name
  location            = local.location

  private_endpoints = {
    # Private endpoint example to a storage account blob using a static IP and private DNS.
    "blob-private-endpoint" = {
      private_dns_zone_ids           = [azurerm_private_dns_zone.this["privatelink.blob.core.windows.net"].id]
      private_connection_resource_id = azurerm_storage_account.storage_account.id
      subnet_id                      = azurerm_subnet.app.id
      subresource_name               = "blob"
      ip_configuration = [
        {
          private_ip_address = "10.0.2.39"
        }
      ]
    }
    # Private endpoint example to a key vault using a dynamic IP and private DNS.
    "keyvault-endpoint" = {
      private_dns_zone_ids           = [azurerm_private_dns_zone.this["privatelink.vaultcore.azure.net"].id]
      private_connection_resource_id = azurerm_key_vault.key_vault.id
      subnet_id                      = azurerm_subnet.app.id
      subresource_name               = "vault"
    }

    # Private endpoint example to a private link service using a dynamic IP.
    "private-link-endpoint" = {
      private_connection_resource_id = "/subscriptions/b5f5e722-d325-4261-98e1-81d2d707bd86/resourceGroups/sdevriest/providers/Microsoft.Network/privateLinkServices/apgp01-murx-weu-murx-lb_pls"
      subnet_id                      = azurerm_subnet.app.id
    }
  }

  private_link_services = {
    # Private link example with a dynamic IP using a load balancer
    private-link = {
      load_balancer_frontend_ip_configuration_ids = [azurerm_lb.loadbalancer.frontend_ip_configuration[0].id]
      nat_ip_configuration = [{
        subnet_id = azurerm_subnet.app.id
      }]
    }
  }
}
