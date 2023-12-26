resource "docker_image" "app" {
  name = local.docker_image_name

  build {
    context      = local.docker_build_context
    dockerfile   = local.dockerfile
    force_remove = true # delete locally when resource is deleted
  }

  provisioner "local-exec" {
    command = "docker push ${self.name}"
  }
}

# TODO: this doesn't work somehow
# resource "docker_registry_image" "app" {
#   name          = docker_image.app.name
#   keep_remotely = true
# }
