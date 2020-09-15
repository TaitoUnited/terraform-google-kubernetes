# Google Cloud Kubernetes

Example usage:

```
provider "google" {
  project      = "my-infrastructure"
  region       = "europe-west1"
  zone         = "europe-west1b"
}

# Enable Google APIs

resource "google_project_service" "compute" {
  service      = "compute.googleapis.com"
}

resource "google_project_service" "cloudkms" {
  service      = "cloudkms.googleapis.com"
}

resource "google_project_service" "container" {
  service      = "container.googleapis.com"
}

resource "google_project_service" "containerregistry" {
  service      = "containerregistry.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
  service      = "cloudbuild.googleapis.com"
}

# CI/CD tester service account

resource "google_service_account" "cicd_tester" {
  depends_on   = [google_project_service.compute]
  account_id   = "cicd-tester"
  display_name = "cicd-tester"
}

# Kubernetes

module "kubernetes" {
  source              = "TaitoUnited/kubernetes/google"
  version             = "1.0.0"
  providers           = [ google ]
  depends_on          = [
    google_project_service.compute,
    google_project_service.cloudkms,
    google_project_service.container,
    google_project_service.containerregistry,
    google_project_service.cloudbuild,
  ]

  # Settings
  helm_enabled        = false  # Should be false on the first run, then true
  email               = "devops@mydomain.com"

  # Network
  network             = module.network.network
  subnetwork          = module.network.subnets_names[0]
  pods_range_name     = module.network.pods_range_name
  services_range_name = module.network.services_range_name

  # Permissions
  permissions         = yamldecode(file("${path.root}/../infra.yaml"))["permissions"]

  # Kubernetes
  kubernetes          = yamldecode(file("${path.root}/../infra.yaml"))["kubernetes"]

  # Database clusters (for db proxies)
  postgresql_clusters = module.database.postgresql_clusters
  mysql_clusters      = module.database.mysql_clusters

  # Service accounts (for permissions)
  global_cicd_deploy_service_account = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  global_cicd_testing_service_account = "serviceAccount:${google_service_account.cicd_tester.email}"
}
```

Example YAML:

```
permissions:
  clusterRoles:
    - name: taito:iam-admin
      subjects: [ "group:devops@mydomain.com" ]
    - name: taito:status-viewer
      subjects: [ "group:staff@mydomain.com" ]
  namespaces:
    - name: db-proxy
      clusterRoles:
        - name: taito:pod-portforwarder
          subjects: [ "user:jane.external@anotherdomain.com" ]
    - name: my-namespace
      clusterRoles:
        - name: taito:status-viewer
          subjects: [ "user:jane.external@anotherdomain.com" ]
    - name: another-namespace
      clusterRoles:
        - name: taito:developer
          subjects: [ "user:jane.external@anotherdomain.com" ]

# For Kubernetes setting descriptions, see
# https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/
kubernetes:
  name: zone1-common-kube1
  context: zone1
  releaseChannel: STABLE
  maintenanceStartTime: 02:00
  registryProjectId:
  authenticatorSecurityGroup: # gke-security-groups@yourdomain.com
  rbacSecurityGroup:
  clusterFirewallRulesEnabled: false
  masterPrivateEndpointEnabled: false
  masterGlobalAccessEnabled: true
  privateNodesEnabled: true
  shieldedNodesEnabled: true
  networkPolicyEnabled: true
  dbEncryptionEnabled: true
  podSecurityPolicyEnabled: true
  verticalPodAutoscalingEnabled: true
  dnsCacheEnabled: true
  pdCsiDriverEnabled: true
  resourceConsumptionExportEnabled: true
  resourceConsumptionExportDatasetId:
  networkEgressExportEnabled: false
  binaryAuthorizationEnabled: false
  intranodeVisibilityEnabled: false
  configConnectorEnabled: false
  region: europe-west1
  # zones: # NOTE: Provide zones only if kubernes is ZONAL instead of REGIONAL
  masterAuthorizedNetworks:
    - 0.0.0.0/0
  nodePools:
    - name: pool-1
      machineType: n1-standard-1
      acceleratorType:
      acceleratorCount: 0
      secureBootEnabled: true
      diskSizeGb: 100
      locations: # Leave empty or specify zones: us-central1-b,us-central1-c
      # NOTE: On Google Cloud total number of nodes = node_count * num_of_zones
      minNodeCount: 1
      maxNodeCount: 1
    - name: gpu-pool-1
      machineType: n1-standard-1
      acceleratorType: NVIDIA_TESLA_T4
      acceleratorCount: 1
      secureBootEnabled: true
      diskSizeGb: 100
      locations: # Leave empty or specify zones: us-central1-b,us-central1-c
      # NOTE: On Google Cloud total number of nodes = node_count * num_of_zones
      minNodeCount: 1
      maxNodeCount: 1
  # Ingress controllers
  nginxIngressControllers:
    - class: nginx
      replicas: 3
      metricsEnabled: true
      maxmindLicenseKey: # For GeoIP
      # See https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
      configMap:
        enable-modsecurity: true
        enable-owasp-modsecurity-crs: true
        use-geoip: false
        use-geoip2: true
        enable-real-ip: false
        enable-opentracing: false
        whitelist-source-range:
        # Block malicious IPs. See https://www.projecthoneypot.org/list_of_ips.php
        block-cidrs:
        block-user-agents:
        block-referers:
      # Map TCP/UDP connections to services
      tcpServices:
        3000: my-namespace/my-tcp-service:9000
      udpServices:
        3001: my-namespace/my-udp-service:9001
  # Certificate managers
  certManager:
    enabled: false
  # Platforms
  istio:
    enabled: false
  knative:         # Using Google Cloud Run
    enabled: false
  # Logging, monitoring, and tracing
  falco:
    enabled: false # NOTE: Not supported yet
  jaeger:
    enabled: false # NOTE: Not supported yet
  sentry:
    enabled: false # NOTE: Not supported yet
  # CI/CD
  jenkinsx:
    enabled: false # NOTE: Not supported yet
```

Combine with the following modules to get a complete infrastructure defined by YAML:

- [Admin](https://registry.terraform.io/modules/TaitoUnited/admin/google)
- [DNS](https://registry.terraform.io/modules/TaitoUnited/dns/google)
- [Network](https://registry.terraform.io/modules/TaitoUnited/network/google)
- [Kubernetes](https://registry.terraform.io/modules/TaitoUnited/kubernetes/google)
- [Databases](https://registry.terraform.io/modules/TaitoUnited/databases/google)
- [Storage](https://registry.terraform.io/modules/TaitoUnited/storage/google)
- [Monitoring](https://registry.terraform.io/modules/TaitoUnited/monitoring/google)
- [PostgreSQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/postgresql)
- [MySQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/mysql)

TIP: Similar modules are also available for AWS, Azure, and DigitalOcean. All modules are used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/).

See also [Google Cloud project resources](https://registry.terraform.io/modules/TaitoUnited/project-resources/google), [Full Stack Helm Chart](https://github.com/TaitoUnited/taito-charts/blob/master/full-stack), and [full-stack-template](https://github.com/TaitoUnited/full-stack-template).

Contributions are welcome!
