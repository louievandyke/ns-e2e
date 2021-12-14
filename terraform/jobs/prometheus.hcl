job "prometheus" {
  datacenters = ["dc1"]

  update {
    stagger      = "30s"
    max_parallel = 1
  }

  group "prometheus" {
    count = 1

    ephemeral_disk {
      size    = 600
      migrate = true
    }

    network {
      mode = "bridge"
      port "prometheus_ui" { to = 9090 }
      port "alertmanager_ui" { to = 9093 }
    }

    service {
      name = "prometheus"

      tags = [
        "http",
        # See: https://docs.traefik.io/routing/services/
        "traefik.http.services.prometheus.loadbalancer.sticky=true",
        "traefik.http.services.prometheus.loadbalancer.sticky.cookie.httponly=true",
        # "traefik.http.services.prometheus.loadbalancer.sticky.cookie.secure=true",
        "traefik.http.services.prometheus.loadbalancer.sticky.cookie.samesite=strict",
      ]

      port = "prometheus_ui"

      connect {
        sidecar_service {}
      }

      check {
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "prometheus" {
      driver = "docker"

      artifact {
        # Double slash required to download just the specified subdirectory, see:
        # https://github.com/hashicorp/go-getter#subdirectories
        source = "git::https://github.com/fhemberger/nomad-demo.git//nomad_jobs/artifacts/prometheus"
      }

      config {
        image = "prom/prometheus:latest"

        cap_drop = [
          "ALL",
        ]

        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml:ro",
        ]

        ports = ["prometheus_ui"]
      }

      template {
        source        = "local/prometheus.yml.tpl"
        destination   = "local/prometheus.yml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
    
  }
  group "alertmanager" {
    ephemeral_disk {
      size    = 600
      migrate = true
    }

    network {
      mode = "bridge"
      port "alertmanager_ui" { to = 9093 }
     }
    
    service {
      name = "alertmanager"

      connect {
          sidecar_service {}
        }

    task "alertmanager" {
      driver = "docker"

      artifact {
        source = "git::https://github.com/fhemberger/nomad-demo.git//nomad_jobs/artifacts/prometheus"
      }

      config {
        image = "prom/alertmanager:latest"

        cap_drop = [
          "ALL",
        ]

        volumes = [
          "local/alertmanager.yml:/etc/alertmanager/config.yml",
        ]

        ports = [ "alertmanager_ui" ]
      }

        tags = [
          "http",
          "prometheus",
          # See: https://docs.traefik.io/routing/services/
          "traefik.http.services.alertmanager.loadbalancer.sticky=true",
          "traefik.http.services.alertmanager.loadbalancer.sticky.cookie.httponly=true",
          # "traefik.http.services.alertmanager.loadbalancer.sticky.cookie.secure=true",
          "traefik.http.services.alertmanager.loadbalancer.sticky.cookie.samesite=strict",
        ]

        port = "alertmanager_ui"

        check {
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }

  group "exporters" {
    count = 1

    network {
      mode = "bridge"
      port "consul_exporter" { to = 9107 }
    }

    task "consul-exporter" {
      driver = "docker"

      config {
        image = "prom/consul-exporter:latest"

        cap_drop = [
          "ALL",
        ]

        args = [
          "--consul.server",
          "consul.service.consul:8500",
        ]

        ports = [ "consul_exporter" ]
      }

      service {
        name = "${TASK}"
        tags = ["prometheus"]
        port = "consul_exporter"

        check {
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

