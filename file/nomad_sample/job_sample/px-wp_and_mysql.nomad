job "wp-and-mysql" {
  datacenters = ["dc1"]

  group "wp-group" {
    count = 1
    
    network {
      port "http" {
        to = 80
      }
      port "mysql" {
        static = 3306
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
        WORDPRESS_DB_HOST     = "mysql5733.service.consul:3306"
        WORDPRESS_DB_USER     = "wp_user"
        WORDPRESS_DB_PASSWORD = "Password1"
      }

      service {
        name = "wordpress"
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
            limit = 1
            grace = "20s"
            ignore_warnings = false
          }
        }
      }

      resources {
        cpu = 1000
        memory = 1024

      }
    }

    task "mysql" {
      driver = "docker"

      config {
        image = "mysql:5.7.33"
        ports = ["mysql"]
        volumes = [
          "name=wpmysql,size=10,repl=3/:/var/lib/mysql",
        ]
        volume_driver = "pxd"
      }

      env {
        MYSQL_ROOT_PASSWORD = "Password1"
        MYSQL_DATABASE      = "wordpress"
        MYSQL_USER          = "wp_user"
        MYSQL_PASSWORD      = "Password1"
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