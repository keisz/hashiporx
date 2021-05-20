job "mysql-server" {
  datacenters = ["dc1"]
  type        = "service"

  group "mysql-server" {
    count = 1
    
    network {
      port "mysql-server" {
        static = 3306
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "mysql-server" {
      driver = "docker"

      config {
        image = "mysql:5.7.33"
        ports = ["mysql-server"]
        volumes = [
          "name=mysql,size=10,repl=3/:/var/lib/mysql",
        ]
        volume_driver = "pxd"
      }

      env {
        MYSQL_ROOT_PASSWORD = "secret"
      }

      service {
        name = "mysql-server"
        port = "mysql-server"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 500
        memory = 1024
        }
      }
    }
  }
}