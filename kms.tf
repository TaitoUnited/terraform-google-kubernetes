/**
 * Copyright 2020 Taito United
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

resource "google_kms_key_ring" "key_ring" {
  count      = try(local.kubernetes.dbEncryptionEnabled, false) ? 1 : 0
  name       = "${local.kubernetes.name}-key-ring"
  project    = data.google_project.project.project_id
  location   = local.kubernetes.region
}

resource "google_kms_crypto_key" "kubernetes_key" {
  count           = (try(local.kubernetes.dbEncryptionEnabled, false) ? 1 : 0) * (try(local.kubernetes.name, "") != "" ? 1 : 0)
  name            = "${local.kubernetes.name}-key"
  key_ring        = google_kms_key_ring.key_ring[0].self_link
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_key_ring_iam_member" "kms_encrypter" {
  count       = try(local.kubernetes.dbEncryptionEnabled, false) ? 1 : 0
  key_ring_id = google_kms_key_ring.key_ring[0].self_link
  role        = "roles/cloudkms.cryptoKeyEncrypter"

  member = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_key_ring_iam_member" "kms_decrypter" {
  count       = try(local.kubernetes.dbEncryptionEnabled, false) ? 1 : 0
  key_ring_id = google_kms_key_ring.key_ring[0].self_link
  role        = "roles/cloudkms.cryptoKeyDecrypter"

  member = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}
