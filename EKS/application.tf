# Define Microservice Deployment
resource "kubernetes_deployment" "microservice" {
    depends_on = [ kubernetes_service.mongodb, kubernetes_config_map.mongodb_config  ]
  metadata {
    name = "microservice"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "microservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "microservice"
        }
      }

      spec {
        container {
          name  = "microservice"
          image = "321009707228.dkr.ecr.us-east-1.amazonaws.com/microservice:latest"
          //image_pull_policy = "Never"
          
          port {
            container_port = 80
          }
          env {
            name  = "MONGO_URL"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.mongodb_config.metadata[0].name
                key  = "database_url"
              }
            }
          }
          
        }
      }
    }
  }
}

resource "kubernetes_service" "external_service" {
    depends_on = [ kubernetes_deployment.microservice ]
  metadata {
    name = "external-service"
  }

  spec {
    selector = {
      app = "microservice"
    }

    port {
      protocol = "TCP"
      port     = 80
      target_port = 80
      node_port = 30002
    }

    type = "LoadBalancer"
  }
}