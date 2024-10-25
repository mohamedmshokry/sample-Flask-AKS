# azurerm_kubernetes_cluster.manual-created-aks:
resource "azurerm_kubernetes_cluster" "manual-created-aks" {
    automatic_upgrade_channel           = "patch"
    azure_policy_enabled                = false
    cost_analysis_enabled               = false
    current_kubernetes_version          = "1.29.9"
    disk_encryption_set_id              = [90mnull[0m[0m
    dns_prefix                          = "aks-cluster-01-dns"
    dns_prefix_private_cluster          = [90mnull[0m[0m
    edge_zone                           = [90mnull[0m[0m
    fqdn                                = "aks-cluster-01-dns-oirvx5ux.hcp.eastus.azmk8s.io"
    http_application_routing_enabled    = false
    http_application_routing_zone_name  = [90mnull[0m[0m
    id                                  = "/subscriptions/ff3487eb-e5ec-44cb-8d02-b4b59abb7f9e/resourceGroups/aks-demo/providers/Microsoft.ContainerService/managedClusters/aks-cluster-01"
    image_cleaner_enabled               = true
    image_cleaner_interval_hours        = 168
    kube_admin_config                   = (sensitive value)
    kube_admin_config_raw               = (sensitive value)
    kube_config                         = (sensitive value)
    kube_config_raw                     = (sensitive value)
    kubernetes_version                  = "1.29.9"
    local_account_disabled              = false
    location                            = "eastus"
    name                                = "aks-cluster-01"
    node_os_upgrade_channel             = "NodeImage"
    node_resource_group                 = "MC_aks-demo_aks-cluster-01_eastus"
    node_resource_group_id              = "/subscriptions/ff3487eb-e5ec-44cb-8d02-b4b59abb7f9e/resourceGroups/MC_aks-demo_aks-cluster-01_eastus"
    oidc_issuer_enabled                 = false
    oidc_issuer_url                     = [90mnull[0m[0m
    open_service_mesh_enabled           = false
    portal_fqdn                         = "aks-cluster-01-dns-oirvx5ux.portal.hcp.eastus.azmk8s.io"
    private_cluster_enabled             = false
    private_cluster_public_fqdn_enabled = false
    private_dns_zone_id                 = [90mnull[0m[0m
    private_fqdn                        = [90mnull[0m[0m
    resource_group_name                 = "aks-demo"
    role_based_access_control_enabled   = true
    run_command_enabled                 = true
    sku_tier                            = "Free"
    support_plan                        = "KubernetesOfficial"
    tags                                = {}
    workload_identity_enabled           = false

    auto_scaler_profile {
        balance_similar_node_groups      = false
        empty_bulk_delete_max            = "10"
        expander                         = "random"
        max_graceful_termination_sec     = "600"
        max_node_provisioning_time       = "15m"
        max_unready_nodes                = 3
        max_unready_percentage           = 45
        new_pod_scale_up_delay           = "0s"
        scale_down_delay_after_add       = "10m"
        scale_down_delay_after_delete    = "10s"
        scale_down_delay_after_failure   = "3m"
        scale_down_unneeded              = "10m"
        scale_down_unready               = "20m"
        scale_down_utilization_threshold = "0.5"
        scan_interval                    = "10s"
        skip_nodes_with_local_storage    = false
        skip_nodes_with_system_pods      = true
    }

    default_node_pool {
        auto_scaling_enabled          = true
        capacity_reservation_group_id = [90mnull[0m[0m
        fips_enabled                  = false
        gpu_instance                  = [90mnull[0m[0m
        host_encryption_enabled       = false
        host_group_id                 = [90mnull[0m[0m
        kubelet_disk_type             = "OS"
        max_count                     = 5
        max_pods                      = 110
        min_count                     = 2
        name                          = "agentpool"
        node_count                    = 2
        node_labels                   = {}
        node_public_ip_enabled        = false
        node_public_ip_prefix_id      = [90mnull[0m[0m
        only_critical_addons_enabled  = false
        orchestrator_version          = "1.29.9"
        os_disk_size_gb               = 128
        os_disk_type                  = "Managed"
        os_sku                        = "Ubuntu"
        pod_subnet_id                 = [90mnull[0m[0m
        proximity_placement_group_id  = [90mnull[0m[0m
        scale_down_mode               = "Delete"
        snapshot_id                   = [90mnull[0m[0m
        tags                          = {}
        temporary_name_for_rotation   = [90mnull[0m[0m
        type                          = "VirtualMachineScaleSets"
        ultra_ssd_enabled             = false
        vm_size                       = "Standard_D4pls_v5"
        vnet_subnet_id                = [90mnull[0m[0m
        workload_runtime              = [90mnull[0m[0m
        zones                         = []

        upgrade_settings {
            drain_timeout_in_minutes      = 0
            max_surge                     = "10%"
            node_soak_duration_in_minutes = 0
        }
    }

    identity {
        identity_ids = []
        principal_id = "f0a6fbf3-daca-405b-b5de-2b0a61cdf2e0"
        tenant_id    = "8e3ba3a6-8904-4766-96df-6f73186bf69f"
        type         = "SystemAssigned"
    }

    ingress_application_gateway {
        effective_gateway_id                 = "/subscriptions/ff3487eb-e5ec-44cb-8d02-b4b59abb7f9e/resourceGroups/MC_aks-demo_aks-cluster-01_eastus/providers/Microsoft.Network/applicationGateways/ingress-appgateway"
        gateway_id                           = [90mnull[0m[0m
        gateway_name                         = "ingress-appgateway"
        ingress_application_gateway_identity = [
            {
                client_id                 = "efff4d9d-4190-407f-98e4-f7aab862bacd"
                object_id                 = "0134c109-2308-445f-b1f5-466c828672db"
                user_assigned_identity_id = "/subscriptions/ff3487eb-e5ec-44cb-8d02-b4b59abb7f9e/resourcegroups/MC_aks-demo_aks-cluster-01_eastus/providers/Microsoft.ManagedIdentity/userAssignedIdentities/ingressapplicationgateway-aks-cluster-01"
            },
        ]
        subnet_cidr                          = [90mnull[0m[0m
        subnet_id                            = [90mnull[0m[0m
    }

    kubelet_identity {
        client_id                 = "9ad0a84d-12b0-4b2c-937c-5d366415680f"
        object_id                 = "5019e1f6-9494-4245-ad12-ed04cf816327"
        user_assigned_identity_id = "/subscriptions/ff3487eb-e5ec-44cb-8d02-b4b59abb7f9e/resourceGroups/MC_aks-demo_aks-cluster-01_eastus/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aks-cluster-01-agentpool"
    }

    maintenance_window_auto_upgrade {
        day_of_month = 0
        day_of_week  = "Sunday"
        duration     = 4
        frequency    = "Weekly"
        interval     = 1
        start_date   = "2024-10-25T00:00:00Z"
        start_time   = "00:00"
        utc_offset   = "+00:00"
        week_index   = [90mnull[0m[0m
    }

    maintenance_window_node_os {
        day_of_month = 0
        day_of_week  = "Sunday"
        duration     = 4
        frequency    = "Weekly"
        interval     = 1
        start_date   = "2024-10-25T00:00:00Z"
        start_time   = "00:00"
        utc_offset   = "+00:00"
        week_index   = [90mnull[0m[0m
    }

    monitor_metrics {
        annotations_allowed = [90mnull[0m[0m
        labels_allowed      = [90mnull[0m[0m
    }

    network_profile {
        dns_service_ip      = "10.0.0.10"
        ip_versions         = [
            "IPv4",
        ]
        load_balancer_sku   = "standard"
        network_data_plane  = "azure"
        network_mode        = [90mnull[0m[0m
        network_plugin      = "azure"
        network_plugin_mode = [90mnull[0m[0m
        network_policy      = [90mnull[0m[0m
        outbound_type       = "loadBalancer"
        pod_cidr            = [90mnull[0m[0m
        pod_cidrs           = []
        service_cidr        = "10.0.0.0/16"
        service_cidrs       = [
            "10.0.0.0/16",
        ]

        load_balancer_profile {
            effective_outbound_ips      = [
                "/subscriptions/ff3487eb-e5ec-44cb-8d02-b4b59abb7f9e/resourceGroups/MC_aks-demo_aks-cluster-01_eastus/providers/Microsoft.Network/publicIPAddresses/eb10231d-c7a6-41fc-a3a7-a28719c560ac",
            ]
            idle_timeout_in_minutes     = 0
            managed_outbound_ip_count   = 1
            managed_outbound_ipv6_count = 0
            outbound_ip_address_ids     = []
            outbound_ip_prefix_ids      = []
            outbound_ports_allocated    = 0
        }
    }

    windows_profile {
        admin_password = (sensitive value)
        admin_username = "azureuser"
        license        = [90mnull[0m[0m
    }
}
