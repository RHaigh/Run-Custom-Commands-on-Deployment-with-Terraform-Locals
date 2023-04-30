variable "resource_group_location" {
  type = string
  default = "uksouth"
  description = "Default location of resource group"
}

variable "prefix" {
  type = string
  default = "win-vm"
  description = "Default resource prefix"
}
