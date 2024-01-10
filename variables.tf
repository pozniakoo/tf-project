variable "region" {
  type    = string
  default = "us-east-1"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDRs"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zone"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ami" {
  type    = string
  default = "ami-0dbc3d7bc646e8516"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "access_key" {
  type    = string
  default = ""
}

variable "secret_key" {
  type    = string
  default = ""
}