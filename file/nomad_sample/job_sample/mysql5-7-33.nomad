job "mysql-5.7.33" {
  datacenters = ["dc1"]

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "mysql" {
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

   task "mysql" {
      driver = "docker"

      config {
        image = "mysql:5.7.33"
        ports = ["mysql"]
      }

      env {
        MYSQL_ROOT_PASSWORD = "Password1"
      }

      service {
        name = "mysql5733"
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