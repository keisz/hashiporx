job "portworx" {
  type        = "service"
  datacenters = ["dc1"]

  group "portworx" {
    count = 6

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    network {
      port "portworx" {
        static = 9015
      }
    }

    # restart policy for failed portworx tasks
    restart {
      attempts = 6
      delay    = "30s"
      interval = "5m"
      mode     = "fail"
    }

    # how to handle upgrades of portworx instances
    update {
      max_parallel     = 1
      health_check     = "checks"
      min_healthy_time = "10s"
      healthy_deadline = "5m"
      auto_revert      = true
      canary           = 0
      stagger          = "30s"
    }

    task "px-node" {
      driver = "docker"
      kill_timeout = "120s"   # allow portworx 2 min to gracefully shut down
      kill_signal = "SIGTERM" # use SIGTERM to shut down the nodes

      # consul service check for portworx instances
      service {
        name = "portworx"
        tags = ["portworx1"]
        port = "portworx"

        check {
          port     = "portworx"
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }

      # setup environment variables for px-nodes
      env {
        AUTO_NODE_RECOVERY_TIMEOUT_IN_SECS = "1500"
        PX_TEMPLATE_VERSION                = "V4"
      }

      # container config
      config {
        image        = "portworx/oci-monitor:2.1.1"
        network_mode = "host"
        ipc_mode = "host"
        privileged = true
        ports = ["portworx"]

        # configure your parameters below
        # do not remove the last parameter (needed for health check)
        args = [
            "-c", "px-cluster-nomadv8",
            "-a",
            "-k", "consul://127.0.0.1:8500",
            "--endpoint", "0.0.0.0:9015"
        ]

        volumes = [
            "/var/cores:/var/cores",
            "/var/run/docker.sock:/var/run/docker.sock",
            "/run/containerd:/run/containerd",
            "/etc/pwx:/etc/pwx",
            "/opt/pwx:/opt/pwx",
            "/proc:/host_proc",
            "/etc/systemd/system:/etc/systemd/system",
            "/var/run/log:/var/run/log",
            "/var/log:/var/log",
            "/var/run/dbus:/var/run/dbus"
        ]
      }

      # resource config
      resources {
        cpu    = 1024
        memory = 2048
      }
    }
  }
}