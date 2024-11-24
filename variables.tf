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

variable "project_id" {
  type        = string
}

variable "project_number" {
  type        = string
}

variable "email" {
  type        = string
  description = "DevOps support email"
}

variable "network" {
  type        = string
  default     = ""
  description = "Kubernetes network"
}

variable "subnetwork" {
  type        = string
  default     = ""
  description = "Kubernetes subnetwork"
}

variable "pods_ip_range_name" {
  type        = string
  default     = ""
  description = "Kubernetes ip range pods"
}

variable "services_ip_range_name" {
  type        = string
  default     = ""
  description = "Kubernetes ip range services"
}

variable "create_registry" {
  type        = bool
  default     = "true"
  description = "Creates a container registry."
}

variable "grant_registry_access" {
  type        = bool
  default     = "false"
  description = "Grants registry access. If you have problems with this, set it to true only after Kubernetes cluster already exists."
}

variable "kubernetes" {
  type = object({
    name = string
    context = string
    releaseChannel = string
    maintenanceStartTime = string
    registryProjectId = string
    authenticatorSecurityGroup = string
    addClusterFirewallRules = bool
    enablePrivateEndpoint = bool
    deployUsingPrivateEndpoint = bool
    masterGlobalAccessEnabled = bool
    enablePrivateNodes = bool
    enableShieldedNodes = bool
    enableConfidentialNodes = bool
    sandboxEnabled = bool
    securityPostureMode = string
    securityPostureVulnerabilityMode = string
    workloadVulnerabilityMode = string
    networkPolicy = bool
    enableFqdnNetworkPolicy = bool
    enableCiliumClusterwideNetworkPolicy = bool
    datapathProvider = string
    dbEncryptionEnabled = bool
    enableVerticalPodAutoscaling = bool
    dnsCache = bool
    gatewayApiChannel = string
    gcePdCsiDriver = bool
    gcsFuseCsiDriver = bool
    filestoreCsiDriver = bool
    enableResourceConsumptionExport = bool
    resourceUsageExportDatasetId = string
    enableNetworkEgressExport = bool
    enableBinaryAuthorization = bool
    enableIntranodeVisibility = bool
    configConnector = bool
    monitoringEnableManagedPrometheus = bool
    gkeBackupAgentConfig = bool
    region = string
    regional = bool
    zones = list(string)
    
    masterAuthorizedNetworks = list(string)
    masterIpv4CidrBlock = string

    nodePools = list(object({
      name = string
      machineType = string
      acceleratorType = string
      acceleratorCount = number
      secureBootEnabled = bool
      diskSizeGb = number
      locations = string
      minNodeCount = number
      maxNodeCount = number
    }))
    ingressNginxControllers = list(object({
      name = string
      class = string
      replicas = number
      metricsEnabled = bool
      maxmindLicenseKey = string
      configMap = map(string)
      tcpServices = map(string)
      udpServices = map(string)
    }))
    certManager = object({
      enabled = bool
    })
  })
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "permissions" {
  type = object({
    clusterRoles = list(object({
      name = string
      subjects = list(string)
    }))
    namespaces = list(object({
      name = string
      clusterRoles = list(object({
        name = string
        subjects = list(string)
      }))
    }))
  })
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

# Helm infrastructure apps

variable "helm_enabled" {
  type        = bool
  default     = "false"
  description = "Installs helm apps if set to true. Should be set to true only after Kubernetes cluster already exists."
}

variable "generate_ingress_dhparam" {
  type        = bool
  description = "Generate Diffie-Hellman key for ingress"
}

variable "use_kubernetes_as_db_proxy" {
  type        = bool
  default     = false
}

variable "postgresql_cluster_names" {
  type        = list(string)
  default     = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "mysql_cluster_names" {
  type        = list(string)
  default     = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

# Helm app versions

# NOTE: Remember to update also helm_apps.tf
# TODO: Should be optional and null by default
variable "ingress_nginx_version" {
  type        = string
  default     = "4.11.2"
}

# NOTE: Remember to update also helm_apps.tf
# TODO: Should be optional and null by default
variable "cert_manager_version" {
  type        = string
  default     = "1.15.3"
}

variable "kubernetes_admin_version" {
  type        = string
  default     = "1.12.0"
}

variable "socat_tunneler_version" {
  type        = string
  default     = "0.2.0"
}
