job "scheduler" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "windows"
  }

  group "scheduler" {
    count = 1


    reschedule {
      delay          = "30s"
      delay_function = "constant"
      unlimited      = true
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "scheduler" {
      driver = "raw_exec"

      config {
        command = "C:/opt/x.bat"
      }
      service {
        name  = "scheduler-lvd"
        tags  = "scheduler-lvd-windows"
        port  = "scheduler"
      }
      resources {
        cpu    = 100 #  MHz
        memory = 128 # MB

        network {
          port "scheduler" {
          }
        }
      }
    }
  }
}
