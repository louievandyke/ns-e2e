job "internal-webserver-dev-1616430452" {
  datacenters = ["dc1"]
  type        = "service"
  region      = "global"
  priority    = 50

  update {
    stagger      = "30s"
    max_parallel = 1
  }

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "internal-web-app" {
    count = 1

    constraint {
      distinct_hosts = "true"
    }

    network {
      mode = "bridge"

      port "https" {
        static = 443
      }

      port "stats" {
        to = 80
      }

      port "cobalt" {}
    }

    restart {
      attempts = 2
      delay    = "15s"
      interval = "1m"
      mode     = "delay"
    }

    ephemeral_disk {
      size = 200
    }

    task "internal-webserver-service" {
      logs {
        max_files     = 10
        max_file_size = 10
      }

      driver = "docker"

      config {
        image = "docker-dev-repo.cobalt.only.sap/ariba-cobalt-internal-webserver/internal-webserver:dev"

        auth {
          username = "readonly"
          password = "readonly"
        }

        labels {
          job_name            = "${NOMAD_JOB_NAME}"
          task_name           = "${NOMAD_TASK_NAME}"
          group_name          = "${NOMAD_GROUP_NAME}"
          alloc_name          = "${NOMAD_ALLOC_NAME}"
          pod_id              = "dev"
          cobalt_id           = "${NOMAD_JOB_NAME}"
          cobalt_service_name = "${NOMAD_TASK_NAME}"
          cobalt_podid        = "dev"
        }
      }

      env {
        LANG         = "en_US.UTF-8"
        LANGUAGE     = "en_US.UTF-8"
        LC_ALL       = "en_US.UTF-8"
        CLUSTER_NAME = "dc1"
        COBALT_ID    = "internal-webserver-dev-1616430452"
        COBALT_PODID = "dev"
        BUILD_NUMBER = "dev"
        DOMAIN_NAME  = "consul."
        SVC_EXT      = ".service"
        BUILD_URL    = ""
        DEPLOYED_BY  = ""
      }

      resources {
        cpu    = 500 # MHz
        memory = 512 # MB
      }
    }
  }
}