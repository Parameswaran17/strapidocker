resource "random_string" "sg_suffix" {
  length  = 6  # Adjust the length as needed for uniqueness
  special = false
  upper   = false
}

resource "aws_instance" "strapi_instance" {
  ami           = var.ami
  instance_type = "t2.medium"
  key_name      = "paramesh-key-pair-strapi"
  security_groups = [aws_security_group.strapi_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "Paramesh-Strapi-Instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
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
      private_key = var.ec2_private_key
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
