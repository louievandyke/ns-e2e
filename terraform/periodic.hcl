job "periodic-job" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "batch"

  periodic {
      cron = "*/5 2-23 * * *"
      prohibit_overlap = true
  }

  group "periodic-group" {
    count = 1

    task "periodic-task" {
      driver = "exec"

      config {
        command = "/usr/bin/sleep"
        args   = ["5"]
      }
      service {
        name  = "periodic-scheduler-lvd"
      }
      resources {
        cpu    = 20 #  MHz
        memory = 10 # MB

      }
    }
  }
}