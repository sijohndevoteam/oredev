# This module creates a Google Cloud Storage bucket that can be used to host a static website.
# That is, the website can contain static HTML, CSS, JS, and images.
provider "google" {
  project = var.project
}

resource "google_storage_bucket" "website_bucket" {
  name = var.bucket_name
  location = var.location
  website {
    main_page_suffix = "index.html"
	not_found_page = "404.html"
  }
}

# Upload a simple index.html page to the bucket
resource "google_storage_bucket_object" "indexpage" {
  name         = "index.html"
  source = "${path.module}/src/index.html"
  content_type = "text/html"
  bucket       = google_storage_bucket.website_bucket.id
}
resource "google_storage_bucket_object" "indexpage_image" {
  name         = "Devoteam.png"
  source = "${path.module}/src/Devoteam.png"
  content_type = "image/png"
  bucket       = google_storage_bucket.website_bucket.id
}

# Upload a simple 404 / error page to the bucket
resource "google_storage_bucket_object" "errorpage" {
  name         = "404.html"
  content      = "<html><body>404!</body></html>"
  content_type = "text/html"
  bucket       = google_storage_bucket.website_bucket.id
}

resource "google_storage_bucket_access_control" "public_access" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "READER"
  entity = "allUsers"
}
output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.website_bucket.name}/index.html"
}