resource "aws_iam_role" "codepipeline" {
  name               = "${var.prefix}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_for_codepipeline.json
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "${var.prefix}-codepipeline-role-policy"
  role   = aws_iam_role.codepipeline.name
  policy = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.prefix}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_for_codebuild.json
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
