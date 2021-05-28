job "minio" {
  type = "service"
  datacenters = ["dc1"]

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "minio" {
    restart {
      interval = "5m"
      attempts = 10
      delay = "25s"
      mode = "delay"
    }

    network {
      port "minio" {
        to = 9000
      }
    }

   task "minio" {
      driver = "docker"

      config {
        image = "minio/minio:latest"
        ports = ["minio"]
        volumes = [
          "name=minio-vol,size=40,repl=3/:/var/lib/mysql",
        ]
        volume_driver = "pxd"
      }

      env {
        MYSQL_ROOT_PASSWORD = "Password1"
      }

      service {
        name = "demo-mysql"
        tags = ["global"]
        port = "mysql"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu = 500
        memory = 512
      }
    }
  }
}