# Variable para el AMI de la instancia EC2
variable "ec2_ami" {
  description = "AMI ID de la instancia EC2"
  type        = string
}

# Variable para el tipo de instancia EC2
variable "ec2_instance_type" {
  description = "El tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

# Variable para los IDs de los grupos de seguridad de la instancia EC2
variable "ec2_security_group_ids" {
  description = "Lista de IDs de los grupos de seguridad para la instancia EC2"
  type        = list(string)
}

variable "ec2_subnet_id" {
  description = "ID de la subred donde se lanzará la instancia EC2"
  type        = string
}

# Variable para el nombre del tag de la instancia EC2
variable "ec2_instance_name" {
  description = "Nombre del tag para la instancia EC2"
  type        = string
  default     = "infralabs_ec2"
}

# Variable para el script de configuración inicial (user_data)
variable "ec2_user_data" {
  description = "Script de configuración inicial para la instancia EC2"
  type        = string
  default     = <<-EOF
                  #!/bin/bash
                  echo "Hola Grupo de Terraformers!" > index.html
                  nohup busybox httpd -f -p 8080 &
                EOF
}

# Variable para el nombre del grupo de seguridad principal de EC2
variable "ec2_main_security_group_name" {
  description = "Nombre del grupo de seguridad principal para EC2"
  type        = string
  default     = "primer-servidor-infra"
}

# Variable para el nombre del firewall adicional de EC2
variable "ec2_firewall_security_group_name" {
  description = "Nombre del firewall de seguridad adicional para EC2"
  type        = string
  default     = "firewall-servidor-infra"
}


# Variable para el nombre del par de claves (Key Pair)
variable "ec2_key_name" {
  description = "Nombre del par de claves para acceder a la instancia EC2"
  type        = string
}
