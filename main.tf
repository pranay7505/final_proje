terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.93.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "72c85e04-6d5a-484d-a0ce-325cdfd9fd10"
  client_id       = "3e291224-db59-4c21-8b51-0f1468f2510c"
  client_secret   = "sm68Q~ywN2XG-~t6tF7fFt3crB2lklIQoOB9DcgV"
  tenant_id       = "a1102ec6-f684-4618-84be-d1586d3ecc65"
  
  features {}
}



resource "azurerm_resource_group" "ex_reso" {
  name     = "app-resource"
  location = "Central India"
}



resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = azurerm_resource_group.ex_reso.location
  resource_group_name = azurerm_resource_group.ex_reso.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "SubnetA"
    address_prefix = "10.0.1.0/24"

  }

}

resource "azurerm_subnet" "app_subnet" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.ex_reso.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "app_interface" {
  name                = "app-interface"
  location            = azurerm_resource_group.ex_reso.location
  resource_group_name = azurerm_resource_group.ex_reso.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app_public.id
  }
  depends_on = [azurerm_subnet.app_subnet]
}

resource "azurerm_windows_virtual_machine" "app_machine" {
  name                = "app-machine"
  resource_group_name = azurerm_resource_group.ex_reso.name
  location            = azurerm_resource_group.ex_reso.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.app_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_public_ip" "app_public" {
  name                = "app-public"
  resource_group_name = azurerm_resource_group.ex_reso.name
  location            = azurerm_resource_group.ex_reso.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}