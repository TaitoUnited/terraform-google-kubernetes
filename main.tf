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

locals {
  kubernetes_admin_version = "1.1.0"
  socat_tunneler_version   = "0.1.0"
  # NOTE: Remember to update also helm_apps_version in helm-apps.tf

  kubernetes_master_cidr   = "172.16.0.0/28"

  kubernetes               = var.kubernetes
  permissions              = var.permissions
  postgresqlClusterNames   = var.postgresql_cluster_names
  mysqlClusterNames        = var.mysql_cluster_names

  helmEnabled              = var.helm_enabled && local.kubernetes != null

  nodePools = try(
    local.kubernetes.nodePools != null
    ? local.kubernetes.nodePools
    : [],
    []
  )

  nginxIngressControllers = try(
    local.kubernetes.nginxIngressControllers != null
    ? local.kubernetes.nginxIngressControllers
    : [],
    []
  )
}

data "google_project" "project" {
}
