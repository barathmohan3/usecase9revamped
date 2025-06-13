# ------------------------
# Get EKS Cluster Details
# ------------------------
data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

# ------------------------
# Kubernetes Provider
# ------------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# ------------------------
# HELM Provider
# ------------------------
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# ------------------------
# AWS Load Balancer Controller
# ------------------------
resource "helm_release" "loadbalancer_controller" {
  depends_on = [var.lbc_iam_depends_on]
  name       = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.lbc_iam_role_arn
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "clusterName"
    value = var.cluster_id
  }
}

# ------------------------
# Namespace for Monitoring
# ------------------------
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# ------------------------
# Prometheus & Grafana Stack
# ------------------------
resource "helm_release" "prometheus_grafana_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.0.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  timeout    = 600

  max_history     = 5
  cleanup_on_fail = true
  wait            = true
  wait_for_jobs   = true

  values = [
    <<-EOT
    prometheus:
      enabled: true
      prometheusSpec:
        scrapeInterval: 30s
        evaluationInterval: 30s
        resources:
          requests:
            memory: 1Gi
            cpu: 500m
      additionalPodMonitors:
        - name: aws-lb-controller-monitor
          namespaceSelector:
            matchNames: ["kube-system"]
          podMetricsEndpoints:
            - port: http
              path: /metrics
          selector:
            matchLabels:
              app.kubernetes.io/name: aws-load-balancer-controller

    grafana:
      enabled: true
      adminPassword: "admin"
      service:
        type: LoadBalancer
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: "external"
          service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
          service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
        port: 80
        targetPort: 3000
      resources:
        requests:
          memory: 512Mi
          cpu: 300m
    EOT
  ]

  depends_on = [
    helm_release.loadbalancer_controller,
    kubernetes_namespace.monitoring
  ]
}
