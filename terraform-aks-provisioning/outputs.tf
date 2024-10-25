output "aks-connect-command" {
  description = "The full of the command to connect to the AKS cluster"
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main[0].name} --name ${module.aks.aks_name} --overwrite-existing"
}
