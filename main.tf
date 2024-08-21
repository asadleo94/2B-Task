#Resource Group Creation
resource "azurerm_resource_group" "rg-2B" {
  location = var.location
  name     = var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
}

#Start of Task 1

#Web App 1 VM Creation
resource "azurerm_windows_virtual_machine" "webserver1" {
  admin_password        = var.vm_password
  admin_username        = var.user
  license_type          = "Windows_Server"
  location              =  var.location
  name                  = "WebServer001"
  network_interface_ids = [azurerm_network_interface.webservernic.id]
  resource_group_name   =  var.rg_name
  secure_boot_enabled   = true
  size                  = "Standard_D2s_v3"
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  vtpm_enabled = true
  additional_capabilities {
  }
  boot_diagnostics {
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.webservernic,
  ]
}
# Virtual Machine Extension
resource "azurerm_virtual_machine_extension" "iis-ext-web1" {
  name                 = "vm-script"
  virtual_machine_id   = azurerm_windows_virtual_machine.webserver1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    { 
      "commandToExecute": "powershell Install-WindowsFeature -name Web-Server -IncludeManagementTools;"
    } 
  SETTINGS

  tags = {
    environment = var.env
  }
}
#Web App 2 VM Creation
resource "azurerm_windows_virtual_machine" "webserver2" {
  admin_password        = var.vm_password
  admin_username        = var.user
  license_type          = "Windows_Server"
  location              =  var.location
  name                  = "WebServer002"
  network_interface_ids = [azurerm_network_interface.webser2nic.id]
  resource_group_name   =  var.rg_name
  secure_boot_enabled   = true
  size                  = "Standard_D2s_v3"
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  vtpm_enabled = true
  additional_capabilities {
  }
  boot_diagnostics {
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.webser2nic,
  ]
}
resource "azurerm_virtual_machine_extension" "iis-ext-web2" {
  name                 = "vm-script"
  virtual_machine_id   = azurerm_windows_virtual_machine.webserver2.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    { 
      "commandToExecute": "powershell Install-WindowsFeature -name Web-Server -IncludeManagementTools;"
    } 
  SETTINGS

  tags = {
    environment = var.env
  }
}
#Networking
resource "azurerm_virtual_network" "web1vnet" {
  address_space       = ["10.1.0.0/24"]
  location            =  var.location
  name                = "vnet-webserver-001"
  resource_group_name =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
resource "azurerm_subnet" "web2vnet" {
  address_prefixes     = ["10.1.0.0/25"]
  name                 = "sn-webserver-001"
  resource_group_name  =  var.rg_name
  service_endpoints    = ["Microsoft.ServiceBus", "Microsoft.Storage"]
  virtual_network_name = "vnet-webserver-001"
  depends_on = [
    azurerm_virtual_network.web1vnet,
  ]
}
resource "azurerm_network_interface" "webservernic" {
  #enable_accelerated_networking = true
  location                      =  var.location
  name                          = "webserver001627"
  resource_group_name           =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.web2vnet.id
  }
  depends_on = [
    azurerm_public_ip.web1pubip,
    azurerm_subnet.web2vnet,
  ]
}
resource "azurerm_network_interface_security_group_association" "webser1nic" {
  network_interface_id      = azurerm_network_interface.webservernic.id
  network_security_group_id = azurerm_network_security_group.web1nsg.id
  depends_on = [
    azurerm_network_interface.webservernic,
    azurerm_network_security_group.web1nsg,
  ]
}
resource "azurerm_network_interface_security_group_association" "webser2nsg" {
  network_interface_id      = azurerm_network_interface.webser2nic.id
  network_security_group_id = azurerm_network_security_group.web2nsg.id
  depends_on = [
    azurerm_network_interface.webser2nic,
    azurerm_network_security_group.web2nsg,
  ]
}
resource "azurerm_public_ip" "web1pubip" {
  allocation_method   = "Static"
  location            =  var.location
  name                = "WebServer001-ip"
  resource_group_name =  var.rg_name
  sku                 = "Standard"
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
resource "azurerm_public_ip" "web2pubip" {
  allocation_method   = "Static"
  location            =  var.location
  name                = "WebServer002-ip"
  resource_group_name =  var.rg_name
  sku                 = "Standard"
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
resource "azurerm_network_interface" "webser2nic" {
  #enable_accelerated_networking = true
  location                      =  var.location
  name                          = "webserver002606"
  resource_group_name           =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.web2vnet.id
  }
  depends_on = [
    azurerm_public_ip.web2pubip,
    azurerm_subnet.web2vnet,
  ]
}
resource "azurerm_network_security_group" "web2nsg" {
  location            =  var.location
  name                = "WebServer002-nsg"
  resource_group_name =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
resource "azurerm_network_security_group" "web1nsg" {
  location            =  var.location
  name                = "WebServer001-nsg"
  resource_group_name =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
resource "azurerm_network_security_rule" "webnsgrule1" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "80"
  direction                   = "Inbound"
  name                        = "Allow-Port-80"
  network_security_group_name = "WebServer001-nsg"
  priority                    = 310
  protocol                    = "Tcp"
  resource_group_name         =  var.rg_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.web1nsg,
  ]
}
resource "azurerm_network_security_rule" "webnsgrule2" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "3389"
  direction                   = "Inbound"
  name                        = "RDP"
  network_security_group_name = "WebServer001-nsg"
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         =  var.rg_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.web1nsg,
  ]
}

