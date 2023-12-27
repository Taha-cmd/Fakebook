variable "unique_prefix" {
  type     = string
  nullable = false
}

variable "location" {
  type     = string
  nullable = false
}

variable "docker_repository" {
  type     = string
  nullable = false

  description = "The name of the docker repository on dockerhub to push to"
}
