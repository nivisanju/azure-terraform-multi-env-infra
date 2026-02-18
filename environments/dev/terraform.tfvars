subnets = [
  {
    name              = "app-subnet"
    address_prefixes  = ["10.10.1.0/24"]
    service_endpoints = ["Microsoft.Storage"]
    nsg_rules = [
      {
        name                       = "AllowSSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTP"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTPS"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        source_port_range          = "*"
        protocol                   = "Tcp"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  },
  {
    name              = "data-subnet"
    address_prefixes  = ["10.10.2.0/24"]
    service_endpoints = ["Microsoft.Storage"]
  }
]



subscription_id   = "6a86f866-946c-4313-8eab-219a3df8acfd"
tenant_id         = "773fd5cb-c4ae-4eda-9357-43e4adc8665f"
vm_size           = "Standard_D2s_v3"
vm_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKgiaLwi83t3csbVrPD9sX3/Z9UAqHRM7sc9fIel802txzkU2iMv33/JAYr3jbCbOByHHTbCKtZ8qMs0RHOALngS7n825BoxFYiH7+N/+AYbTtjKYeoHcVrx1oWJaPdp783+cNrkN190PmI/Isz2d8rfncDrVwk/nswQaYXzY4yBL4WqceQFubtaWYuQiOh7EVmy1EbC5Ya66O5Nh/Y4qBOt+Fo2PHCENbdJIfergAAhgpYukAABYRxTcixS3bJFFHlOxaSx1JRdskJZa+dFRKmbF+/p4XCOnjPClrNuL/De8MkCGPh4jMxMwFhnEOEguXFxZ3BS+aTPMd0kMwkKCtZEnEmPlaOzqx/BDYXKH/FJvNYu1uD8CAHeYVZpufmC6VQ0CUCuEwbUqxieyJ8R/G/LhlDwZb/7bZfAMDmiAJTqhMUJ/BA6/9EQsJyX6yhtSudeggrqpJx1Hu95FfyS7RbxO+8Smy+nLXcwlYVpP2MMiWGqJ9T3KxzfD3n2dVqi0wITnI2v7JLiW0T4rfGrYzsG6+urfNT/70m3RODYCowd9MMVg28ZVhfKURyV2hcV1MGZ9RBTJH4pKHnGP1kWRBYnZXZayHgaVM0+x7EsgytmTTmZyh8iyOTUzIjANeDoS8fxfYa2pypX9IV3/o+LUVElRdEn2NiBWFwydXdD3cvQ== azure-vm"