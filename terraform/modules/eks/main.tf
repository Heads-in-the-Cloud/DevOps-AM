
######################
# Launch EKS Cluster #
######################

resource "aws_eks_cluster" "eks_cluster" {
  name = "AM-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.eks_subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.EKS_cluster_policy,
    aws_iam_role_policy_attachment.EKS_vpc_policy
  ]
}

#############
# IAM Roles #
#############

resource "aws_iam_role" "eks_cluster_role" {
  name = "AM-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_policy_doc.json
}

data "aws_iam_policy_document" "eks_cluster_policy_doc" {
  Version = "2021-01-21"
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
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
