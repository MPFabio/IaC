resource "google_storage_bucket" "bucket" {
  name                     = var.bucket_name
  project                  = var.project_id
  location                 = var.location
  storage_class            = var.storage_class
  force_destroy            = var.force_destroy
  public_access_prevention = "enforced"

  versioning {
    enabled = var.enable_versioning
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action_type
        storage_class = lookup(lifecycle_rule.value, "storage_class", null)
      }
      condition {
        age                   = lookup(lifecycle_rule.value, "age", null)
        num_newer_versions    = lookup(lifecycle_rule.value, "num_newer_versions", null)
        with_state            = lookup(lifecycle_rule.value, "with_state", null)
        matches_storage_class = lookup(lifecycle_rule.value, "matches_storage_class", null)
      }
    }
  }

  labels = {
    environment = var.environment
  }

  uniform_bucket_level_access = true
}
