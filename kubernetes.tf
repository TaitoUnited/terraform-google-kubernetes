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

module "kubernetes" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version = "12.0.0"

  project_id                     = var.project_id
  name                           = local.kubernetes.name
  region                         = local.kubernetes.region
  regional                       = local.kubernetes.regional
  zones                          = local.kubernetes.zones
  network                        = var.network
  subnetwork                     = var.subnetwork
  ip_range_pods                  = var.pods_ip_range_name
  ip_range_services              = var.services_ip_range_name
  # compute_engine_service_account = var.compute_engine_service_account
  master_ipv4_cidr_block         = local.kubernetes_master_cidr

  master_authorized_networks = [
    for cidr in local.kubernetes.masterAuthorizedNetworks:
    {
      cidr_block   = cidr
      display_name = cidr
    }
  ]

  database_encryption = [{
    state    = local.kubernetes.dbEncryptionEnabled ? "ENCRYPTED" : "DECRYPTED"
    key_name = (
      local.kubernetes.dbEncryptionEnabled
        ? google_kms_crypto_key.kubernetes_key[0].self_link
        : ""
    )
  }]

  create_service_account          = true
  grant_registry_access           = true
  registry_project_id             = (
                                      local.kubernetes.registryProjectId != ""
                                        ? local.kubernetes.registryProjectId
                                        : var.project_id
                                    )

  add_cluster_firewall_rules      = local.kubernetes.clusterFirewallRulesEnabled
  enable_private_endpoint         = local.kubernetes.masterPrivateEndpointEnabled
  master_global_access_enabled    = local.kubernetes.masterGlobalAccessEnabled
  enable_private_nodes            = local.kubernetes.privateNodesEnabled
  network_policy                  = local.kubernetes.networkPolicyEnabled
  # network_policy_provider         = "CALICO"
  enable_shielded_nodes           = local.kubernetes.shieldedNodesEnabled
  # sandbox_enabled                 = local.kubernetes.sandboxEnabled
  enable_vertical_pod_autoscaling = local.kubernetes.verticalPodAutoscalingEnabled
  horizontal_pod_autoscaling      = true
  http_load_balancing             = true
  dns_cache                       = local.kubernetes.dnsCacheEnabled
  gce_pd_csi_driver               = local.kubernetes.pdCsiDriverEnabled

  resource_usage_export_dataset_id   = local.kubernetes.resourceConsumptionExportDatasetId
  enable_resource_consumption_export = local.kubernetes.resourceConsumptionExportEnabled
  enable_network_egress_export    = local.kubernetes.networkEgressExportEnabled
  enable_binary_authorization     = local.kubernetes.binaryAuthorizationEnabled
  enable_intranode_visibility     = local.kubernetes.intranodeVisibilityEnabled

  logging_service                 = "logging.googleapis.com/kubernetes"
  monitoring_service              = "monitoring.googleapis.com/kubernetes"

  config_connector                = local.kubernetes.configConnectorEnabled
  istio                           = local.kubernetes.istio.enabled
  cloudrun                        = local.kubernetes.knative.enabled

  # Enable G Suite groups for access control
  authenticator_security_group    = local.kubernetes.authenticatorSecurityGroup

  enable_pod_security_policy      = local.kubernetes.podSecurityPolicyEnabled

  kubernetes_version        = null
  release_channel           = local.kubernetes.releaseChannel
  maintenance_start_time    = local.kubernetes.maintenanceStartTime

  node_metadata             = "GKE_METADATA_SERVER"

  identity_namespace        = "enabled"

  # TODO: Cluster autoscaling configuration (defaults are ok?)
  # cluster_autoscaling     = map

  remove_default_node_pool  = true
  # initial_node_count        = 1

  node_pools = [
    for nodePool in local.kubernetes.nodePools:
    {
      name                  = nodePool.name
      # service_account     = var.compute_engine_service_account
      node_locations        = nodePool.locations

      node_count            = (
        nodePool.minNodeCount == nodePool.maxNodeCount
        ? nodePool.minNodeCount
        : null
      )
      autoscaling           = nodePool.minNodeCount != nodePool.maxNodeCount
      initial_node_count    = nodePool.minNodeCount
      min_count             = nodePool.minNodeCount
      max_count             = nodePool.maxNodeCount

      auto_repair           = true
      auto_upgrade          = true
      disk_size_gb          = nodePool.diskSizeGb

      image_type            = "COS_CONTAINERD"
      machine_type          = nodePool.machineType
      accelerator_type      = nodePool.acceleratorType
      accelerator_count     = nodePool.acceleratorCount

      enable_secure_boot    = nodePool.secureBootEnabled
      enable_integrity_monitoring = true
    }
  ]

  # TODO: prevent destroy -> https://github.com/hashicorp/terraform/issues/18367
}
