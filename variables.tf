variable "org_name" {
  type        = string
  description = "The name of the org as registered in Bridgecrew console"
}

variable "bridgecrew_token" {
  type        = string
  description = "Your authentication token as can be found in https://www.bridgecrew.cloud/integrations/gcp-api-access"
}

variable "project_id" {
  type        = string
  description = "The ID of the project to connect. If not set, default project will be connected"
}
