

# Define MongoDB Secret
resource "kubernetes_secret" "mongodb_secret" {
    depends_on = [ aws_eks_node_group.private-nodes ]
  metadata {
    name = "mongodb-secret"
  }

  data = {
    username = base64encode("myusername")
    password = base64encode("mypassword")
  }
}
# Define MongoDB Deployment
resource "kubernetes_deployment" "mongodb" {
    depends_on = [ aws_eks_node_group.private-nodes ]
  metadata {
    name = "mongodb"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mongodb"
      }
    }

    template {
      metadata {
        labels = {
          app = "mongodb"
        }
      }

      spec {
        container {
          name  = "mongodb"
          image = "mongo:4.4"
          port {
            container_port = 27017
          }
          
        }
      }
    }
  }
}

# Define MongoDB Service
resource "kubernetes_service" "mongodb" {
    depends_on = [ kubernetes_deployment.mongodb ]
  metadata {
    name = "mongodb-service"
  }

  spec {
    selector = {
      app = "mongodb"
    }

    port {
      protocol    = "TCP"
      port        = 27017
      target_port = 27017
    }
  }
}

resource "kubernetes_config_map" "mongodb_config" {
  metadata {
    name = "mongodb-config"
  }

  data = {
    # Add your configuration key-value pairs here
    database_url = kubernetes_service.mongodb.metadata[0].name
  }
}