resource "azurerm_network_security_rule" "web2nsgrule1" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "80"
  direction                   = "Inbound"
  name                        = "Allow-Port-80"
  network_security_group_name = "WebServer002-nsg"
  priority                    = 310
  protocol                    = "*"
  resource_group_name         =  var.rg_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.web2nsg,
  ]
}
resource "azurerm_network_security_rule" "web2nsgrule2" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "3389"
  direction                   = "Inbound"
  name                        = "RDP"
  network_security_group_name = "WebServer002-nsg"
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         =  var.rg_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.web2nsg,
  ]
}

#Load Balancer Creation Code - Task 1
resource "azurerm_lb" "loadbalancer" {
  location            =  var.location
  name                = "lb-webserver-001"
  resource_group_name =  var.rg_name
  sku                 = "Standard"
  
  tags = {
    Environment = var.env
    Owner       = var.owner
  }

  frontend_ip_configuration {
    name                 = "lb-ws-ip-001"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id  # Reference the Public IP
  }

  depends_on = [
    azurerm_resource_group.rg-2B,    # Ensure the resource group is created first
    azurerm_public_ip.lb_public_ip   # Ensure the public IP is created before the LB
  ]
}
# Define the Public IP
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lb-webserver-pip"
  location            =  var.location
  resource_group_name =  var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
    depends_on = [
    azurerm_resource_group.rg-2B,    # Ensure the resource group is created first
  ]
}
resource "azurerm_lb_backend_address_pool" "lb-bck" {
  loadbalancer_id = azurerm_lb.loadbalancer.id
  name            = "lb-bckpool-001"
  depends_on = [
    azurerm_lb.loadbalancer,
  ]
}
resource "azurerm_lb_rule" "lbrules" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-bck.id]
  backend_port                   = 80
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "lb-ws-ip-001"
  frontend_port                  = 80
  loadbalancer_id                = azurerm_lb.loadbalancer.id
  name                           = "lb-rb-001"
  protocol                       = "Tcp"
  depends_on = [
    azurerm_lb_backend_address_pool.lb-bck,
  ]
}
resource "azurerm_lb_probe" "lb_probe" {
  interval_in_seconds = 5
  loadbalancer_id     = azurerm_lb.loadbalancer.id
  name                = "lb-ph-001"
  number_of_probes    = 1
  port                = 80
  depends_on = [
    azurerm_lb.loadbalancer,
  ]
}
resource "azurerm_network_interface_backend_address_pool_association" "lbnicpool" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-bck.id
  ip_configuration_name   = "ipconfig1"
  network_interface_id    = azurerm_network_interface.webservernic.id
  depends_on = [
    azurerm_lb_backend_address_pool.lb-bck,
    azurerm_network_interface.webservernic,
  ]
}
resource "azurerm_public_ip" "lbpubip" {
  allocation_method   = "Static"
  location            =  var.location
  name                = "lb-ws-ip-pubip"
  resource_group_name =  var.rg_name
  sku                 = "Standard"
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  zones = ["1", "2", "3"]
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-bck-nic" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-bck.id
  ip_configuration_name   = "ipconfig1"
  network_interface_id    = azurerm_network_interface.webser2nic.id
  depends_on = [
    azurerm_lb_backend_address_pool.lb-bck,
    azurerm_network_interface.webser2nic,
  ]
}
#End of Task 1

