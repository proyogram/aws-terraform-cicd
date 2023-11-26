variable "prefix" {
  type        = string
  description = "全てのリソースの文字前に付与される値"
}

variable "full_repository_id" {
  type        = string
  description = "「Organization名/リポジトリ名」の形式"
}

variable "branch_name" {
  type        = string
  description = "ブランチ名"
}
