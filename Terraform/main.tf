provider "aws" {
  region = "eu-west-2"  # Adjust to your desired region
}

# Data source to fetch the latest Ubuntu 22.04 AMI
data "aws_ami" "latest_ubuntu_22_04" {
  most_recent = true

  owners = ["099720109477"]  # Ubuntu's owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Data source to fetch the SSH key pair
data "aws_key_pair" "my_key" {
  key_name = var.key_name
}

resource "random_string" "sg_suffix" {
  length  = 6  # Adjust the length as needed for uniqueness
  special = false
  upper   = false
}

resource "aws_instance" "strapi_instance" {
  ami           = data.aws_ami.latest_ubuntu_22_04.id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.strapi_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "Paramesh-Strapi-Instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nodejs npm git",
      "sudo npm install -g strapi",
      "git clone https://github.com/Parameswaran17/strapidocker.git .",  # Clone repository into current directory
      "cd /home/ubuntu/strapidocker",
      "sudo apt-get install -y docker.io", 
      "sudo usermod -aG docker ubuntu",     
      "sudo systemctl enable docker",    
      "sudo systemctl start docker",     
      "sudo docker pull parameswaran17/docker_image:latest",  
      "sudo docker run -d -p 1337:1337 --name my_strapi parameswaran17/docker_image:latest" 
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-security-group2-${random_string.sg_suffix.result}"
  description = "Security group for Strapi EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Paramesh Security Group"
  }
}
