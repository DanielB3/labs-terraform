# Configuración del backend para almacenar el estado de Terraform en un bucket de S3

terraform {
  backend "s3" {
    bucket  = "infralabs-bucket"         # Nombre del bucket de S3
    key     = "folder/tfstate-rds.tf"        # Clave del archivo en el bucket que contiene el estado de Terraform
    region  = "us-east-1"                # Región donde se encuentra el bucket
    encrypt = true                       # Habilita la encriptación del archivo de estado
  }
}

# Configuración del proveedor AWS, especificando el perfil y la región

provider "aws" {
#profile = "default"                    # Perfil de AWS utilizado
  region  = "us-east-1"                  # Región de AWS para desplegar los recursos
  alias   = "rds"
}

# Genera una cadena aleatoria que se usará como contraseña de la base de datos
resource "random_string" "db-password" {
  length  = 32                           # Longitud de la cadena
  upper   = true                         # Incluir letras mayúsculas
  numeric = true                         # Incluir números
  special = false                        # No incluir caracteres especiales
}

# Crea un grupo de seguridad en AWS para la instancia RDS

resource "aws_security_group" "infralabs" {
  provider    = aws.rds
  vpc_id      = var.vpc                  # ID de la VPC donde se crea el grupo de seguridad
  name        = var.security_group       # Nombre del grupo de seguridad
  description = "Allow all inbound for Postgres infralabs"  # Descripción del grupo

  ingress {
    from_port   = 5432                   # Puerto inicial del rango permitido para el tráfico entrante
    to_port     = 5432                   # Puerto final del rango permitido para el tráfico entrante
    protocol    = "tcp"                  # Protocolo permitido
    cidr_blocks = ["0.0.0.0/0"]          # Bloques CIDR desde donde se permite el tráfico
  }

 ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Cambia esto si solo quieres permitir acceso desde ciertas IPs o subredes
  }

 egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Permitir todo el tráfico saliente
  }
}

# Define un grupo de subredes de DB en AWS que especifica en qué subredes debe operar la RDS
resource "aws_db_subnet_group" "infralabs" {
  provider   = aws.rds
  name       = "te-infralabs"            # Nombre del grupo de subredes
  subnet_ids = [var.subnet1, var.subnet2]  # IDs de las subredes asignadas al grupo

  tags = {
    Name = "My DB subnet group"          # Etiqueta asignada al grupo de subredes
  }
}

# Crea una instancia de base de datos en AWS RDS
resource "aws_db_instance" "infralabs" {
  provider               = aws.rds  # Usar el alias del proveedor
  identifier             = var.db-instance-id  # Identificador único para la instancia de base de datos
  db_name                = var.db_name         # Nombre de la base de datos
  instance_class         = var.db_instance_type  # Tipo de instancia (por ejemplo, db.t2.micro)
  allocated_storage      = var.db_instance_storage  # Espacio de almacenamiento asignado
  engine                 = var.db_instance_engine  # Motor de base de datos (por ejemplo, postgres)
  engine_version         = var.db_instance_engine_version  # Versión del motor
  skip_final_snapshot    = var.db_instance_skip_final_snapshot  # Si se debe omitir el snapshot final al eliminar la instancia
  publicly_accessible    = var.db_instance_publicly_accessible  # Si la instancia será accesible públicamente
  vpc_security_group_ids = [aws_security_group.infralabs.id]  # ID del grupo de seguridad asignado
  username               = var.db_username  # Nombre de usuario del administrador de la base de datos
  password               = var.db_password  # Contraseña de la base de datos
  db_subnet_group_name   = aws_db_subnet_group.infralabs.name  # Nombre del grupo de subredes asignado
  multi_az               = true
}
