job "dummy-batch" {
  type        = "system"
  datacenters = ["dc1"]
  #namespace   = "test"

  #parameterized {}

  group "default" {
    count = 1

    task "default" {
      driver = "docker"
      config {
        image = "busybox"
        args  = ["sleep", "120"]
      }

      resources {
        cpu    = 300
        memory = 32
      }
    }
  }
}

