
# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "my_terraform_network"
  address_space       = ["10.0.0.0/16"]
  location            = "UK South"
  resource_group_name = "ResourceGroup1"
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "y_terraform_subnet"
  resource_group_name  = "ResourceGroup1"
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "my_terraform_public_ip"
  location            = "UK South"
  resource_group_name = "ResourceGroup1"
  allocation_method   = "Dynamic"
  sku   =   "Basic"
}

# Create Network Security Group and rules that will allow RDP access - disable this if you intend to use it as a produxtion server or will be storing any form of sensitive data
resource "azurerm_network_security_group" "terraform_sg" {
  name                = "arc-testing-sg"
  location            = "UK South"
  resource_group_name = "ResourceGroup1"

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "my_terraform_nic"
  location            = "UK South"
  resource_group_name = "ResourceGroup1"

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.terraform_sg.id
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "arcvm" {
  name                  = "arcvm"
  admin_username        = "azureuser"
  admin_password        = "Password123!"
  location              = "UK South"
  resource_group_name   = "ResourceGroup1"
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_D8as_v5"  

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  # Select a standards windows 11 operating server 
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# Now we use the Terraform VM extension resource for windows operating systems
resource "azurerm_virtual_machine_extension" "software_install" { 
  name                 = "software_install"
  virtual_machine_id   = azurerm_windows_virtual_machine.arcvm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  
  # The following details powershell commands to execute, their priviliges and creates a software_install.log file that will aid in error detection
  protected_settings = jsonencode({
    "commandToExecute" = "powershell.exe -ExecutionPolicy Unrestricted -NoProfile -Command \"& { [System.IO.File]::WriteAllBytes('C:/software_install.ps1', [System.Convert]::FromBase64String('${base64encode(local.shell_script)}')); powershell.exe -ExecutionPolicy Unrestricted -NoProfile -File C:/software_install.ps1 *> C:/software_install.log }\""
  })

  depends_on = [azurerm_windows_virtual_machine.arcvm]
}

# Now we define the variable 'shell_script' by passing it the path to our file from the root directory
locals {
  shell_script = file("./software_install.ps1")
}





