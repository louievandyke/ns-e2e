job "ig1" {
  datacenters = ["dc1"]

  group "ingress-group1" {

    network {
      mode = "bridge"

      port "inbound" {
        static = 9090
        to = 9090
      }
    }

    service {
      name = "ig1-ingress"
      port = "9090"

      connect {
        gateway {

          # Consul gateway [envoy] proxy options.
          proxy {
            connect_timeout = "500ms"
          }

          ingress {
            listener {
              port     = 9090
              protocol = "http"
              service {
                name = "computetools-dev-nginx1"
                 hosts = ["172.31.26.251"]
              }
            }
          }
        }
      }
    }
  }
}