#Start of Task 2

# App Server VM Creation Code
resource "azurerm_windows_virtual_machine" "appserver" {
  admin_password        = var.vm_password
  admin_username        = var.user
  license_type          = "Windows_Server"
  location              =  var.location
  name                  = "AppServer001"
  network_interface_ids = [azurerm_network_interface.appservice-nic.id]
  resource_group_name   =  var.rg_name
  secure_boot_enabled   = true
  size                  = "Standard_D2s_v3"
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  vtpm_enabled = true
  additional_capabilities {
  }
  boot_diagnostics {
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.appservice-nic,
  ]
}
resource "azurerm_virtual_network" "appvnet" {
  address_space       = ["10.2.0.0/24"]
  location            =  var.location
  name                = "vnet-appserver-001"
  resource_group_name =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
resource "azurerm_subnet" "appsubnet" {
  address_prefixes     = ["10.2.0.0/25"]
  name                 = "sn-appserver-001"
  resource_group_name  =  var.rg_name
  service_endpoints    = ["Microsoft.ServiceBus"]
  virtual_network_name = "vnet-appserver-001"
  depends_on = [
    azurerm_virtual_network.appvnet,
  ]
}
resource "azurerm_network_interface" "appservice-nic" {
  #enable_accelerated_networking = "true"
  location                      =  var.location
  name                          = "appserver001337"
  resource_group_name           =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.appsubnet.id
  }
  depends_on = [
    azurerm_public_ip.appserverpubip,
    azurerm_subnet.appsubnet,
  ]
}
resource "azurerm_network_interface_security_group_association" "appservernic1" {
  network_interface_id      = azurerm_network_interface.appservice-nic.id
  network_security_group_id = azurerm_network_security_group.appservernsg.id
  depends_on = [
    azurerm_network_interface.appservice-nic,
    azurerm_network_security_group.appservernsg,
  ]
}
resource "azurerm_network_security_group" "appservernsg" {
  location            =  var.location
  name                = "AppServer001-nsg"
  resource_group_name =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
resource "azurerm_network_security_rule" "appserverinbound" {
  access                      = "Allow"
  destination_address_prefix  = "10.2.0.0/24"
  destination_port_range      = "*"
  direction                   = "Inbound"
  name                        = "AllowCidrBlockCustomAnyInbound"
  network_security_group_name = "AppServer001-nsg"
  priority                    = 320
  protocol                    = "*"
  resource_group_name         =  var.rg_name
  source_address_prefix       = "10.1.0.0/24"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.appservernsg,
  ]
}
resource "azurerm_network_security_rule" "appnsgrule1" {
  access                      = "Allow"
  destination_address_prefix  = "10.1.0.0/24"
  destination_port_range      = "*"
  direction                   = "Outbound"
  name                        = "AllowCidrBlockCustomAnyOutbound"
  network_security_group_name = "AppServer001-nsg"
  priority                    = 330
  protocol                    = "*"
  resource_group_name         =  var.rg_name
  source_address_prefix       = "10.2.0.0/24"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.appservernsg,
  ]
}
resource "azurerm_network_security_rule" "appnsgrule2" {
  access                      = "Deny"
  destination_address_prefix  = "10.2.0.0/24"
  destination_port_range      = "*"
  direction                   = "Inbound"
  name                        = "DenyAnyCustomAnyInbound"
  network_security_group_name = "AppServer001-nsg"
  priority                    = 310
  protocol                    = "*"
  resource_group_name         =  var.rg_name
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.appservernsg,
  ]
}
resource "azurerm_public_ip" "appserverpubip" {
  allocation_method   = "Static"
  location            =  var.location
  name                = "AppServer001-ip"
  resource_group_name =  var.rg_name
  sku                 = "Standard"
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}


