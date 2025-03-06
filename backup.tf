/**
 * Copyright 2025 Taito United
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# TODO: make this configurable
resource "google_gke_backup_backup_plan" "backup_plan" {
  count    = coalesce(local.kubernetes.gkeBackupAgentConfig, false) ? 1 : 0

  name     = module.kubernetes.name
  cluster  = module.kubernetes.cluster_id
  location = local.kubernetes.region

  retention_policy {
    backup_delete_lock_days = 30
    backup_retain_days = 60
  }

  backup_schedule {
    rpo_config {
      target_rpo_minutes=1440
    }
  }

  backup_config {
    include_volume_data = false
    include_secrets = true
    all_namespaces = true
    permissive_mode = true
  }
}