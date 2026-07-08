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

module "key_vault" {
  source  = "schubergphilis-ep/mcaf-key-vault/azure"
  version = "0.1.0"

  key_vault = {
    name                = "keyvault"
    tenant_id           = "00000000-0000-0000-0000-000000000000"
    resource_group_name = local.resource_group_name
    location            = local.location
    purge_protection    = false
  }

  tags = {
    "Resource Type" = "Key vault"
  }
}

module "network" {
  source  = "schubergphilis-ep/mcaf-network/azure"
  version = "0.1.0"
  resource_group = {
    name     = local.resource_group_name
    location = local.location
  }

  vnet_name          = "vnet"
  vnet_address_space = ["10.0.0.0/8"]

  subnets = local.subnets

  private_dns = {
    "key_vault" = {
      zone_name = "privatelink.vaultcore.azure.net"
    },
    "storage_blob" = {
      zone_name = "privatelink.blob.core.windows.net"
    }
  }
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
  source  = "schubergphilis-ep/mcaf-private-endpoints/azure"
  version = "0.2.0"

  resource_group_name = local.resource_group_name
  location            = local.location

  private_endpoints = {
    # Private endpoint example to a storage account blob using a static IP and private DNS.
    "blob-private-endpoint" = {
      private_dns_zone_ids           = [module.network.private_dns_zone_list["privatelink.blob.core.windows.net"].id]
      private_connection_resource_id = azurerm_storage_account.storage_account.id
      subnet_id                      = module.network.subnet_list.app-subnet.id
      subresource_name               = "blob"
      ip_configuration = [
        {
          private_ip_address = "10.0.2.39"
        }
      ]
    }
    # Private endpoint example to a key vault using a dynamic IP and private DNS.
    "keyvault-endpoint" = {
      private_dns_zone_ids           = [module.network.private_dns_zone_list["privatelink.vaultcore.azure.net"].id]
      private_connection_resource_id = module.key_vault.key_vault_id
      subnet_id                      = module.network.subnet_list.app-subnet.id
      subresource_name               = "vault"
    }

    # Private endpoint example to a private link service using a dynamic IP.
    "private-link-endpoint" = {
      private_connection_resource_id = "/subscriptions/b5f5e722-d325-4261-98e1-81d2d707bd86/resourceGroups/sdevriest/providers/Microsoft.Network/privateLinkServices/apgp01-murx-weu-murx-lb_pls"
      subnet_id                      = module.network.subnet_list.app-subnet.id
    }
  }

  private_link_services = {
    # Private link example with a dynamic IP using a load balancer
    private-link = {
      load_balancer_frontend_ip_configuration_ids = [azurerm_lb.loadbalancer.frontend_ip_configuration[0].id]
      nat_ip_configuration = [{
        subnet_id = module.network.subnet_list.app-subnet.id
      }]
    }
  }
}
