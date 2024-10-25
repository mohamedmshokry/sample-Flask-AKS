variable "use-random-names" {
  type        = bool
  description = "Use random names for resources if set to yes you must provide aks-resources-names map variable"
}

variable "msentra-aks-admins" {
  type        = string
  description = "The group id of the AKS group that needs to be Admins to access AKS cluster"
}

variable "aks-resources-names" {
  type        = map(string)
  description = "AKK resources names (AKS cluster, Resource group, etc.)"
}

variable "bring_your_own_vnet" {
  type    = bool
  default = true
}

variable "create_resource_group" {
  type     = bool
  default  = true
  nullable = false
}

variable "create_role_assignments_for_application_gateway" {
  type    = bool
  default = true
}

variable "location" {
  default = "eastus"
}

variable "resource_group_name" {
  type    = string
  default = null
}

variable "use_brown_field_application_gateway" {
  type    = bool
  default = false
}

variable "aks-vnet-address-space" {
  type        = string
  description = "The default address space of the vnet"
}

variable "aks-subnet-address-prefix" {
  type        = string
  description = "The default address prefix of the aks subnet"
}

variable "greenfield-appgw-cidr" {
  type        = string
  description = "The default address prefix of the aks subnet"
}

variable "appgw-name" {
  type        = string
  description = "The name of the application gateway ingress"
}

variable "kubernetes-version" {
  type        = string
  description = "The default Kubernetes version"
}

variable "green_field_application_gateway_for_ingress" {
  type = object({
    name        = optional(string)
    subnet_cidr = optional(string)
    subnet_id   = optional(string)
  })
  description = <<-EOT
  [Definition of `green_field`](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new)
  * `name` - (Optional) The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster.
  * `subnet_cidr` - (Optional) The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster.
  * `subnet_id` - (Optional) The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster.
EOT
}

variable "agents_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "The default virtual machine size for the Kubernetes agents. Changing this without specifying `var.temporary_name_for_rotation` forces a new resource to be created."
}

variable "rbac_aad_admin_group_object_ids" {
  type        = list(string)
  default     = null
  description = "Object ID of groups with admin access."
}


variable "aks-dns-service-ip" {
  type        = string
  description = "The default DNS service IP of the aks subnet"
}

variable "aks-svc-subnet" {
  type        = string
  description = "The default DNS service IP of the aks subnet"
}

variable "aks-net-plugin" {
  type        = string
  description = "The default CNI"
  validation {
    condition     = contains(["azure", "kubenet"], var.aks-net-plugin)
    error_message = "The network plugin must be either 'azure' or 'kubenet'."
  }
}

variable "aks-net-policy" {
  type        = string
  description = "The default CNI Policy"
}