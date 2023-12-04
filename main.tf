module "codepipeline" {
  source             = "./modules/codepipeline"
  prefix             = "tf-codepipeline"
  full_repository_id = "proyogram/aws-terraform-backup"
  branch_name        = "develop"
}
