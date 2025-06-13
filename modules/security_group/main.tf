resource "aws_security_group" "eks" {
  name        = "${var.name}-eks-sg"
  description = "EKS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-eks-sg"
  }
}

output "eks_security_group_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = aws_security_group.eks.id
}