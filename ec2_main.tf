# -------------------------
# Define el provider de AWS
# -------------------------
provider "aws" {
  region = "us-east-1"
#profile    = "default"
  alias   = "ec2"

}

# ----------------------------------------------------
# Data Source para obtener el ID de la VPC por defecto
# ----------------------------------------------------
data "aws_vpc" "default" {
  default = true
}


# ---------------------------------------
# Define una instancia EC2 con AMI Ubuntu
# ---------------------------------------


resource "aws_instance" "infralabs_servidor" {
  provider               = aws.ec2
  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  subnet_id              = var.ec2_subnet_id
  vpc_security_group_ids = var.ec2_security_group_ids
  key_name               = var.ec2_key_name

  associate_public_ip_address = true  # Añadir esta línea para asociar una IP pública

  tags = {
    Name = var.ec2_instance_name
  }

  user_data = var.ec2_user_data
}

# ------------------------------------------------------
# Define un grupo de seguridad con acceso al puerto 8080
# ------------------------------------------------------

resource "aws_security_group" "grupo_de_seguridad_infra" {
  provider  = aws.ec2
  name      = var.ec2_main_security_group_name
  vpc_id    = data.aws_vpc.default.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 8080 desde el exterior"
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 3306 para MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Permitir todo el tráfico saliente
  }
}


resource "aws_security_group" "firewall_de_seguridad_infra" {
  provider  = aws.ec2
  name      = var.ec2_firewall_security_group_name
  vpc_id    = data.aws_vpc.default.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 80 desde el exterior"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
  }
}