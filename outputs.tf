output "service_account" {
  value = google_service_account.bridgecrew-sec
}

output "project_membership" {
  value = google_project_iam_member.service_account_project_membership
}
