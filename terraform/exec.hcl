job "windows" {
  datacenters = ["dc1"]
  type        = "service"

  group "microsoft" {
    count = 1

    task "example" {
      driver = "raw_exec"

      constraint {
        attribute = "${attr.kernel.name}"
        value     = "windows"
      }

      config {
        # When running a binary that exists on the host, the path must be absolute/
        command = "C:/opt/consul.exe"
        args    = ["-version"]
      }
    }
  }
}