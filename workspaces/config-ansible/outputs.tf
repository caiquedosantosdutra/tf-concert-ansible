# workspaces/config-ansible/outputs.tf
output "job_url" {
  value = module.ansible.job_url
}

output "job_status" {
  value = module.ansible.job_status
}