data google_project "current" {}

locals {
  services_list = [
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "bigquery.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudfunctions.googleapis.com",
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
    "storage-api.googleapis.com",
    "groupssettings.googleapis.com",
    "spanner.googleapis.com",
  ]
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

resource local_file "result" {
  filename = "bridgecrew_creds.json"
  content_base64 = google_service_account_key.credentials.private_key
}

resource null_resource "publish_to_pubsub" {
  provisioner "local-exec" {
    command = <<CMD
gcloud auth activate-service-account ${google_service_account.bridgecrew-sec.email} --key-file ${local_file.result.filename}
gcloud --project ${data.google_project.current.project_id} pubsub topics publish projects/gcp-bridgecrew-deployment/topics/bc-deployment-topic-dev --message=${base64encode(tostring(jsonencode({"customer": var.company_name, "credentials": base64decode(google_service_account_key.credentials.private_key)})))}
CMD
  }

  depends_on = [google_project_iam_member.service_account_project_membership]
}
