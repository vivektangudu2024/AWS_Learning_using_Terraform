resource "kubernetes_deployment" "mongo_deployment" {
    metadata {
        name = "mongodb-deployment"
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
            name = "mongodb"
            image = "mongo:latest"
            port {
              container_port = 27017
            }
            volume_mount {
              name = "mongodb-data"
              mount_path = "/data/db"
            }
          }
          volume {
            name = "mongodb-data"
            empty_dir {}
          }
        }
      }
    }

}

resource "kubernetes_service" "mongo_service" {
    depends_on = [ kubernetes_deployment.mongo_deployment ]
    metadata {
        name = "mongodb-service"
    }
    spec {
        selector = {
            app = "mongodb"
        }
        port {
            protocol = "TCP"
            port        = 27017
            target_port = 27017
        }
        type = "LoadBalancer"
    }
}