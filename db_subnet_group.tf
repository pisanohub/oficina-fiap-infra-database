resource "aws_db_subnet_group" "oficina_fiap" {
  name       = "oficina-fiap-db-subnet-group"
  subnet_ids = slice(data.aws_subnets.default.ids, 0, 2)

  tags = {
    Name = "oficina-fiap-db-subnet-group"
  }
}
