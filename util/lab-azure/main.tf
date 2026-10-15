# ============================================
# Ansible lab servers on Azure
# Everything lives in one resource group, so
# "terraform destroy" (or deleting the RG) cleans up.
# ============================================

# Public key: explicit variable, or the repo-local util/keys/ansible-lab.pub
locals {
  ssh_public_key = coalesce(var.ssh_public_key, trimspace(file("${path.module}/../keys/ansible-lab.pub")))
}

resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ---------- Network ----------

resource "azurerm_virtual_network" "lab" {
  name                = "${var.instance_name_prefix}-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
}

resource "azurerm_subnet" "lab" {
  name                 = "${var.instance_name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "lab" {
  name                = "${var.instance_name_prefix}-nsg"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.allowed_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-icmp"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.allowed_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "lab" {
  subnet_id                 = azurerm_subnet.lab.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

# ---------- Per-server public IP + NIC ----------

resource "azurerm_public_ip" "lab" {
  count               = var.instance_count
  name                = "${var.instance_name_prefix}-${count.index + 1}-pip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "lab" {
  count               = var.instance_count
  name                = "${var.instance_name_prefix}-${count.index + 1}-nic"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab[count.index].id
  }
}

# ---------- Lab servers ----------

resource "azurerm_linux_virtual_machine" "lab" {
  count               = var.instance_count
  name                = "${var.instance_name_prefix}-${count.index + 1}"
  computer_name       = "${var.instance_name_prefix}-${count.index + 1}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  size                = var.vm_size
  admin_username      = var.ssh_user
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.lab[count.index].id]

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

  # Ubuntu images ship with python3; python3-apt makes the apt module happy
  custom_data = base64encode(<<-EOF
    #cloud-config
    package_update: true
    packages:
      - python3
      - python3-apt
  EOF
  )
}
