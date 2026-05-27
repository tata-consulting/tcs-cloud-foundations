variable "name_prefix" {
  description = "Prefix applied to shared landing zone resources."
  type        = string
}

variable "environment" {
  description = "Environment name for the landing zone."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to resources."
  type        = map(string)
  default     = {}
}
