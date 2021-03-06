# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      # Specify what version of the provider we are going to utilise
      source = "hashicorp/azurerm"
      version = ">= 2.4.1"
    }
  }
backend "azurerm" {
    resource_group_name   = "azhar-infrast"
    storage_account_name  = "azharmtstate"
    container_name        = "tstate"
    key                   = "BsZqWXMs8FCW7E32oRFDnZ+mMwJAFadkNY4hGhVKEQlPYD4/eEGbQbB3jSS7f6FY5XxiroZnvjoj+AStydC1VQ=="
    }
}
provider "azurerm" {
  features {
      key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
data "azurerm_client_config" "current" {}
# Create our Resource Group - Azhar-RG
resource "azurerm_resource_group" "rg" {
  name     = "azhar-app01"
  location = "East US"
}
# Create our Virtual Network - Azhar-VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "azharchipzvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
# Create our Subnet to hold our VM - Virtual Machines
resource "azurerm_subnet" "sn" {
  name                 = "VM"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = ["10.0.1.0/24"]
}
# Create our Azure Storage Account - Azhar
resource "azurerm_storage_account" "azharulhaqsa" {
  name                     = "azharsa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "azharrox"
  }
}
# Create our vNIC for our VM and assign it to our Virtual Machines Subnet
resource "azurerm_network_interface" "vmnic" {
  name                = "azhar"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Create our Virtual Machine - Jonnychipz-VM01
resource "azurerm_virtual_machine" "azharulhaqvm01" {
  name                  = "azharulhaqvm01"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vmnic.id]
  vm_size               = "Standard_D2s_v3"
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core-smalldisk"
    version   = "latest"
  }
  storage_os_disk {
    name              = "azharulhaqvm01os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name      = "azharulhaqvm01"
    admin_username     = "azharulhaq01"
    admin_password     = "Password123$"
  }
  os_profile_windows_config {
  }
}
