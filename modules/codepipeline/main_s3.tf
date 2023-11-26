resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.prefix}-github-artifact"
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_object" "buildspec" {
  for_each = fileset("${path.module}/buildspec/", "*")

  bucket = aws_s3_bucket.codepipeline_bucket.id
  key    = "/buildspec/${each.value}"
  source = "${path.module}/buildspec/${each.value}"
  etag   = filemd5("${path.module}/buildspec/${each.value}")
}
