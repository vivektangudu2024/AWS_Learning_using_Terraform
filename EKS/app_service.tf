data "kubernetes_service" "mongo_service" {
    depends_on = [ kubernetes_service.mongo_service ]
    metadata {
        name = "mongodb-service"
    }
}

resource "kubernetes_deployment" "app_deployment" {
    depends_on = [ kubernetes_service.mongo_service ]
    metadata {
        name = "login-deployment"
        labels = {
          app:"login"
        }
    }
    spec {
      replicas = 1

      selector {
        match_labels = {
            app = "login"
        }
      }
      template {
        metadata {
          labels = {
            app = "login"
          }
        }
        spec {
          container {
            name = "login-container"
            image = "shantanuban09/login_signup_01:3.0"

            env {
              name = "MONGO_URL"
              value = data.kubernetes_service.mongo_service.status[0].load_balancer[0].ingress[0].hostname
            }

            port {
              container_port = 3000
            }
          }
        }
      }
    }

}

resource "kubernetes_service" "app_service" {
    depends_on = [ kubernetes_deployment.app_deployment ]
    metadata {
        name = "login-service"
    }
    spec {
        selector = {
            app = "login"
        }
        port {
            protocol = "TCP"
            port        = 80
            target_port = 3000
        }
        type = "LoadBalancer"
    }
}



output "service_external_ip" {
  value = kubernetes_service.app_service.status[0].load_balancer[0].ingress[0].hostname
}

output "mongo_external_ip" {
  value = data.kubernetes_service.mongo_service.status[0].load_balancer[0].ingress[0].hostname
}