job "testcentos" {
  type = "service"
  datacenters = ["dc1"]

  group "test" {
   count = 1
   task "centos" {
      driver = "docker"

      config {
        image = "keisz/testcentos"
        args = ["sleep", "infinity"]
      }

      resources {
        cpu = 500
        memory = 512
      }
    }
  }
}
