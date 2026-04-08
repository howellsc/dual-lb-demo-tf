output "l4_neg" {
  value = google_compute_network_endpoint_group.neg_l4.id
}

output "l7_neg" {
  value = google_compute_network_endpoint_group.neg_l7.id
}
