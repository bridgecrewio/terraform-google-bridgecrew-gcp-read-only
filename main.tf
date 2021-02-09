data "google_project" "current" {
  project_id = var.project_id
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

resource "null_resource" "notify_bridgecrew" {
  triggers = {
    version = local.version
  }

  provisioner "local-exec" {
    command = <<CURL
curl --request PUT 'https://www.bridgecrew.cloud/api/v1/integrations/csp' \
  --header 'Authorization: ${var.bridgecrew_token}' \
  --header 'Content-Type: application/json' \
  --data-raw '${jsonencode({ "customerName" : var.org_name, "version" : local.version, "credentials" : jsondecode(base64decode(google_service_account_key.credentials.private_key)) })}'

CURL
  }

  depends_on = [google_project_iam_member.service_account_project_membership]
}
