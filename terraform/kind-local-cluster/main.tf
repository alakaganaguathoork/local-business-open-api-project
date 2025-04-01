terraform {
  backend "local" {
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "app"
    namespace = kubernetes_namespace.this.metadata.0.name
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "MyApp"
      }
    }

    template {
      metadata {
        labels = {
          app = "MyApp"
        }
      }

      spec {
        container {
          image             = var.docker_image_name
          image_pull_policy = "IfNotPresent"
          name              = "${var.docker_image_name}-container"
          port {
            container_port = 5400
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health_check"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_svc" {
  metadata {
    name      = "nodeport"
    namespace = kubernetes_namespace.this.metadata.0.name
  }

  spec {
    selector = {
      app = kubernetes_deployment.app.spec.0.template.0.metadata.0.labels.app
    }
    type = "NodePort"

    port {
      node_port   = 30080
      port        = 5400
      target_port = 5400
    }
  }
}
