variable "region" {
  type    = string
  default = "us-east-1"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "azs" {
  type        = string
  description = "Availability Zones"
  default     = "us-east-1a"
}

variable "adres" {
  type        = string
  description = "URL Cloudfront"
  default     = "########" #<< ENTER YOUR URL
}

variable "greeting" {
  type        = string
  description = "URL Cloudfront"
  default     = "greeting.#########" #<< ENTER YOUR URL
}

variable "cogdomain" {
  type        = string
  description = "Cognito domain name"
  default     = "project8-serverless-app"
}

variable "webapp_files" {
  default     = ["script.js", "index.html", "login.html", "logout.html"]
  description = "Webapp files"
}
variable "bucket" {
  type = string
}