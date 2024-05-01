variable "region" {
  type    = string
  default = "us-east-1"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "Private Subnet"
  default     = "10.0.2.0/24"
}

variable "azs" {
  type        = string
  description = "Availability Zone"
  default     = "us-east-1a"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "ami" {
  type    = string
  default = "ami-041feb57c611358bd"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
