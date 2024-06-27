# variables.tf
variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string  
}

variable "region" {
  description = "AWS region"
  type        = string
}

