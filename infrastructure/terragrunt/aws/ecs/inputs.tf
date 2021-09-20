variable "alb_target_group_arn" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cpu_units" {
  type = string
}

variable "database_host_secret_arn" {
  type = string
}

variable "database_name_secret_arn" {
  type = string
}

variable "database_username_secret_arn" {
  type = string
}

variable "database_password_secret_arn" {
  type = string
}

variable "database_proxy_security_group_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "ecs_events_lambda_security_group_id" {
  type = string
}

variable "ecs_service_security_group_id" {
  type = string
}

variable "efs_security_group_id" {
  type = string
}

variable "list_manager_api_key" {
  description = "API key used for Platform ListManager request auth"
  type        = string
  sensitive   = true
}

variable "list_manager_notify_services" {
  description = "Platform ListManager service names and API keys for sending templates"
  type        = string
  sensitive   = true
}

variable "list_manager_endpoint" {
  description = "Platform ListManager API endpoint"
  type        = string
  sensitive   = true
}

variable "list_manager_service_id" {
  description = "Platform ListManager endpoint ID to get subscriber counts"
  type        = string
  sensitive   = true
}

variable "notify_api_key" {
  description = "API key used for Notify request auth"
  type        = string
  sensitive   = true
}

variable "memory" {
  type = string
}

variable "max_capacity" {
  type = number
}

variable "min_capacity" {
  type = number
}

variable "private_subnet_ids" {
  type = list(any)
}

variable "scale_in_cooldown" {
  type = number
}

variable "scale_out_cooldown" {
  type = number
}

variable "scale_threshold_cpu" {
  type = number
}

variable "scale_threshold_memory" {
  type = number
}

variable "wordpress_image" {
  type = string
}

variable "wordpress_image_tag" {
  type = string
}

variable "wordpress_repository_arn" {
  type = string
}

# Generated by https://api.wordpress.org/secret-key/1.1/salt/
variable "wordpress_auth_key" {
  type = string
}

variable "wordpress_secure_auth_key" {
  type = string
}

variable "wordpress_logged_in_key" {
  type = string
}

variable "wordpress_nonce_key" {
  type = string
}

variable "wordpress_auth_salt" {
  type = string
}

variable "wordpress_secure_auth_salt" {
  type = string
}

variable "wordpress_logged_in_salt" {
  type = string
}

variable "wordpress_nonce_salt" {
  type = string
}
