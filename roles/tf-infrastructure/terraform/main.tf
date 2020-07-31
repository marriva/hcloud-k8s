provider "hcloud" {
  token   = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  count = length(var.authorized_keys)
  name = "ssh-key-${count.index}"
  public_key = var.authorized_keys[count.index]
}

# Private Network and subnets
resource "hcloud_network" "default" {
  name     = "kubernetes"
  ip_range = "10.0.0.0/8"
}

resource "hcloud_network_subnet" "master" {
  network_id   = hcloud_network.default.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_network_subnet" "worker" {
  network_id   = hcloud_network.default.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.2.0/24"
}

resource "hcloud_server" "master" {
  count       = 1
  name        = "master-${count.index}"
  image       = var.server_image
  server_type = var.master_servertype
  location    = var.datacenter
  ssh_keys    = hcloud_ssh_key.default[*].id
  user_data   = file("./user-data/cloud-config.yaml")
}

resource "hcloud_server_network" "master_network" {
  count      = length(hcloud_server.master)
  subnet_id  = hcloud_network_subnet.master.id
  server_id  = hcloud_server.master.*.id[count.index]
  ip         = "10.0.1.${count.index + 2}"
}

# Worker
resource "hcloud_server" "worker" {
  count       = var.worker_count
  name        = "worker-${count.index}"
  image       = var.server_image
  server_type = var.worker_servertype
  location    = var.datacenter
  ssh_keys    = hcloud_ssh_key.default[*].id
  user_data   = file("./user-data/cloud-config.yaml")
}

resource "hcloud_server_network" "worker_network" {
  count      = length(hcloud_server.worker)
  subnet_id  = hcloud_network_subnet.worker.id
  server_id  = hcloud_server.worker.*.id[count.index]
  ip         = "10.0.2.${count.index + 2}"
}
