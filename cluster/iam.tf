#IAM Cluster Role setup
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "liatrio_eks_cluster_role" {
  name               = "liatrio-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "Liatrio Cluster Role"
  }
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.liatrio_eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.liatrio_eks_cluster_role.name
}

#IAM Node Role setup
resource "aws_iam_role" "liatrio_node_role" {
  name = "liatrio-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.liatrio_node_role.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.liatrio_node_role.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.liatrio_node_role.name
}