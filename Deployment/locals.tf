locals {

  source_code_hash     = sha1(join("", [for f in fileset("../src/Fakebook/Fakebook/", "**") : filesha1("../src/Fakebook/Fakebook/${f}")]))
  docker_image_name    = "docker.io/se22m001/fakebook:${substr(local.source_code_hash, 0, 10)}"
  docker_build_context = "../src/Fakebook/"
  dockerfile           = "Fakebook/Dockerfile" # Relative from context

  app_port = 8080
}