#End of Task 2


#Start Of Task 3

# Windows VM where SQL Server is installed
resource "azurerm_windows_virtual_machine" "dbserver" {
  admin_password        = var.vm_password
  admin_username        = var.user
  license_type          = "Windows_Server"
  location              =  var.location
  name                  = "DBServer001"
  network_interface_ids = [azurerm_network_interface.dbservernic.id]
  resource_group_name   =  var.rg_name
  secure_boot_enabled   = true
  size                  = "Standard_D2s_v3"
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  vtpm_enabled = true

  additional_capabilities {}
  
  boot_diagnostics {}

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    offer     = "sql2022-ws2022"
    publisher = "microsoftsqlserver"
    sku       = "standard-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.dbservernic,
  ]
}
# SQL Virtual Machine resource
resource "azurerm_mssql_virtual_machine" "dbvm" {
  sql_license_type   = "PAYG"
  virtual_machine_id = azurerm_windows_virtual_machine.dbserver.id
  tags = {
    Environment = var.env
    Owner       = var.owner
  }

  sql_instance {}

  storage_configuration {
    disk_type             = "NEW"
    storage_workload_type = "OLTP"

    data_settings {
      default_file_path = "F:\\data"
      luns              = [0]  # Reference to the data disk attached to LUN 0
    }

    log_settings {
      default_file_path = "G:\\log"
      luns              = [1]  # Reference to the log disk attached to LUN 1
    }

    temp_db_settings {
      data_file_count        = 2
      data_file_growth_in_mb = 64
      data_file_size_mb      = 8
      default_file_path      = "D:\\tempDb"
      log_file_growth_mb     = 64
      log_file_size_mb       = 8
      luns                   = []  # No additional disks for temp DB
    }
  }

  depends_on = [
    azurerm_windows_virtual_machine.dbserver,
    azurerm_virtual_machine_data_disk_attachment.dbserver-disk1,
    azurerm_virtual_machine_data_disk_attachment.dbserver-disk2,
  ]
}
resource "azurerm_managed_disk" "db-disk1" {
  create_option        = "Empty"
  location             =  var.location
  name                 = "DBServer001_DataDisk_0"
  resource_group_name  =  var.rg_name
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 128  
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
resource "azurerm_managed_disk" "db-disk2" {
  create_option        = "Empty"
  location             =  var.location
  name                 = "DBServer001_DataDisk_1"
  resource_group_name  =  var.rg_name
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 128  
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
# Managed Disk for Data
resource "azurerm_managed_disk" "db-disksql" {
  name                 = "sql-data-disk"
  location             = azurerm_windows_virtual_machine.dbserver.location
  resource_group_name  = azurerm_windows_virtual_machine.dbserver.resource_group_name
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 128
  create_option        = "Empty"
}
# Managed Disk for Logs
resource "azurerm_managed_disk" "db-disksql2" {
  name                 = "sql-log-disk"
  location             = azurerm_windows_virtual_machine.dbserver.location
  resource_group_name  = azurerm_windows_virtual_machine.dbserver.resource_group_name
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 128
  create_option        = "Empty"
}
# Attach data disk to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "dbserver-disk1" {
  caching            = "ReadOnly"
  lun                = 0
  managed_disk_id    = azurerm_managed_disk.db-disk1.id
  virtual_machine_id = azurerm_windows_virtual_machine.dbserver.id

  depends_on = [
    azurerm_managed_disk.db-disk1,
    azurerm_windows_virtual_machine.dbserver,
  ]
}
# Attach log disk to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "dbserver-disk2" {
  caching            = "None"
  lun                = 1
  managed_disk_id    = azurerm_managed_disk.db-disk2.id
  virtual_machine_id = azurerm_windows_virtual_machine.dbserver.id

  depends_on = [
    azurerm_managed_disk.db-disk2,
    azurerm_windows_virtual_machine.dbserver,
  ]
}
#Networking
resource "azurerm_virtual_network" "dbvnet" {
  address_space       = ["10.3.0.0/24"]
  location            =  var.location
  name                = "vnet-dbserver-001"
  resource_group_name =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
resource "azurerm_subnet" "dbsubnet" {
  address_prefixes     = ["10.3.0.0/25"]
  name                 = "sn-dbserver-001"
  resource_group_name  =  var.rg_name
  virtual_network_name = "vnet-dbserver-001"
  depends_on = [
    azurerm_virtual_network.dbvnet,
  ]
}
resource "azurerm_network_interface" "dbservernic" {
  #enable_accelerated_networking = true
  location                      =  var.location
  name                          = "dbserver001387"
  resource_group_name           =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.dbsubnet.id
  }
  depends_on = [
    azurerm_public_ip.dbpubip,
    azurerm_subnet.dbsubnet,
  ]
}
resource "azurerm_network_interface_security_group_association" "dbservernsg" {
  network_interface_id      = azurerm_network_interface.dbservernic.id
  network_security_group_id = azurerm_network_security_group.dbnsg.id
  depends_on = [
    azurerm_network_interface.dbservernic,
    azurerm_network_security_group.dbnsg,
  ]
}
resource "azurerm_network_security_group" "dbnsg" {
  location            =  var.location
  name                = "DBServer001-nsg"
  resource_group_name =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
resource "azurerm_network_security_rule" "dbnsgrule1" {
  access                      = "Allow"
  destination_address_prefix  = "10.3.0.4"
  destination_port_range      = "1434"
  direction                   = "Inbound"
  name                        = "AllowCidrBlockCustom1434Inbound"
  network_security_group_name = "DBServer001-nsg"
  priority                    = 330
  protocol                    = "Udp"
  resource_group_name         =  var.rg_name
  source_address_prefixes     = ["10.1.0.4", "10.1.0.5", "10.2.0.4"]
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.dbnsg,
  ]
}
resource "azurerm_network_security_rule" "dbnsgrule2" {
  access                      = "Allow"
  destination_address_prefix  = "10.3.0.4"
  destination_port_ranges     = ["1433", "3389", "50000"]
  direction                   = "Inbound"
  name                        = "AllowCidrBlockCustomInbound"
  network_security_group_name = "DBServer001-nsg"
  priority                    = 320
  protocol                    = "Tcp"
  resource_group_name         =  var.rg_name
  source_address_prefixes     = ["10.1.0.4", "10.1.0.5", "10.2.0.4"]
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.dbnsg,
  ]
}
resource "azurerm_network_security_rule" "dbnsgrule3" {
  access                      = "Deny"
  destination_address_prefix  = "10.3.0.4"
  destination_port_range      = "*"
  direction                   = "Inbound"
  name                        = "DenyTagCustomAnyInbound"
  network_security_group_name = "DBServer001-nsg"
  priority                    = 310
  protocol                    = "*"
  resource_group_name         =  var.rg_name
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.dbnsg,
  ]
}
resource "azurerm_public_ip" "dbpubip" {
  allocation_method   = "Static"
  location            =  var.location
  name                = "DBServer001-ip"
  resource_group_name =  var.rg_name
  sku                 = "Standard"
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}

