terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a new Web Droplet in the nyc1 region
resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key.id]
}

# ssh key
data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}

# kubernetes
resource "digitalocean_kubernetes_cluster" "teste" {
  name    = "teste"
  region  = var.region
  version = "1.26.3-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

# variaveis
variable "do_token" {
  default = ""
}
variable "ssh_key_name" {
  default = ""
}
variable "region" {
  default = ""
}

output jenkins_ip {
  value       = digitalocean_droplet.jenkins.ipv4_address
}

resource "local_file" "foo" {
  content  = digitalocean_kubernetes_cluster.teste.kube_config.0.raw_config
  filename = "kube_config.yaml"
}