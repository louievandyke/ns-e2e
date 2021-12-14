job "countdash" {
  datacenters = ["dc1"]

  group "api" {
    network {
      mode = "bridge"
    }

    service {
      name = "count-api"
      port = "9001"

      #connect {
        #sidecar_service = {}

        #sidecar_task {
          #name = "filebeat"

          #driver = "docker"
          #config {
           # image = "docker.elastic.co/beats/filebeat:7.9.3"
          #}

          #logs {
           # max_files     = 2
           # max_file_size = 2 # MB
          #}

          #resources {
           # cpu    = 500
           # memory = 1024
         # }
       # }
      #}
    }

    task "web" {
      driver = "docker"

      config {
        image = "hashicorpnomad/counter-api:v2"
      }
    }
  }
}