variable "prefix" {
  type        = string
  description = "全てのリソースの文字前に付与される値。"
}

variable "full_repository_id" {
  type        = string
  description = "Codepipelineのソースとして設定するリポジトリ名。「ユーザ名/リポジトリ名」の形式で記載する。"
}

variable "branch_name" {
  type        = string
  description = "Codepipelineのソースとして設定するブランチ名。"
}
