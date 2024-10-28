## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.116.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aks"></a> [aks](#module\_aks) | Azure/aks/azurerm | 9.1.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.aks-subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.aks-vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_id.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agents_size"></a> [agents\_size](#input\_agents\_size) | The default virtual machine size for the Kubernetes agents. Changing this without specifying `var.temporary_name_for_rotation` forces a new resource to be created. | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_aks-dns-service-ip"></a> [aks-dns-service-ip](#input\_aks-dns-service-ip) | The default DNS service IP of the aks subnet | `string` | n/a | yes |
| <a name="input_aks-net-plugin"></a> [aks-net-plugin](#input\_aks-net-plugin) | The default CNI | `string` | n/a | yes |
| <a name="input_aks-net-policy"></a> [aks-net-policy](#input\_aks-net-policy) | The default CNI Policy | `string` | n/a | yes |
| <a name="input_aks-resources-names"></a> [aks-resources-names](#input\_aks-resources-names) | AKK resources names (AKS cluster, Resource group, etc.) | `map(string)` | n/a | yes |
| <a name="input_aks-subnet-address-prefix"></a> [aks-subnet-address-prefix](#input\_aks-subnet-address-prefix) | The default address prefix of the aks subnet | `string` | n/a | yes |
| <a name="input_aks-svc-subnet"></a> [aks-svc-subnet](#input\_aks-svc-subnet) | The default DNS service IP of the aks subnet | `string` | n/a | yes |
| <a name="input_aks-vnet-address-space"></a> [aks-vnet-address-space](#input\_aks-vnet-address-space) | The default address space of the vnet | `string` | n/a | yes |
| <a name="input_appgw-name"></a> [appgw-name](#input\_appgw-name) | The name of the application gateway ingress | `string` | n/a | yes |
| <a name="input_bring_your_own_vnet"></a> [bring\_your\_own\_vnet](#input\_bring\_your\_own\_vnet) | n/a | `bool` | `true` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | n/a | `bool` | `true` | no |
| <a name="input_create_role_assignments_for_application_gateway"></a> [create\_role\_assignments\_for\_application\_gateway](#input\_create\_role\_assignments\_for\_application\_gateway) | n/a | `bool` | `true` | no |
| <a name="input_green_field_application_gateway_for_ingress"></a> [green\_field\_application\_gateway\_for\_ingress](#input\_green\_field\_application\_gateway\_for\_ingress) | [Definition of `green_field`](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new)<br/>* `name` - (Optional) The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster.<br/>* `subnet_cidr` - (Optional) The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster.<br/>* `subnet_id` - (Optional) The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. | <pre>object({<br/>    name        = optional(string)<br/>    subnet_cidr = optional(string)<br/>    subnet_id   = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_greenfield-appgw-cidr"></a> [greenfield-appgw-cidr](#input\_greenfield-appgw-cidr) | The default address prefix of the aks subnet | `string` | n/a | yes |
| <a name="input_kubernetes-version"></a> [kubernetes-version](#input\_kubernetes-version) | The default Kubernetes version | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"eastus"` | no |
| <a name="input_msentra-aks-admins"></a> [msentra-aks-admins](#input\_msentra-aks-admins) | The group id of the AKS group that needs to be Admins to access AKS cluster | `string` | n/a | yes |
| <a name="input_rbac_aad_admin_group_object_ids"></a> [rbac\_aad\_admin\_group\_object\_ids](#input\_rbac\_aad\_admin\_group\_object\_ids) | Object ID of groups with admin access. | `list(string)` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | `null` | no |
| <a name="input_use-random-names"></a> [use-random-names](#input\_use-random-names) | Use random names for resources if set to yes you must provide aks-resources-names map variable | `bool` | n/a | yes |
| <a name="input_use_brown_field_application_gateway"></a> [use\_brown\_field\_application\_gateway](#input\_use\_brown\_field\_application\_gateway) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks-connect-command"></a> [aks-connect-command](#output\_aks-connect-command) | The full of the command to connect to the AKS cluster |
