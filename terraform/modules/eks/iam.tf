
resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.environment_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_policy_doc.json
}

data "aws_iam_policy_document" "eks_cluster_policy_doc" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "EKS_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "EKS_vpc_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}
