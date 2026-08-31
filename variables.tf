variable "location" {
  description = "The location/region where the virtual network private endpoint is created."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "The resource group to deploy the resources in, can be overridden on a per resource level"
  type        = string
  default     = null
}

variable "private_endpoints" {
  type = map(object({
    name                          = optional(string)
    location                      = optional(string)
    resource_group_name           = optional(string)
    custom_network_interface_name = optional(string)
    ip_configuration = optional(list(object({
      name               = optional(string)
      member_name        = optional(string)
      private_ip_address = optional(string)
      subresource_name   = optional(string)
    })), [])
    is_manual_connection                    = optional(bool)
    private_connection_resource_alias       = optional(string)
    private_connection_resource_id          = optional(string)
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(list(string), [])
    private_service_connection_name         = optional(string)
    private_endpoints_manage_dns_zone_group = optional(bool, true)
    request_message                         = optional(string)
    subnet_id                               = string
    subresource_name                        = optional(string)
    subresource_names                       = optional(list(string))
    tags                                    = optional(map(string))
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
This object describes the private endpoint configuration.

- `name` - (Optional) Specifies the Name of the Private Endpoint.
- `location` - (Optional) The supported Azure location where the resource exists.
- `resource_group_name` - (Optional) The resource group name.
- `custom_network_interface_name` - (Optional) The custom name of the network interface attached to the private endpoint. Defaults to the private endpoint name with '_nic'.
- `ip_configuration`- (Optional) This allows a static IP address to be set for this Private Endpoint, otherwise an address is dynamically allocated from the Subnet.
  - `name` - (Optional)
  - `member_name` - (Optional)
  - `private_ip_address` - (Optional) -
  - `subresource_name` - (Optional)
- `is_manual_connection` - (Optional) Does the Private Endpoint require Manual Approval from the remote resource owner? Use together with request_message.
- `private_connection_resource_alias` - (Optional) The Service Alias of the Private Link Enabled Remote Resource which this Private Endpoint should be connected to. One of private_connection_resource_id or private_connection_resource_alias must be specified.
- `private_connection_resource_id` - (Required) The ID of the Private Link Enabled Remote Resource which this Private Endpoint should be connected to. One of private_connection_resource_id or private_connection_resource_alias must be specified.
- `private_dns_zone_group_name` - (Optional) Specifies the Name of the Private DNS Zone Group.
- `private_dns_zone_ids` - (Optional) Specifies the list of Private DNS Zones to include.
- `private_service_connection_name` - (Optional) Specifies the Name of the Private Service Connection.
- `private_endpoints_manage_dns_zone_group` - (Optional) Should the Private Endpoint manage the DNS Zone Group, or manage it through azure policy for example, defaults to true.
- `request_message` - (Optional) A message passed to the owner of the remote resource when the private endpoint attempts to establish the connection to the remote resource.
- `subnet_id` - (Required) The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint.
- `subresource_name` - (Optional) A subresource name which the Private Endpoint is able to connect to, e.g. 'vault' for key vault or 'blob' for storage account. Required when not using a custom Private Link service.
- `subresource_names` - (Optional) A list of subresource names, for targets that expose more than one on a single endpoint. Mutually exclusive with `subresource_name`. The first entry is used when deriving the default endpoint and NIC names.
- `tags` - (Optional) A mapping of tags to assign to the resource.

  Example Inputs:

  ```hcl
  private_endpoints = {
    "blob-private-endpoint" = {
      private_connection_resource_id = azurerm_storage_account.storage_account.id
      subnet_id                      = azurerm_subnet.app-subnet.id
      subresource_name               = "blob"
      private_endpoints_manage_dns_zone_group = false
    }
  }
  ```hcl
DESCRIPTION
}

variable "private_link_services" {
  type = map(object({
    name                                        = optional(string)
    location                                    = optional(string)
    resource_group_name                         = optional(string)
    auto_approval_subscription_ids              = optional(list(string), [])
    enable_proxy_protocol                       = optional(bool)
    fqdns                                       = optional(list(string), [])
    load_balancer_frontend_ip_configuration_ids = list(string)
    nat_ip_configuration = list(object({
      name                       = optional(string)
      primary                    = optional(bool)
      private_ip_address         = optional(string)
      private_ip_address_version = optional(string)
      subnet_id                  = string
    }))
    tags                        = optional(map(string))
    visibility_subscription_ids = optional(set(string), [])

  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
This object describes the private link configuration.

- `name` - (Optional) Specifies the name of this Private Link Service.
- `location` - (Optional) The supported Azure location where the resource exists.
- `resource_group_name` - (Optional) The resource group name.
- `auto_approval_subscription_ids` - (Optional) A list of Subscription UUID/GUID's that will be automatically be able to use this Private Link Service.
- `enable_proxy_protocol` - (Optional) Should the Private Link Service support the Proxy Protocol?
- `fqdns` - (Optional) List of FQDNs allowed for the Private Link Service.
- `load_balancer_frontend_ip_configuration_ids` - (Required) A list of Frontend IP Configuration IDs from a Standard Load Balancer, where traffic from the Private Link Service should be routed.
- `nat_ip_configuration` - (Required)
  - `name` - (Optional) Specifies the name which should be used for the NAT IP Configuration.
  - `primary` - (Optional) Is this is the Primary IP Configuration?
  - `private_ip_address` - (Optional) Specifies a Private Static IP Address for this IP Configuration.
  - `private_ip_address_version` - (Optional) - The version of the IP Protocol which should be used.
  - `subnet_id` - (Required) - Specifies the ID of the Subnet which should be used for the Private Link Service.
- `visibility_subscription_ids` - (Optional)
- `tags` - (Optional) A list of zones where this public IP should be deployed. Defaults to no zone. if you prefer, you can set other values for the zones ["1","2","3"]. Changing this forces a new resource to be created.

  Example Inputs:

  ```hcl
  private_link_services = {
    lb-private-link = {
      load_balancer_frontend_ip_configuration_ids = [azurerm_lb.locabalancer.frontend_ip_configuration[0].id]
      nat_ip_configuration = [{
        subnet_id = azurerm_subnet.app-subnet.id
      }]
    }
  }
  ```hcl
DESCRIPTION
}
