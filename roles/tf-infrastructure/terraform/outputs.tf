output "master_ipv4" {
  description = "Map of private ipv4 to public ipv4 for masters"
  value       = ["${hcloud_server.master.*.ipv4_address}"]
}

output "worker_ipv4" {
  description = "Map of private ipv4 to public ipv4 for workers"
  value       = ["${hcloud_server.worker.*.ipv4_address}"]
}