#End of Task 3

# VBirtual Network Communication Peering
resource "azurerm_virtual_network_peering" "dbpeer1" {
  name                      = "lpl-dbserver"
  remote_virtual_network_id = azurerm_virtual_network.web1vnet.id
  resource_group_name       =  var.rg_name
  virtual_network_name      = "vnet-dbserver-001"
  depends_on = [
    azurerm_virtual_network.dbvnet,
    azurerm_virtual_network.web1vnet,
  ]
}
resource "azurerm_virtual_network_peering" "dbpeer2" {
  name                      = "rpl-dbserver"
  remote_virtual_network_id = azurerm_virtual_network.appvnet.id
  resource_group_name       =  var.rg_name
  virtual_network_name      = "vnet-dbserver-001"
  depends_on = [
    azurerm_virtual_network.appvnet,
    azurerm_virtual_network.dbvnet,
  ]
}

resource "azurerm_virtual_network_peering" "webpeer1" {
  name                      = "rpl-webserver"
  remote_virtual_network_id = azurerm_virtual_network.appvnet.id
  resource_group_name       =  var.rg_name
  virtual_network_name      = "vnet-webserver-001"
  depends_on = [
    azurerm_virtual_network.appvnet,
    azurerm_virtual_network.web1vnet,
  ]
}
resource "azurerm_virtual_network_peering" "weebpeer2" {
  name                      = "rpl-webserver-db"
  remote_virtual_network_id = azurerm_virtual_network.dbvnet.id
  resource_group_name       =  var.rg_name
  virtual_network_name      = "vnet-webserver-001"
  depends_on = [
    azurerm_virtual_network.dbvnet,
    azurerm_virtual_network.web1vnet,
  ]
}
resource "azurerm_virtual_network_peering" "apppeer1" {
  name                      = "lpl-appserver"
  remote_virtual_network_id = azurerm_virtual_network.dbvnet.id
  resource_group_name       =  var.rg_name
  virtual_network_name      = "vnet-appserver-001"
  depends_on = [
    azurerm_virtual_network.appvnet,
    azurerm_virtual_network.dbvnet,
  ]
}
resource "azurerm_virtual_network_peering" "appperr2" {
  name                      = "lpl-appserver-webserver"
  remote_virtual_network_id = azurerm_virtual_network.web1vnet.id
  resource_group_name       =  var.rg_name
  virtual_network_name      = "vnet-appserver-001"
  depends_on = [
    azurerm_virtual_network.appvnet,
    azurerm_virtual_network.web1vnet,
  ]
}

