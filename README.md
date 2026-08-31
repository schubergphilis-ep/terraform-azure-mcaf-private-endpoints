<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.this_unmanaged_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_link_service.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_link_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location/region where the virtual network private endpoint is created. | `string` | `null` | no |
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | This object describes the private endpoint configuration.<br/><br/>- `name` - (Optional) Specifies the Name of the Private Endpoint.<br/>- `location` - (Optional) The supported Azure location where the resource exists.<br/>- `resource_group_name` - (Optional) The resource group name.<br/>- `custom_network_interface_name` - (Optional) The custom name of the network interface attached to the private endpoint. Defaults to the private endpoint name with '\_nic'.<br/>- `ip_configuration`- (Optional) This allows a static IP address to be set for this Private Endpoint, otherwise an address is dynamically allocated from the Subnet.<br/>  - `name` - (Optional)<br/>  - `member_name` - (Optional)<br/>  - `private_ip_address` - (Optional) -<br/>  - `subresource_name` - (Optional)<br/>- `is_manual_connection` - (Optional) Does the Private Endpoint require Manual Approval from the remote resource owner? Use together with request\_message.<br/>- `private_connection_resource_alias` - (Optional) The Service Alias of the Private Link Enabled Remote Resource which this Private Endpoint should be connected to. One of private\_connection\_resource\_id or private\_connection\_resource\_alias must be specified.<br/>- `private_connection_resource_id` - (Required) The ID of the Private Link Enabled Remote Resource which this Private Endpoint should be connected to. One of private\_connection\_resource\_id or private\_connection\_resource\_alias must be specified.<br/>- `private_dns_zone_group_name` - (Optional) Specifies the Name of the Private DNS Zone Group.<br/>- `private_dns_zone_ids` - (Optional) Specifies the list of Private DNS Zones to include.<br/>- `private_service_connection_name` - (Optional) Specifies the Name of the Private Service Connection.<br/>- `private_endpoints_manage_dns_zone_group` - (Optional) Should the Private Endpoint manage the DNS Zone Group, or manage it through azure policy for example, defaults to true.<br/>- `request_message` - (Optional) A message passed to the owner of the remote resource when the private endpoint attempts to establish the connection to the remote resource.<br/>- `subnet_id` - (Required) The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint.<br/>- `subresource_name` - (Optional) A subresource name which the Private Endpoint is able to connect to, e.g. 'vault' for key vault or 'blob' for storage account. Required when not using a custom Private Link service.<br/>- `subresource_names` - (Optional) A list of subresource names, for targets that expose more than one on a single endpoint. Mutually exclusive with `subresource_name`. The first entry is used when deriving the default endpoint and NIC names.<br/>- `tags` - (Optional) A mapping of tags to assign to the resource.<br/><br/>  Example Inputs:<pre>hcl<br/>  private_endpoints = {<br/>    "blob-private-endpoint" = {<br/>      private_connection_resource_id = azurerm_storage_account.storage_account.id<br/>      subnet_id                      = azurerm_subnet.app-subnet.id<br/>      subresource_name               = "blob"<br/>      private_endpoints_manage_dns_zone_group = false<br/>    }<br/>  }</pre>hcl | <pre>map(object({<br/>    name                          = optional(string)<br/>    location                      = optional(string)<br/>    resource_group_name           = optional(string)<br/>    custom_network_interface_name = optional(string)<br/>    ip_configuration = optional(list(object({<br/>      name               = optional(string)<br/>      member_name        = optional(string)<br/>      private_ip_address = optional(string)<br/>      subresource_name   = optional(string)<br/>    })), [])<br/>    is_manual_connection                    = optional(bool)<br/>    private_connection_resource_alias       = optional(string)<br/>    private_connection_resource_id          = optional(string)<br/>    private_dns_zone_group_name             = optional(string, "default")<br/>    private_dns_zone_resource_ids           = optional(list(string), [])<br/>    private_service_connection_name         = optional(string)<br/>    private_endpoints_manage_dns_zone_group = optional(bool, true)<br/>    request_message                         = optional(string)<br/>    subnet_id                               = string<br/>    subresource_name                        = optional(string)<br/>    subresource_names                       = optional(list(string))<br/>    tags                                    = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_private_link_services"></a> [private\_link\_services](#input\_private\_link\_services) | This object describes the private link configuration.<br/><br/>- `name` - (Optional) Specifies the name of this Private Link Service.<br/>- `location` - (Optional) The supported Azure location where the resource exists.<br/>- `resource_group_name` - (Optional) The resource group name.<br/>- `auto_approval_subscription_ids` - (Optional) A list of Subscription UUID/GUID's that will be automatically be able to use this Private Link Service.<br/>- `enable_proxy_protocol` - (Optional) Should the Private Link Service support the Proxy Protocol?<br/>- `fqdns` - (Optional) List of FQDNs allowed for the Private Link Service.<br/>- `load_balancer_frontend_ip_configuration_ids` - (Required) A list of Frontend IP Configuration IDs from a Standard Load Balancer, where traffic from the Private Link Service should be routed.<br/>- `nat_ip_configuration` - (Required)<br/>  - `name` - (Optional) Specifies the name which should be used for the NAT IP Configuration.<br/>  - `primary` - (Optional) Is this is the Primary IP Configuration?<br/>  - `private_ip_address` - (Optional) Specifies a Private Static IP Address for this IP Configuration.<br/>  - `private_ip_address_version` - (Optional) - The version of the IP Protocol which should be used.<br/>  - `subnet_id` - (Required) - Specifies the ID of the Subnet which should be used for the Private Link Service.<br/>- `visibility_subscription_ids` - (Optional)<br/>- `tags` - (Optional) A list of zones where this public IP should be deployed. Defaults to no zone. if you prefer, you can set other values for the zones ["1","2","3"]. Changing this forces a new resource to be created.<br/><br/>  Example Inputs:<pre>hcl<br/>  private_link_services = {<br/>    lb-private-link = {<br/>      load_balancer_frontend_ip_configuration_ids = [azurerm_lb.locabalancer.frontend_ip_configuration[0].id]<br/>      nat_ip_configuration = [{<br/>        subnet_id = azurerm_subnet.app-subnet.id<br/>      }]<br/>    }<br/>  }</pre>hcl | <pre>map(object({<br/>    name                                        = optional(string)<br/>    location                                    = optional(string)<br/>    resource_group_name                         = optional(string)<br/>    auto_approval_subscription_ids              = optional(list(string), [])<br/>    enable_proxy_protocol                       = optional(bool)<br/>    fqdns                                       = optional(list(string), [])<br/>    load_balancer_frontend_ip_configuration_ids = list(string)<br/>    nat_ip_configuration = list(object({<br/>      name                       = optional(string)<br/>      primary                    = optional(bool)<br/>      private_ip_address         = optional(string)<br/>      private_ip_address_version = optional(string)<br/>      subnet_id                  = string<br/>    }))<br/>    tags                        = optional(map(string))<br/>    visibility_subscription_ids = optional(set(string), [])<br/><br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group to deploy the resources in, can be overridden on a per resource level | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints) | A map of private endpoint names to their corresponding names and IDs |
<!-- END_TF_DOCS -->

## License

**Copyright:** Schuberg Philis

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
