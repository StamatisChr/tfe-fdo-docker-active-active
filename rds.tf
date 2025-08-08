resource "aws_db_instance" "tfe_postgres" {
  identifier             = "tfe-postgres"
  engine                 = "postgres"
  engine_version         = "14.17"
  instance_class         = var.db_instance_class
  allocated_storage      = 50
  storage_type           = "gp3"
  username               = var.tfe_database_user
  db_name                = var.tfe_database_name
  password               = var.tfe_database_password
  vpc_security_group_ids = [aws_security_group.tfe_sg.id]
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = {
    Name = "stam-${random_pet.hostname_suffix.id}"
  }
}