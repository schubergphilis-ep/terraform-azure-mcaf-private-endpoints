resource "azurerm_private_endpoint" "this" {
  for_each = { for k, v in var.private_endpoints : k => v if v.private_endpoints_manage_dns_zone_group }

  name                          = each.value.name != null ? each.value.name : "${provider::azurerm::parse_resource_id(each.value.private_connection_resource_id)["resource_name"]}-${each.value.subresource_name}-pep"
  location                      = coalesce(each.value.location, var.location)
  resource_group_name           = coalesce(each.value.resource_group_name, var.resource_group_name)
  subnet_id                     = each.value.subnet_id
  custom_network_interface_name = each.value.custom_network_interface_name != null ? each.value.custom_network_interface_name : "${provider::azurerm::parse_resource_id(each.value.private_connection_resource_id)["resource_name"]}-${each.value.subresource_name}-nic"

  private_service_connection {
    name                              = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "${each.key}_psc"
    is_manual_connection              = each.value.is_manual_connection != null ? each.value.is_manual_connection : false
    private_connection_resource_alias = each.value.private_connection_resource_alias != null ? each.value.private_connection_resource_alias : null
    private_connection_resource_id    = each.value.private_connection_resource_id != null ? each.value.private_connection_resource_id : null
    request_message                   = each.value.request_message != null ? each.value.request_message : null
    subresource_names                 = each.value.subresource_name != null ? [each.value.subresource_name] : null
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_resource_ids) > 0 ? ["this"] : []

    content {
      name                 = each.value.private_dns_zone_group_name
      private_dns_zone_ids = each.value.private_dns_zone_resource_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration

    content {
      name               = ip_configuration.value.name != null ? ip_configuration.value.name : "${each.key}_ip"
      member_name        = ip_configuration.value.member_name != null ? ip_configuration.value.member_name : "default"
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = ip_configuration.value.subresource_name != null ? ip_configuration.value.subresource_name : each.value.subresource_name
    }
  }

  tags = merge(
    try(each.value.tags),
    tomap({
      "Resource Type" = "Private Endpoint"
    })
  )
}

resource "azurerm_private_endpoint" "this_unmanaged_dns_zone_groups" {
  for_each = { for k, v in var.private_endpoints : k => v if !v.private_endpoints_manage_dns_zone_group }

  name                          = each.value.name != null ? each.value.name : "${provider::azurerm::parse_resource_id(each.value.private_connection_resource_id)["resource_name"]}-${each.value.subresource_name}-pep"
  location                      = coalesce(each.value.location, var.location)
  resource_group_name           = coalesce(each.value.resource_group_name, var.resource_group_name)
  subnet_id                     = each.value.subnet_id
  custom_network_interface_name = each.value.custom_network_interface_name != null ? each.value.custom_network_interface_name : "${provider::azurerm::parse_resource_id(each.value.private_connection_resource_id)["resource_name"]}-${each.value.subresource_name}-nic"

  private_service_connection {
    name                              = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "${each.key}_psc"
    is_manual_connection              = each.value.is_manual_connection != null ? each.value.is_manual_connection : false
    private_connection_resource_alias = each.value.private_connection_resource_alias != null ? each.value.private_connection_resource_alias : null
    private_connection_resource_id    = each.value.private_connection_resource_id != null ? each.value.private_connection_resource_id : null
    request_message                   = each.value.request_message != null ? each.value.request_message : null
    subresource_names                 = each.value.subresource_name != null ? [each.value.subresource_name] : null
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration

    content {
      name               = ip_configuration.value.name != null ? ip_configuration.value.name : "${each.key}_ip"
      member_name        = ip_configuration.value.member_name != null ? ip_configuration.value.member_name : "default"
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = ip_configuration.value.subresource_name != null ? ip_configuration.value.subresource_name : each.value.subresource_name
    }
  }

  tags = merge(
    try(each.value.tags),
    tomap({
      "Resource Type" = "Private Endpoint"
    })
  )

  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}


resource "azurerm_private_link_service" "this" {
  for_each = var.private_link_services

  name                                        = each.value.name != null ? each.value.name : "${each.key}_pls"
  location                                    = each.value.location != null ? each.value.location : var.location
  resource_group_name                         = each.value.resource_group_name != null ? each.value.resource_group_name : var.resource_group_name
  auto_approval_subscription_ids              = each.value.auto_approval_subscription_ids != null ? each.value.auto_approval_subscription_ids : []
  proxy_protocol_enabled                      = each.value.enable_proxy_protocol != null ? each.value.enable_proxy_protocol : false
  fqdns                                       = each.value.fqdns != null ? each.value.fqdns : []
  load_balancer_frontend_ip_configuration_ids = each.value.load_balancer_frontend_ip_configuration_ids != null ? each.value.load_balancer_frontend_ip_configuration_ids : []
  visibility_subscription_ids                 = each.value.visibility_subscription_ids != null ? each.value.visibility_subscription_ids : []

  dynamic "nat_ip_configuration" {
    for_each = each.value.nat_ip_configuration
    content {
      name                       = nat_ip_configuration.value.name != null ? nat_ip_configuration.value.name : "${each.key}_nip"
      primary                    = nat_ip_configuration.value.primary != null ? nat_ip_configuration.value.primary : true
      private_ip_address         = nat_ip_configuration.value.private_ip_address != null ? nat_ip_configuration.value.private_ip_address : null
      private_ip_address_version = nat_ip_configuration.value.private_ip_address_version != null ? nat_ip_configuration.value.private_ip_address_version : "IPv4"
      subnet_id                  = nat_ip_configuration.value.subnet_id
    }
  }

  tags = merge(
    try(each.value.tags),
    tomap({
      "Resource Type" = "Private Link Service"
    })
  )
}
