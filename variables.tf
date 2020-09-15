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

variable "pods_range_name" {
  type        = string
  default     = ""
  description = "Kubernetes ip range pods"
}

variable "services_range_name" {
  type        = string
  default     = ""
  description = "Kubernetes ip range services"
}

variable "global_cicd_deploy_service_account" {
  type        = string
  default     = ""
  description = "Global CI/CD deploy service account (e.g. cloud build). The service account is given deploy privileges to ALL Kubernetes namespaces. Leave empty if you want to create namespace specific CI/CD service accounts instead."
}

variable "global_cicd_testing_service_account" {
  type        = string
  default     = ""
  description = "Global CI/CD testing service account. The service account is given secret read privileges to ALL Kubernetes namespaces. Leave empty if you want to create namespace specific CI/CD service accounts instead."
}

variable "kubernetes" {
  type        = any
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "permissions" {
  type        = any
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "postgresql_clusters" {
  type        = list
  default     = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "mysql_clusters" {
  type        = list
  default     = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}
