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

variable "helm_enabled" {
  type        = bool
  default     = "false"
  description = "Installs helm apps if set to true. Should be set to true only after Kubernetes cluster already exists."
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

variable "kubernetes" {
  type = object({
    name = string
    context = string
    releaseChannel = string
    maintenanceStartTime = string
    registryProjectId = string
    authenticatorSecurityGroup = string
    rbacSecurityGroup = string
    clusterFirewallRulesEnabled = bool
    masterPrivateEndpointEnabled = bool
    masterGlobalAccessEnabled = bool
    privateNodesEnabled = bool
    shieldedNodesEnabled = bool
    networkPolicyEnabled = bool
    dbEncryptionEnabled = bool
    podSecurityPolicyEnabled = bool
    verticalPodAutoscalingEnabled = bool
    dnsCacheEnabled = bool
    pdCsiDriverEnabled = bool
    resourceConsumptionExportEnabled = bool
    resourceConsumptionExportDatasetId = string
    networkEgressExportEnabled = bool
    binaryAuthorizationEnabled = bool
    intranodeVisibilityEnabled = bool
    configConnectorEnabled = bool
    region = string
    zones = list(string)
    masterAuthorizedNetworks = list(string)
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
    nginxIngressControllers = list(object({
      class = string
      replicas = number
      metricsEnabled = bool
      maxmindLicenseKey = string
      configmap = map(string)
      tcpServices = map(string)
      udpServices = map(string)
    }))
    certManager = object({
      enabled = bool
    })
    istio = object({
      enabled = bool
    })
    knative = object({
      enabled = bool
    })
    falco = object({
      enabled = bool
    })
    jaeger = object({
      enabled = bool
    })
    sentry = object({
      enabled = bool
    })
    jenkinsx = object({
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
