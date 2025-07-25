output "private_endpoints" {
  description = "A map of private endpoint names to their corresponding names and IDs"
  value = merge(
    {
      for name, private_endpoint in azurerm_private_endpoint.this : name => {
        name = private_endpoint.name
        id   = private_endpoint.id
        ip   = private_endpoint.private_service_connection[0].private_ip_address
      }
    },
    {
      for name, private_endpoint in azurerm_private_endpoint.this_unmanaged_dns_zone_groups : name => {
        name = private_endpoint.name
        id   = private_endpoint.id
        ip   = private_endpoint.private_service_connection[0].private_ip_address
      }
    }
  )
}