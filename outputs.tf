output "db_endpoint" {
  description = "Endereco de conexao do banco de dados"
  value       = aws_db_instance.oficina_fiap.endpoint
}

output "db_name" {
  description = "Nome do banco de dados criado"
  value       = aws_db_instance.oficina_fiap.db_name
}
