job "wordpress" {
  datacenters = ["dc1"]

  group "wordpress" {
    count = 1
    
    network {
      port "http" {
        to = 80
      }
    }

    restart {
      interval = "5m"
      attempts = 10
      delay    = "25s"
      mode     = "delay"
    }

    task "wordpress" {
      driver = "docker"

      config {
        image = "wordpress"
        ports = ["http"]
      }

      env {
        WORDPRESS_DB_HOST     = "wp-mysql.service.consul:3306"
        WORDPRESS_DB_USER     = "wp_user"
        WORDPRESS_DB_PASSWORD = "Password1"
      }

      service {
        name = "wp-wordpress"
        tags = ["global"]
        port = "http"

        check {
          name     = "wordpress running on port 80"
          type     = "http"
          protocol = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"

          check_restart {
            limit = 3
            grace = "20s"
            ignore_warnings = false
            delay    = "10s"
          }
        }
      }
      
      resources {
        cpu = 1000
        memory = 1024
      }
    }
  }
}
