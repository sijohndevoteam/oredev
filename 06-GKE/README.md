# GKE Hosting of a eCommerce App (Microservices)
# Remove your local lock file!
rm .terraform.lock.hcl

# And then -
brew install kreuzwerker/taps/m1-terraform-provider-helper
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0
terraform init

Updating after clearing
From Workstation