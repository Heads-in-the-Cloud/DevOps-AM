
######################
# Launch EKS Cluster #
######################

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.environment_name}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.eks_subnets
    security_group_ids      = [var.eks_sg_id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.EKS_cluster_policy,
    aws_iam_role_policy_attachment.EKS_vpc_policy
  ]

  tags = {
    Name = "${var.environment_name}-eks-cluster"
  }
}

// route 53
resource "aws_route53_record" "utopia_record" {
  zone_id = var.r53_zone_id
  name    = var.record_name
  type    = "CNAME"
  ttl     = "60"
  records = ["placeholder.text"]

  # Don't recreate route53 record if record target changes
  lifecycle {
    ignore_changes = [
        records
    ]
  }
}
