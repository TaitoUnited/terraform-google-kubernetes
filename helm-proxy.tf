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

data "google_sql_database_instance" "postgresql" {
  count      = local.helmEnabled ? length(local.postgresqlClusterNames) : 0
  project    = var.project_id
  name       = local.postgresqlClusterNames[count.index]
}

data "google_sql_database_instance" "mysql" {
  count      = local.helmEnabled ? length(local.mysqlClusterNames) : 0
  project    = var.project_id
  name       = local.mysqlClusterNames[count.index]
}

resource "helm_release" "postgres_proxy" {
  depends_on = [module.kubernetes, module.helm_apps]

  count      = local.helmEnabled ? length(local.postgresqlClusterNames) : 0
  name       = local.postgresqlClusterNames[count.index]
  namespace  = "db-proxy"
  create_namespace = true
  repository = "https://kubernetes-charts.storage.googleapis.com/"
  chart      = "socat-tunneller"
  version    = var.socat_tunneler_version
  wait       = false

  set {
    name  = "tunnel.host"
    value = data.google_sql_database_instance.postgresql[count.index].private_ip_address
  }

  set {
    name  = "tunnel.port"
    value = 5432
  }
}

resource "helm_release" "mysql_proxy" {
  depends_on = [module.kubernetes, helm_release.postgres_proxy]

  count      = local.helmEnabled ? length(local.mysqlClusterNames) : 0
  name       = local.mysqlClusterNames[count.index]
  namespace  = "db-proxy"
  repository = "https://kubernetes-charts.storage.googleapis.com/"
  chart      = "socat-tunneller"
  version    = var.socat_tunneler_version
  wait       = false

  set {
    name  = "tunnel.host"
    value = data.google_sql_database_instance.mysql[count.index].private_ip_address
  }

  set {
    name  = "tunnel.port"
    value = 3306
  }
}
