job "demo-mysql" {
  datacenters = ["dc1"]

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "demo-mysql" {
    restart {
      interval = "5m"
      attempts = 10
      delay = "25s"
      mode = "delay"
    }

    network {
      port "mysql" {
        to = 3306
      }
    }

   task "demo-mysql" {
      driver = "docker"

      config {
        image = "mysql:5.7.33"
        ports = ["mysql"]
        volumes = [
          "name=demo-mysql,size=20,repl=3/:/var/lib/mysql",
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