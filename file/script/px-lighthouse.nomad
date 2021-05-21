job "lighthouse" {
  datacenters = ["dc1"]

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "lighthouse" {
    restart {
      interval = "5m"
      attempts = 10
      delay = "25s"
      mode = "delay"
    }

    network {
      port "http" {
        to = 80
      }
      port "https" {
        to = 443
      }
    }

   task "lighthouse" {
      driver = "docker"

      config {
        image = "portworx/px-lighthouse:latest"
        ports = ["http"]
        volumes = [
          "name=px-lighthouse,size=5,repl=3/:/config",
        ]
        volume_driver = "pxd"
      }

      service {
        name = "lighthouse-http"
        tags = ["px"]
        port = "http"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu = 1000
        memory = 1024
      }
    }
  }
}