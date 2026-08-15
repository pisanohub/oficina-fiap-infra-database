variable "aws_region" {
  description = "Regiao da AWS. O AWS Academy Learner Lab so permite us-east-1 ou us-west-2."
  type        = string
  default     = "us-east-1"
}

variable "db_instance_class" {
  description = "Classe da instancia RDS."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento alocado para o banco, em GB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Nome do banco de dados inicial criado dentro da instancia RDS."
  type        = string
  default     = "oficina"
}

variable "db_username" {
  description = "Usuario master do banco."
  type        = string
  default     = "oficina_admin"
}

variable "db_password" {
  description = "Senha do usuario master do banco."
  type        = string
  sensitive   = true
}
