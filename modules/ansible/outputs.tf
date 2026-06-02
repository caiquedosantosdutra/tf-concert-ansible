# modules/ansible/outputs.tf

output "job_id" {
  value       = aap_job.this.id
  description = "ID do job no AAP"
}

output "job_status" {
  value       = aap_job.this.status
  description = "Status final do job"
}