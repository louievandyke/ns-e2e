job "http-echo-win" {
  datacenters = ["dc1"]
  group "echo" {
    count = 1
    task "server" {
      driver = "docker"
      constraint {
        attribute = "${attr.kernel.name}"
        value     = "windows"
      }
      config {
        image = "hashicorp/http-echo:latest"
        args = [
          "-listen", ":8080",
          "-text", "Hello and welcome to 127.0.0.1 running on port 8080",
        ]
      }
      resources {
        network {
          mbits = 10
          port "http" {
            static = 8080
          }
        }
      }
    }
  }
}
