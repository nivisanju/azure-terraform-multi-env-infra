subnets = [
  {
    name              = "app-subnet"
    address_prefixes  = ["10.20.1.0/24"]
    service_endpoints = ["Microsoft.Storage"]
    nsg_rules = [
      {
        name                       = "AllowSSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  },
  {
    name              = "data-subnet"
    address_prefixes  = ["10.20.2.0/24"]
    service_endpoints = ["Microsoft.Storage"]
  }
]

