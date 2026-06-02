# modules/ansible/outputs.tf

output "job_status" {
  value       = aap_job.this.status
  description = "Status final do job"
}

output "job_url" {
  value       = aap_job.this.url
  description = "URL do job no AAP"
}