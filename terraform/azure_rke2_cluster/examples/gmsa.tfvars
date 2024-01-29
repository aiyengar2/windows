nodes = [
  {
    name     = "linux-server"
    image    = "linux"
    size     = "Standard_B4als_v2"
    roles    = ["controlplane", "etcd", "worker"]
    replicas = 1
  },
  {
    name     = "windows-server"
    image    = "windows"
    roles    = ["worker"]
    replicas = 1
  }
]

apps = {
  cert-manager-crd = {
    path      = "https://github.com/cert-manager/cert-manager/releases/download/v1.12.4/cert-manager.crds.yaml"
    namespace = "cert-manager"
  }

  cert-manager = {
    path         = "https://charts.jetstack.io/charts/cert-manager-v1.12.4.tgz"
    namespace    = "cert-manager"
    values       = {}
    dependencies = ["cert-manager-crd"]
  }

  rancher-windows-gmsa-crd = {
    path      = "https://github.com/rancher/Rancher-Plugin-gMSA/raw/release/v0.2/assets/rancher-gmsa-webhook-crd/rancher-gmsa-webhook-crd-0.2.0-rc1.tgz"
    namespace = "cattle-windows-gmsa-system"
    values    = {}
  }

  rancher-windows-gmsa = {
    path         = "https://github.com/rancher/Rancher-Plugin-gMSA/raw/release/v0.2/assets/rancher-gmsa-webhook/rancher-gmsa-webhook-0.2.0-rc1.tgz"
    namespace    = "cattle-windows-gmsa-system"
    values       = {}
    dependencies = ["rancher-windows-gmsa-crd", "cert-manager"]
  }

  windows-ad-setup = {
    path      = "charts/windows-ad-setup"
    namespace = "cattle-windows-gmsa-system"
    # Comment this out if you are not using the Active Directory Terraform module
    #
    # This will cause a failure unless you have run the script in the setup_integration
    # output of the Active Directory Terraform module
    #
    # Alternatively, you can manually create the expected `values.json` for an external Active Directory
    values_file  = "dist/active_directory/values.json"
    dependencies = ["rancher-windows-gmsa"]
  }

  rancher-gmsa-plugin-installer = {
    path      = "https://github.com/rancher/Rancher-Plugin-gMSA/raw/release/v0.2/assets/rancher-gmsa-plugin-installer/rancher-gmsa-plugin-installer-0.2.0-rc1.tgz"
    namespace = "cattle-windows-gmsa-system"
    values    = {}
  }

  rancher-gmsa-account-provider = {
    path         = "https://github.com/rancher/Rancher-Plugin-gMSA/raw/release/v0.2/assets/rancher-gmsa-account-provider/rancher-gmsa-account-provider-0.2.0-rc1.tgz"
    namespace    = "cattle-windows-gmsa-system"
    values       = {}
    dependencies = ["cert-manager"]
  }

  windows-gmsa-webserver = {
    path      = "charts/windows-gmsa-webserver"
    namespace = "cattle-wins-system"
    values = {
      gmsa = "gmsa1-ccg"
    }
    dependencies = ["windows-ad-setup", "rancher-gmsa-plugin-installer", "rancher-gmsa-account-provider"]
  }
}
