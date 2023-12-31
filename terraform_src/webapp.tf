# Define the Azure provider configuration
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "test" {
  name     = "test-resources"
  location = "East US"
}

# Define a virtual network for the three tiers
resource "azurerm_virtual_network" "test" {
  name                = "test-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

# Create a subnet for each tier
resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Create virtual machines for each tier
resource "azurerm_linux_virtual_machine" "web" {
  count                 = 2
  name                  = "web-vm-${count.index}"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [element(azurerm_network_interface.web_nics, count.index).id]
  size                  = "Standard_DS2_v2"
  admin_username        = "adminuser"
  admin_password        = "Passwordxyz34"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Define network interfaces for the VMs
resource "azurerm_network_interface" "web_nics" {
  count               = 2
  name                = "web-nic-${count.index}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define the application tier virtual machines (similar to web tier)

# Application Tier Virtual Machines
resource "azurerm_linux_virtual_machine" "app" {
  count                 = 2 # Number of application VMs
  name                  = "app-vm-${count.index}"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [element(azurerm_network_interface.app_nics, count.index).id]
  size                  = "Standard_DS2_v2"
  admin_username        = "adminuser"
  admin_password        = "Passwordxyz34"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Network Interfaces for Application VMs
resource "azurerm_network_interface" "app_nics" {
  count               = 2
  name                = "app-nic-${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Database Tier (Azure Database for PostgreSQL)
resource "azurerm_postgresql_server" "database" {
  name                         = "mydatabase"
  location                     = azurerm_resource_group.example.location
  ssl_enforcement_enabled      = true
  resource_group_name          = azurerm_resource_group.example.name
  sku_name                     = "GP_Gen5_2"
  administrator_login          = "dbadmin"
  administrator_login_password = "SuperSecretPassword1!"
  version                      = "12"
}

resource "azurerm_postgresql_database" "app_database" {
  name                = "myappdb"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.database.name
  charset             = "UTF8"
  collation           = "en_US.UTF8"
}
