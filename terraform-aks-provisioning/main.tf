resource "random_id" "prefix" {
  byte_length = 8
}

resource "random_id" "name" {
  byte_length = 8
}

# Getting existing AKS admins group
# data "azuread_group" "msentra-aks-group" {
#   display_name     = var.msentra-aks-admins
#   security_enabled = true
# }

resource "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 1 : 0

  location = var.location
  # name     = coalesce(var.resource_group_name, "${random_id.prefix.hex}-rg")
  name = var.use-random-names ? coalesce(var.resource_group_name, "${random_id.prefix.hex}-rg") : var.aks-resources-names["aks-rg-name"]
}

locals {
  resource_group = {
    name     = var.create_resource_group ? azurerm_resource_group.main[0].name : var.resource_group_name
    location = var.location
  }

}

resource "azurerm_virtual_network" "aks-vnet" {
  count = var.bring_your_own_vnet ? 1 : 0

  address_space = [var.aks-vnet-address-space]
  location      = local.resource_group.location
  # name                = "${random_id.prefix.hex}-vn"
  name                = var.use-random-names ? "${random_id.prefix.hex}-vn" : var.aks-resources-names["aks-vnet-name"]
  resource_group_name = local.resource_group.name
}

resource "azurerm_subnet" "aks-subnet" {
  count = var.bring_your_own_vnet ? 1 : 0

  address_prefixes = [var.aks-subnet-address-prefix]
  # name                 = "${random_id.prefix.hex}-sn"
  name                 = var.use-random-names ? "${random_id.prefix.hex}-sn" : var.aks-resources-names["aks-subnet-name"]
  resource_group_name  = local.resource_group.name
  virtual_network_name = azurerm_virtual_network.aks-vnet[0].name
}

locals {
  appgw_cidr = !var.use_brown_field_application_gateway && !var.bring_your_own_vnet ? "10.225.0.0/16" : var.greenfield-appgw-cidr
}

resource "azurerm_subnet" "appgw" {
  count = var.use_brown_field_application_gateway && var.bring_your_own_vnet ? 1 : 0

  address_prefixes = [local.appgw_cidr]
  # name                 = "${random_id.prefix.hex}-gw"
  name                 = var.use-random-names ? "${random_id.prefix.hex}-gw" : var.aks-resources-names["brownfield-app-gw-name"]
  resource_group_name  = local.resource_group.name
  virtual_network_name = azurerm_virtual_network.aks-vnet[0].name
}

# Locals block for hardcoded names
locals {
  backend_address_pool_name      = try("${azurerm_virtual_network.aks-vnet[0].name}-beap", "")
  frontend_ip_configuration_name = try("${azurerm_virtual_network.aks-vnet[0].name}-feip", "")
  frontend_port_name             = try("${azurerm_virtual_network.aks-vnet[0].name}-feport", "")
  http_setting_name              = try("${azurerm_virtual_network.aks-vnet[0].name}-be-htst", "")
  listener_name                  = try("${azurerm_virtual_network.aks-vnet[0].name}-httplstn", "")
  request_routing_rule_name      = try("${azurerm_virtual_network.aks-vnet[0].name}-rqrt", "")
}

resource "azurerm_public_ip" "pip" {
  count = var.use_brown_field_application_gateway && var.bring_your_own_vnet ? 1 : 0

  allocation_method   = "Static"
  location            = local.resource_group.location
  name                = "appgw-pip"
  resource_group_name = local.resource_group.name
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  count = var.use_brown_field_application_gateway && var.bring_your_own_vnet ? 1 : 0

  location            = local.resource_group.location
  name                = var.appgw-name
  resource_group_name = local.resource_group.name

  backend_address_pool {
    name = local.backend_address_pool_name
  }
  backend_http_settings {
    cookie_based_affinity = "Disabled"
    name                  = local.http_setting_name
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip[0].id
  }
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.appgw[0].id
  }
  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    name                           = local.listener_name
    protocol                       = "Http"
  }
  request_routing_rule {
    http_listener_name         = local.listener_name
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  lifecycle {
    ignore_changes = [
      tags,
      backend_address_pool,
      backend_http_settings,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
    ]
  }
}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "9.1.0"

  cluster_name              = var.aks-resources-names["cluster-name"]
  prefix                    = random_id.name.hex
  resource_group_name       = local.resource_group.name
  kubernetes_version        = var.kubernetes-version
  automatic_channel_upgrade = "patch"
  agents_availability_zones = ["1", "2", "3"]
  agents_count              = null
  agents_max_count          = 5
  agents_max_pods           = 100
  agents_min_count          = 2
  agents_size               = var.agents_size
  agents_pool_name          = var.aks-resources-names["aks-nodepool-name"]
  agents_pool_linux_os_configs = [
    {
      transparent_huge_page_enabled = "always"
      sysctl_configs = [
        {
          fs_aio_max_nr               = 65536
          fs_file_max                 = 100000
          fs_inotify_max_user_watches = 1000000
        }
      ]
    }
  ]
  agents_type            = "VirtualMachineScaleSets"
  azure_policy_enabled   = true
  enable_auto_scaling    = true
  enable_host_encryption = true
  green_field_application_gateway_for_ingress = var.use_brown_field_application_gateway ? null : {
    name        = var.appgw-name
    subnet_cidr = local.appgw_cidr
  }
  brown_field_application_gateway_for_ingress = var.use_brown_field_application_gateway ? {
    id        = azurerm_application_gateway.appgw[0].id
    subnet_id = azurerm_subnet.appgw[0].id
  } : null
  create_role_assignments_for_application_gateway = var.create_role_assignments_for_application_gateway
  local_account_disabled                          = false
  log_analytics_workspace_enabled                 = false
  net_profile_dns_service_ip                      = var.aks-dns-service-ip
  net_profile_service_cidr                        = var.aks-svc-subnet
  network_plugin                                  = var.aks-net-plugin
  network_policy                                  = var.aks-net-policy
  os_disk_size_gb                                 = 60
  private_cluster_enabled                         = false
  rbac_aad                                        = true
  rbac_aad_managed                                = true
  role_based_access_control_enabled               = true
  rbac_aad_admin_group_object_ids                 = var.rbac_aad_admin_group_object_ids
  # rbac_aad_admin_group_object_ids = [data.azuread_group.msentra-aks-group.object_id]
  sku_tier       = "Standard"
  vnet_subnet_id = var.bring_your_own_vnet ? azurerm_subnet.aks-subnet[0].id : null
  depends_on = [
    azurerm_subnet.aks-subnet,
  ]
}