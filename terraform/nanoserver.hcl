job "nanoserver" {
  datacenters = ["dc1"]
  type        = "service"

  group "dbwebapp" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "webapp" {
      driver = "docker"
      constraint {
        attribute = "${attr.kernel.name}"
        value     = "windows"
      }

      env {
        DBUSER = "dbwebapp"
        DBPASS = "dbwebapp"
      }

      template {
        data = <<EOH
DBHOST="{{ range service "mysql-server" }}{{ .Address }}{{ end }}"
DBPORT="{{ range service "mysql-server" }}{{ .Port }}{{ end }}"
EOH

        destination = "mysql-server.env"
        env         = true
      }

      config {
         image = "mcr.microsoft.com/windows/nanoserver:10.0.14393.1198"
         image_pull_timeout = "10s"
         command = "cmd.exe"
         args    = ["/K", "ping -t localhost"]
        }

      }
    }
}
