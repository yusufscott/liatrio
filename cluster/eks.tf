#EKS Cluster Setup
resource "aws_eks_cluster" "liatrio_cluster" {
  name     = "liatrio-cluster"
  role_arn = aws_iam_role.liatrio_eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.liatrio_cluster_subnets[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.attach_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.attach_AmazonEKSVPCResourceController,
  ]

  tags = {
    Name = "Liatrio Cluster"
  }
}

resource "aws_eks_node_group" "liatrio_node_group" {
  cluster_name    = aws_eks_cluster.liatrio_cluster.name
  node_group_name = "liatrio-node-group"
  node_role_arn   = aws_iam_role.liatrio_node_role.arn
  subnet_ids      = aws_subnet.liatrio_node_subnets[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.attach_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.attach_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.attach_AmazonEC2ContainerRegistryReadOnly,
  ]
}