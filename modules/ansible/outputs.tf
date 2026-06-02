# modules/ansible/outputs.tf
output "job_url" {
  value = aap_job.this.url
}

output "job_status" {
  value = aap_job.this.status
}