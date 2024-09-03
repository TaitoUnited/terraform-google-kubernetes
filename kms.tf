/**
 * Copyright 2021 Taito United
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
  count      = coalesce(local.kubernetes.dbEncryptionEnabled, false) ? 1 : 0
  name       = "${local.kubernetes.name}-key-ring"
  project    = var.project_id
  location   = local.kubernetes.region
}

resource "google_kms_crypto_key" "kubernetes_key" {
  count           = (coalesce(local.kubernetes.dbEncryptionEnabled, false) ? 1 : 0) * (local.kubernetes.name != null ? 1 : 0)
  name            = "${local.kubernetes.name}-key"
  key_ring        = google_kms_key_ring.key_ring[0].id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_key_ring_iam_member" "kms_encrypter" {
  count       = coalesce(local.kubernetes.dbEncryptionEnabled, false) ? 1 : 0
  key_ring_id = google_kms_key_ring.key_ring[0].id
  role        = "roles/cloudkms.cryptoKeyEncrypter"

  member = "serviceAccount:service-${var.project_number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_key_ring_iam_member" "kms_decrypter" {
  count       = coalesce(local.kubernetes.dbEncryptionEnabled, false) ? 1 : 0
  key_ring_id = google_kms_key_ring.key_ring[0].id
  role        = "roles/cloudkms.cryptoKeyDecrypter"

  member = "serviceAccount:service-${var.project_number}@container-engine-robot.iam.gserviceaccount.com"
}