#Storage Container (Private and Public) Creation -  Task 4

#Storage Container Private
resource "azurerm_storage_account" "pristg" {
  account_replication_type         = "LRS"
  account_tier                     = "Standard"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  location                         =  var.location
  name                             = "st2bprivate001"
  resource_group_name              =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
  ]
}
resource "azurerm_storage_container" "pricon" {
  name                 = "container-private-001"
  storage_account_name = "st2bprivate001"
  depends_on = [
    azurerm_resource_group.rg-2B,
    azurerm_storage_account.pristg
  ]
}
#Storage Container Public
resource "azurerm_storage_account" "stgpub" {
  account_replication_type         = "LRS"
  account_tier                     = "Standard"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  location                         =  var.location
  name                             = "st2bpublic001"
  resource_group_name              =  var.rg_name
  tags = {
    Environment = var.env
    Owner       = var.owner
  }
  depends_on = [
    azurerm_resource_group.rg-2B,
    azurerm_storage_account.stgpub
  ]
}
resource "azurerm_storage_container" "pubcon" {
  name                 = "container-public-001"
  storage_account_name = "st2bpublic001"
  depends_on = [
    azurerm_resource_group.rg-2B,
    azurerm_storage_account.stgpub
  ]

}

#Storage Container (Private and Public) Creation -  Task 5
# Create an Azure AD Application with the name "app_server_sp"
resource "azuread_application" "app_server_sp" {
  display_name = "app_server_sp"
}

resource "azuread_service_principal" "app_server_sp" {
  client_id = azuread_application.app_server_sp.client_id
}

resource "azuread_service_principal_password" "app_server_sp" {
  service_principal_id = azuread_service_principal.app_server_sp.id
  end_date_relative    = "8760h"  # 1 year from now
}

resource "azurerm_role_assignment" "sp_role_assignment" {
  principal_id         = azuread_service_principal.app_server_sp.id
  role_definition_name = "Contributor"
  scope                = data.azurerm_subscription.primary.id
}


# Create an Azure AD Application with the name "web_service_sp"
resource "azuread_application" "web_service_sp" {
  display_name = "web_service_sp"
}

resource "azuread_service_principal" "web_service_sp" {
  client_id = azuread_application.web_service_sp.client_id
}

resource "azuread_service_principal_password" "web_service_sp" {
  service_principal_id = azuread_service_principal.web_service_sp.id
  end_date_relative    = "8760h"  # 1 year from now
}
resource "azurerm_role_assignment" "web_sp_role_assignment" {
  principal_id         = azuread_service_principal.web_service_sp.id
  role_definition_name = "Contributor"
  scope                = data.azurerm_subscription.primary.id
}
data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current" {}


