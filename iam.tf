
resource "google_service_account" "bridgecrew-sec" {
  display_name = "${data.google_project.current.name}-bridgecrew-access"
  account_id   = "bridgecrew-gcp-sec"
  project      = data.google_project.current.project_id

  depends_on = [google_project_service.main]
}

resource "google_project_iam_member" "service_account_project_membership" {
  project = data.google_project.current.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.bridgecrew-sec.email}"
}

resource "google_service_account_key" "credentials" {
  service_account_id = google_service_account.bridgecrew-sec.name
}
