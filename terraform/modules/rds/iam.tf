
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "am-bastion-iam-profile"
  role = aws_iam_role.bastion_iam_role.name
}

resource "aws_iam_role" "bastion_iam_role" {
  name = "am-s3-readonly"
  assume_role_policy = data.aws_iam_policy_document.bastion_policy_doc.json
}

data "aws_iam_policy_document" "bastion_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

data "aws_iam_policy" "bastion_read_s3" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "bastion_s3_policy_attach" {
  role = aws_iam_role.bastion_iam_role.name
  policy_arn = data.aws_iam_policy.bastion_read_s3.arn
}