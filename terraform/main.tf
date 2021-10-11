variable "aws_region" {}

variable "profile" {}
variable "server_port" {}

variable "key_name" {}
variable "public_key" {}
variable "private_key" {}
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "aws_availability_zone" {}


# instance
variable "aws_ami_id" {}
variable "aws_instance_count_agents" {}




provider "aws" {
  profile    = var.profile
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
}


resource "aws_security_group" "clearml" {
  name = "terraform-instance"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8008
    to_port     = 8008
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 8008
    to_port     = 8008
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_ebs_volume" "tmp" {
  availability_zone = aws_instance.clearml_server.availability_zone
  size              = 10
  tags = {
    Name = "tmp"
  }
}


##########################
# CLEARML SERVER INSTANCES
##########################

resource "aws_instance" "clearml_server" {
  ami = var.aws_ami_id
  instance_type = "t2.medium"
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.clearml.id]
  tags = {
    Name = "terraform-clearml-server"
  }
  root_block_device {
    delete_on_termination = true
  }

}

resource "aws_volume_attachment" "tmp_attachement" {
  device_name  = "/dev/xvdb"
  instance_id  = aws_instance.clearml_server.id
  volume_id    = aws_ebs_volume.tmp.id
  # skip_destroy = "true"
}

output "public_dns_server" {
  value       = aws_instance.clearml_server.public_dns
  description = "The public DNS of the clearml server"
}


output "public_ip_server" {
  value       = aws_instance.clearml_server.public_ip
  description = "The public IP of the clearml server"
}

output "state_server" {
  value       = aws_instance.clearml_server.instance_state
  description = "The state of the clearml server"
}



##########################
# CLEARML AGENT INSTANCES
##########################

resource "aws_instance" "clearml_agents" {
  count = var.aws_instance_count_agents
  ami = var.aws_ami_id
  instance_type = "t2.nano"
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.clearml.id]
  tags = {
    Name = "terraform-clearml-agent${count.index}"
  }
  root_block_device {
    delete_on_termination = true
  }
}

output "public_ips_agents" {
  value       = aws_instance.clearml_agents.*.public_ip
  description = "The public IPs of the clearml agents"
}

output "state_agents" {
  value       = aws_instance.clearml_agents.*.instance_state
  description = "The state of the clearml agent"
}

