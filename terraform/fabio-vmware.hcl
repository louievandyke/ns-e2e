job "fabio" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "system"

  update {
    stagger      = "10s"
    max_parallel = 1
  }

  vault {
    policies = ["service-fabio"]
  }

  group "fabio-windows" {
    constraint {
      attribute = "${attr.kernel.name}"
      value     = "windows"
    }

    task "fabio-windows" {
      driver = "raw_exec"

      template {
        data = <<EOH
          {{ with secret "consul/creds/service-fabio" }}
          registry.consul.token = {{ .Data.token }}
          {{ end }}
          registry.consul.kvpath = /control-plane-services/fabio/config
          registry.consul.noroutehtmlpath = /control-plane-services/fabio/noroute.html
          proxy.addr = :{{ env "NOMAD_PORT_lb" }},:{{ env "NOMAD_PORT_uem_rate_limiting" }};proto=tcp
          ui.addr = :{{ env "NOMAD_PORT_ui" }}
          registry.consul.register.addr = {{ env "NOMAD_ADDR_ui" }}
          metrics.target = statsd
          metrics.statsd.addr = 127.0.0.1:8125
          metrics.prefix = fabio
          metrics.names = services.\{\{clean .Service\}\}
        EOH

        destination = "secrets/fabio.properties"
      }

      config {
        command = "/services/fabio/1.5.13/fabio-1.5.13-go1.13.4-windows_amd64.exe"
        args    = ["-cfg", "secrets/fabio.properties"]
      }

      resources {
        cpu    = "[[ .fabio.resources.cpu ]]"    # Mhz
        memory = "[[ .fabio.resources.memory ]]" # MB

        network {
          port "lb" {
            static = 29999
          }

          port "ui" {
            static = 29998
          }

          port "uem_rate_limiting" {
            static = 30000
          }
        }
      }
    }
  }

  group "fabio-linux" {
    constraint {
      attribute = "${attr.kernel.name}"
      value     = "linux"
    }

    task "fabio-linux" {
      driver = "docker"

      template {
        data = <<EOH
          {{ with secret "consul/creds/service-fabio" }}
          registry.consul.token = {{ .Data.token }}
          {{ end }}
          registry.consul.kvpath = /control-plane-services/fabio/config
          registry.consul.noroutehtmlpath = /control-plane-services/fabio/noroute.html
          proxy.addr = :{{ env "NOMAD_PORT_lb" }}
          ui.addr = :{{ env "NOMAD_PORT_ui" }}
          registry.consul.register.addr = {{ env "NOMAD_ADDR_ui" }}
          metrics.target = statsd
          metrics.statsd.addr = 127.0.0.1:8125
          metrics.prefix = fabio
          metrics.names = services.\{\{clean .Service\}\}
        EOH

        destination = "secrets/fabio.properties"
      }

      config {
        image        = "[[ .default_docker_registry ]]/docker-local-ws1uem-qe-builds/fabio-photonos:1.5.14-9bcf5ac-2021.01.14.15"
        network_mode = "host"
        args         = ["-cfg", "secrets/fabio.properties"]
      }

      resources {
        cpu    = "[[ .fabio.resources.cpu ]]"    # Mhz
        memory = "[[ .fabio.resources.memory ]]" # MB

        network {
          port "lb" {
            static = 29999
          }

          port "ui" {
            static = 29998
          }
        }
      }
    }
  }
}
