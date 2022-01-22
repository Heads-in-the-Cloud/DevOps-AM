
##################
# EC2 Nodegroups #
##################

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "AM-eks-nodegroup"
  node_role_arn = aws_iam_role.EKS_nodegroup_role.arn
  subnet_ids = var.eks_public_subnets

  instance_types = ["t3.large"]

  scaling_config {
    desired_size = 2
    max_size = 4
    min_size = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.EKS_EC2_policy,
    aws_iam_role_policy_attachment.EKS_CNI_policy,
    aws_iam_role_policy_attachment.EKS_worker_policy
  ]

  tags = {
    Name = "AM-eks-nodegroup"
  }
}

#############
# IAM Roles #
#############

resource "aws_iam_role" "EKS_nodegroup_role" {
  name = "AM-eks-nodegroup-role"
  assume_role_policy = data.aws_iam_policy_document.eks_nodegroup_policy_doc.json
}

data "aws_iam_policy_document" "eks_nodegroup_policy_doc" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "EKS_CNI_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.EKS_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "EKS_EC2_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.EKS_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "EKS_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.EKS_nodegroup_role.name
}
