job "webserv-nginx" {
  datacenters = ["dc1"]

  group "webserv-group" {
    network {
      port "http" {
        to = 80
      }
    }

    task "webserv1" {
      driver = "docker"

      config {
        image = "nginx:latest"

        ports = ["http"]
      }

      resources {
        cpu    = 500
        memory = 256
      }

      ##consul service
      service {
        tags = ["web", "nginxtest"]

        port = "http"

        meta {
          meta = "webserver-test"
        }

        check {
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }

      }
    }
  }
}