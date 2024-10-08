resource "random_password" "password" {
  length      = 16
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  special     = false
}

resource "aws_security_group" "rds_sg" {
  name = "${var.name}-sg"

  description = "Security group for RDS instance ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ${upper(var.engine)} traffic from only the API Security Group"
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [var.sg_ec2_id]
  }

  tags = {
    Name        = "${var.name}-sg"
    Environment = var.env
    Terraform   = "true"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  subnet_ids = var.vpc_private_subnets

  tags = {
    Name        = var.name
    Environment = var.env
    Terraform   = "true"
  }
}

#tfsec:ignore:AVD-AWS-0176
#tfsec:ignore:AVD-AWS-0177
#tfsec:ignore:aws-rds-enable-performance-insights
resource "aws_db_instance" "rds" {
  allocated_storage       = 10
  db_name                 = replace(var.name, "-", "_")
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  username                = local.db_username
  password                = random_password.password.result
  parameter_group_name    = "default.${var.engine}${var.engine_version}"
  skip_final_snapshot     = true
  storage_encrypted       = true
  multi_az                = false
  kms_key_id              = var.kms_key_arn
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  backup_retention_period = 7

  tags = {
    Name        = var.name
    Environment = var.env
    Terraform   = "true"
  }
}