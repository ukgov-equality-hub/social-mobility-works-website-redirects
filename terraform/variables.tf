
variable "service_name" {
  type = string
  description = "The short name of the service."
  default = "smw_redirect"
}

variable "service_name_hyphens" {
  type = string
  description = "The short name of the service (using hyphen-style)."
  default = "smw-redirect"
}

variable "aws_region" {
  type = string
  description = "The AWS region used for the provider and resources."
  default = "eu-west-2"
}
