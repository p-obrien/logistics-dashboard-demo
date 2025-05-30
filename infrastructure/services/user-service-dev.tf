module "user-service" {
  source  = "../../modules/ecr"
  service = "user-service"
  env     = "dev"
  tags    = { environment = "dev", service = "user-service" }
}
