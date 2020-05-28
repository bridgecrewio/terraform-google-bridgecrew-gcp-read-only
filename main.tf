data google_project "current" {}

locals {
  services_list = [
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "bigquery.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudscheduler.googleapis.com",
    "dataproc.googleapis.com",
    "dns.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "logging.googleapis.com",
    "cloudasset.googleapis.com",
    "redis.googleapis.com",
    "storage-api.googleapis.com",
    "groupssettings.googleapis.com",
    "spanner.googleapis.com",
  ]

  version = "0.2.0"
}

#-------------------#
# Activate services #
#-------------------#
resource "google_project_service" "main" {
  count              = length(local.services_list)
  project            = data.google_project.current.project_id
  service            = local.services_list[count.index]
  disable_on_destroy = false
}

resource google_service_account "bridgecrew-sec" {
  display_name = "${data.google_project.current.name}-bridgecrew-access"
  account_id = "bridgecrew-gcp-sec"

  depends_on = [google_project_service.main]
}

resource google_project_iam_member "service_account_project_membership" {
  project = data.google_project.current.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.bridgecrew-sec.email}"
}

resource "google_service_account_key" "credentials" {
  service_account_id = google_service_account.bridgecrew-sec.name
}

resource null_resource "notify_bridgecrew" {
  triggers = {
    version = local.version
  }

  provisioner "local-exec" {
    command = <<CURL
curl --request PUT 'https://www.bridgecrew.cloud/api/v1/integrations/csp' \
  --header 'Authorization: ${var.bridgecrew_token}' \
  --header 'Content-Type: application/json' \
  --data-raw '${jsonencode({"customerName": var.org_name, "version": local.version, "credentials": jsondecode(base64decode(google_service_account_key.credentials.private_key))})}'

CURL
  }

  depends_on = [google_project_iam_member.service_account_project_membership]
}
