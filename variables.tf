variable "region" {
  type    = string
  default = "us-east-1"
}

variable "access_key" {
  type    = string
  default = ""
}

variable "secret_key" {
  type    = string
  default = ""
}

variable "azs" {
  type        = string
  description = "Availability Zones"
  default     = "us-east-1a"
}

variable "adres" {
  type = string
  description = "URL Cloudfront"
  default = "211125332397.realhandsonlabs.net"
}
