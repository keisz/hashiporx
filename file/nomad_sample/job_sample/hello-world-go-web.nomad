job "hello-world-go" {
  #region = ""
  datacenters = ["dc1"]
  type = "service" 
  group "hello-world-go" {
    count = 1
    network {
      port "http" {
        to = 8888
      }
    }
    service {
      name = "go-web"  
      tags = ["internal", "go", "web"]
      port = "http"
    }
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    task "go-web" {
      driver = "raw_exec"
      config {
        command = "/usr/bin/go"
        args    = ["run", "/root/work/server.go"]
        ports   = ["http"]
      }
    }
  }
}