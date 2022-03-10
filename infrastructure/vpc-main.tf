resource "aws_vpc" "vault_demo" {
  cidr_block       = var.vault_demo_vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.vault_demo_vpc_name
  }
}


