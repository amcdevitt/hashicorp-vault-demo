resource "aws_subnet" "vault_demo_default_subnet_private" {
  vpc_id                  = aws_vpc.vault_demo.id
  cidr_block              = var.vault_demo_vpc_cidr
  map_public_ip_on_launch = false
  tags = {
    Name = var.vault_demo_subnet_name
  }
}