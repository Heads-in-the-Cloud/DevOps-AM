
output "iam_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_id" {
  value = aws_eks_cluster.eks_cluster.id
}

output "eks_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "route_name" {
  value = aws_route53_record.utopia_record.name
}
