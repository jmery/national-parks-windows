////////////////////////////////
// GCP Variables
variable "gcp_credentials_file" {}

variable "gcp_project" {}

variable "gcp_region" {
  default = "australia-southeast1"
  description = "Region List: https://cloud.google.com/compute/docs/regions-zones/"
}

variable "ssh_username" {}

variable "ssh_user_public_key" {}

variable "ssh_user_private_key" {}

variable "gcp_machine_type" {
  default = "n1-standard-4"
  description = "https://cloud.google.com/compute/docs/machine-types"
}

variable "win_admin_pwd" {}

variable "win_hab_pwd" {}

////////////////////////////////
// Required Labels (aka Tags)
// lower-case, numbers, underscores, or dashes only
variable "label_customer" {}

variable "label_project" {}

variable "label_dept" {}

variable "label_contact" {}

variable "label_application" {}

variable "label_ttl" {
  default = 4
}

////////////////////////////////
// Habitat

variable "audit_origin" {
  default = "effortless"
}

variable "config_origin" {
  default = "effortless"
}

variable "national_parks_origin" {}

variable "hab_group" {
  default = "default"
}

variable "hab_prod_channel" {
  default = "stable"
}

variable "hab_update_strategy" {
  default = "at-once"
}
