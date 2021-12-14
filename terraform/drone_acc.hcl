job "drone_acc" {
  region      = "az-us"
  datacenters = ["us-west-2"]
  type        = "service"

  vault {
    policies = ["nomad_reader"]
  }

  constraint {
    attribute = "$${attr.kernel.name}"
    value     = "linux"
  }

  constraint {
    attribute = "$${node.class}"
    operator  = "="
    value     = "spot"
  }

  group "drone_acc" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        to = 80
      }

      port "httpautoscaler" {
        to = 8080
      }
    }

    service {
      name = "drone-acc-autoscaler"
      port = "httpautoscaler"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.drone-acc-autoscaler.rule=Host(`autoscaler-acc.bmgf.io`)",
        "traefik.http.routers.drone-acc-autoscaler.entrypoints=https",
        "traefik.http.routers.drone-acc-autoscaler.tls=true",
      ]
    }

    service {
      name = "drone-acc"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.drone-acc.rule=Host(`cicd-acc.bmgf.io`)",
        "traefik.http.routers.drone-acc.entrypoints=https",
        "traefik.http.routers.drone-acc.tls=true",
      ]

      connect {
        sidecar_service {
          tags = [
            "http",
            "traefik.enable=false",
          ]

          proxy {
            upstreams {
              destination_name = "drone-acc-rds"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "drone_acc" {
      driver = "docker"

      config {
        image = "drone/drone:1.9.0"

        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
          "local/drone.key:/etc/drone.key",
        ]
      }

      template {
        data = <<EOH
AWS_ACCESS_KEY_ID="{{with secret "aws/creds/drone-acc"}}{{.Data.access_key}}{{end}}"
AWS_SECRET_ACCESS_KEY="{{with secret "aws/creds/drone-acc"}}{{.Data.secret_key}}{{end}}"
AWS_REGION="${drone_amazon_region}"
AWS_DEFAULT_REGION="${drone_amazon_region}"
DRONE_USER_CREATE="username:autoscaler,admin:true,machine:true,token:${drone_server_token}"
DRONE_GITHUB_SERVER="https://github.com"
DRONE_GITHUB_CLIENT_ID="${drone_github_client_id}"
DRONE_GITHUB_CLIENT_SECRET="${drone_github_client_secret}"
DRONE_RPC_SECRET="${rpc_secret}"
DRONE_SERVER_HOST="${drone_server_host}"
DRONE_SERVER_PROTO="https"
DRONE_AGENTS_ENABLED="true"
DRONE_DATABASE_DRIVER="postgres"
DRONE_DATADOG_ENABLED="false"
DRONE_JSONNET_ENABLED="true"
DRONE_LICENSE="/etc/drone.key"
DRONE_S3_BUCKET="${logs_s3_bucket}"
DRONE_REPOSITORY_FILTER="gatesfoundation,bmgfio"
DRONE_DATABASE_DATASOURCE="${drone_database_datasource}@{{ env "NOMAD_UPSTREAM_ADDR_drone_acc_rds" }}/droneacc?sslmode=disable"
EOH

        destination = "secrets/file.env"
        env         = true
      }

      template {
        data = <<EOH
${drone_key}
EOH

        destination = "local/drone.key"
      }
    }

    task "drone_acc_autoscaler" {
      driver = "docker"

      config {
        image = "drone/autoscaler:1.7.0"

        volumes = [
          "/var/lib/autoscaler:/data",
        ]
      }

      template {
        data = <<EOH
DRONE_POOL_MIN="${drone_pool_min}"
DRONE_POOL_MAX="${drone_pool_max}"
DRONE_SERVER_PROTO="https"
DRONE_SERVER_HOST="${drone_server_host}"
DRONE_SERVER_TOKEN="${drone_server_token}"
DRONE_AGENT_TOKEN="${drone_agent_token}"
DRONE_AMAZON_REGION="${drone_amazon_region}"
DRONE_AMAZON_SUBNET_ID="${drone_amazon_subnet_id}"
DRONE_AMAZON_SECURITY_GROUP="${drone_amazon_security_group}"
DRONE_AMAZON_SSHKEY="${drone_amazon_ssh_key}"
DRONE_AMAZON_PRIVATE_IP="true"
DRONE_AMAZON_TAGS="${drone_amazon_tags}"
DRONE_HTTP_HOST="${autoscaler_host}"
DRONE_AGENT_CONCURRENCY="${agent_concurrency}"
DRONE_AMAZON_RETRIES="5"
DRONE_INTERVAL="30s"
DRONE_AMAZON_INSTANCE="${amazon_instance}"
DRONE_DATABASE_DRIVER="postgres"
DRONE_DATABASE_DATASOURCE="${drone_database_datasource}@{{ env "NOMAD_UPSTREAM_ADDR_drone_acc_rds" }}/autoscaler?sslmode=disable"
DRONE_S3_BUCKET="${logs_s3_bucket}"
AWS_IAM="false"
AWS_ACCESS_KEY_ID="{{with secret "aws/creds/drone-acc"}}{{.Data.access_key}}{{end}}"
AWS_SECRET_ACCESS_KEY="{{with secret "aws/creds/drone-acc"}}{{.Data.secret_key}}{{end}}"
DRONE_ENABLE_REAPER="true"
DRONE_ENABLE_PINGER="true"
  EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}
