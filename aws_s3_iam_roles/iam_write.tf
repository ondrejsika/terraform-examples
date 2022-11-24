resource "aws_iam_policy" "write_one_s3_bucket" {
  name = "write_one_s3_bucket"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:ListBucket"
          ],
          "Resource" : "arn:aws:s3::::${aws_s3_bucket.example.bucket}"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
          ],
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.example.bucket}/*"
        }
      ]
    }
  )
}

resource "aws_iam_user" "write_one_s3_bucket" {
  name = "write_one_s3_bucket"
}

resource "aws_iam_access_key" "write_one_s3_bucket" {
  user = aws_iam_user.write_one_s3_bucket.name
}

resource "aws_iam_policy_attachment" "write_one_s3_bucket" {
  name       = "write_one_s3_bucket"
  policy_arn = aws_iam_policy.write_one_s3_bucket.arn
  users = [
    aws_iam_user.write_one_s3_bucket.name,
  ]
}

output "write_access_key" {
  value = aws_iam_access_key.write_one_s3_bucket.id
}

output "write_secret_key" {
  value     = aws_iam_access_key.write_one_s3_bucket.secret
  sensitive = true
}

