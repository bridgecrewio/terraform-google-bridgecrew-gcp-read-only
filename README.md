# Bridgecrew GCP READ ONLY Integration
Implementing this module allows visibility to your project on [Bridgecrew Cloud](https://www.bridgecrew.cloud).

## Module contents
This module enables the APIs that allow us to have visibility into your Google Project
and creates a service account for us to scan that project for misconfigurations.

## Configuration
To run this module, supply the name of the company as registered in [Bridgecrew Cloud](https://www.bridgecrew.cloud) as such:
```hcl-terraform
module "bridgecrew-read-only" {
  source        = "bridgecrewio/read-only/google"
  customer_name = "acme"
}
```