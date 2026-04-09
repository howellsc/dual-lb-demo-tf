output "instance_summary" {
  value = {
    for inst in google_compute_instance.web_servers :
    inst.name => inst.network_interface[0].network_ip
  }
}
