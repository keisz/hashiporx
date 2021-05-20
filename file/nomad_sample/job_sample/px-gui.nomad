job "ubuntu-gui" {
  datacenters = ["dc1"]

  group "ubuntu-gui" {
    network {
      port "http" {
        to = 80
      }
    }

    task "ubuntu" {
      driver = "docker"

      config {
        image = "dorowu/ubuntu-desktop-lxde-vnc:latest"
        ports = ["http"]
        volumes = [
          "name=ubuntu-gui,size=10,repl=3/:/tmp",
        ]
        volume_driver = "pxd"
      }

      resources {
        cpu    = 2000
        memory = 2048
      }

      ##consul service
      service {
        name = "ubuntu-gui"
        tags = ["gui", "ubuntu"]
        port = "http"
        meta {
          meta = "ubuntu"
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