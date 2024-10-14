/**
 * Copyright 2024 Taito United
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

resource "google_artifact_registry_repository" "container-registry" {
  count         = var.create_registry ? 1 : 0

  project       = var.project_id
  location      = local.kubernetes.region
  repository_id = "container-registry"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }

  /* TODO: How to avoid current production release being deleted when enough dev versions have been released -> We should tag prod releases?
  cleanup_policies {
    id = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count            = 10
    }
  }
  */

}