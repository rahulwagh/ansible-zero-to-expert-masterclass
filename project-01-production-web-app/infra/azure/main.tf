# ============================================
# Ansible real-world project · Azure
# 4 Ubuntu 22.04 VMs: lb-1, app-1, app-2, db-1
# ============================================

# Public key: explicit variable, or the repo-local infra/keys/lab.pub
locals {
  ssh_public_key = coalesce(var.ssh_public_key, trimspace(file("${path.module}/../keys/lab.pub")))
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ansible-project-vnet"
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "ansible-project-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.1.0/24"]
}

# NSG: public SSH/HTTP/HTTPS. Traffic inside the VNet is allowed by Azure's default rules.
resource "azurerm_network_security_group" "nsg" {
  name                = "ansible-project-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = { ssh = 22, http = 80, https = 443 }
    content {
      name                       = "allow-${security_rule.key}"
      priority                   = 100 + index(keys({ ssh = 22, http = 80, https = 443 }), security_rule.key) * 10
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = tostring(security_rule.value)
      source_address_prefix      = var.allowed_cidr == "0.0.0.0/0" ? "*" : var.allowed_cidr
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "pip" {
  for_each            = var.servers
  name                = "${each.key}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic" {
  for_each            = var.servers
  name                = "${each.key}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each              = var.servers
  name                  = each.key
  computer_name         = each.key
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.vm_size
  admin_username        = var.ssh_user
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  tags                  = merge(var.tags, { group = each.value })

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.ssh_user
    public_key = local.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #cloud-config
    package_update: true
    packages: [python3, python3-apt]
  EOF
  )
}

locals {
  public_ip  = { for k, p in azurerm_public_ip.pip : k => p.ip_address }
  private_ip = { for k, n in azurerm_network_interface.nic : k => n.private_ip_address }
}
