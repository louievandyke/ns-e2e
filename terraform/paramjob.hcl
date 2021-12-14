job "paramjob" {
#  parameterized {
#    meta_required = ["vault_policies"]
#  }
  datacenters = ["dc1"]
  type = "batch"
#  periodic {
#    // Launch every 20 seconds
#    cron = "*/5 * * * * * *"
#
#    // Do not allow overlapping runs.
#    prohibit_overlap = true
#  }
  group "group" {
    count = 1
    task "command" {
      vault {
         policies = ["mysecretpolicy"]
      }
      resources { network { port "export" {} port "exstat" { static=8080 } } }
      driver = "exec"
      config {
        command = "bash"
        args = ["-c", "sleep 300"]
      }
      template {
        data = <<EOH
                NOMAD_META_VAULT_POLICIES: {{env "NOMAD_META_VAULT_POLICIES"}}
                NOMAD_ALLOC_DIR: {{env "NOMAD_ALLOC_DIR"}}
                 NOMAD_TASK_DIR: {{env "NOMAD_TASK_DIR"}}
              NOMAD_SECRETS_DIR: {{env "NOMAD_SECRETS_DIR"}}
             NOMAD_MEMORY_LIMIT: {{env "NOMAD_MEMORY_LIMIT"}}
                NOMAD_CPU_LIMIT: {{env "NOMAD_CPU_LIMIT"}}
                 NOMAD_ALLOC_ID: {{env "NOMAD_ALLOC_ID"}}
               NOMAD_ALLOC_NAME: {{env "NOMAD_ALLOC_NAME"}}
              NOMAD_ALLOC_INDEX: {{env "NOMAD_ALLOC_INDEX"}}
                NOMAD_TASK_NAME: {{env "NOMAD_TASK_NAME"}}
               NOMAD_GROUP_NAME: {{env "NOMAD_GROUP_NAME"}}
                 NOMAD_JOB_NAME: {{env "NOMAD_JOB_NAME"}}
                       NOMAD_DC: {{env "NOMAD_DC"}}
                   NOMAD_REGION: {{env "NOMAD_REGION"}}
                    VAULT_TOKEN: {{env "VAULT_TOKEN"}}
                     GOMAXPROCS: {{env "GOMAXPROCS"}}
                           HOME: {{env "HOME"}}
                           LANG: {{env "LANG"}}
                        LOGNAME: {{env "LOGNAME"}}
              NOMAD_ADDR_export: {{env "NOMAD_ADDR_export"}}
              NOMAD_ADDR_exstat: {{env "NOMAD_ADDR_exstat"}}
                NOMAD_ALLOC_DIR: {{env "NOMAD_ALLOC_DIR"}}
                 NOMAD_ALLOC_ID: {{env "NOMAD_ALLOC_ID"}}
              NOMAD_ALLOC_INDEX: {{env "NOMAD_ALLOC_INDEX"}}
               NOMAD_ALLOC_NAME: {{env "NOMAD_ALLOC_NAME"}}
                NOMAD_CPU_LIMIT: {{env "NOMAD_CPU_LIMIT"}}
                       NOMAD_DC: {{env "NOMAD_DC"}}
               NOMAD_GROUP_NAME: {{env "NOMAD_GROUP_NAME"}}
         NOMAD_HOST_PORT_export: {{env "NOMAD_HOST_PORT_export"}}
         NOMAD_HOST_PORT_exstat: {{env "NOMAD_HOST_PORT_exstat"}}
                NOMAD_IP_export: {{env "NOMAD_IP_export"}}
                NOMAD_IP_exstat: {{env "NOMAD_IP_exstat"}}
                 NOMAD_JOB_NAME: {{env "NOMAD_JOB_NAME"}}
             NOMAD_MEMORY_LIMIT: {{env "NOMAD_MEMORY_LIMIT"}}
              NOMAD_PORT_export: {{env "NOMAD_PORT_export"}}
              NOMAD_PORT_exstat: {{env "NOMAD_PORT_exstat"}}
                   NOMAD_REGION: {{env "NOMAD_REGION"}}
              NOMAD_SECRETS_DIR: {{env "NOMAD_SECRETS_DIR"}}
                 NOMAD_TASK_DIR: {{env "NOMAD_TASK_DIR"}}
                NOMAD_TASK_NAME: {{env "NOMAD_TASK_NAME"}}
                           PATH: {{env "PATH"}}
                            PWD: {{env "PWD"}}
                          SHELL: {{env "SHELL"}}
                          SHLVL: {{env "SHLVL"}}
                           USER: {{env "USER"}}
                    VAULT_TOKEN: {{env "VAULT_TOKEN"}}
# Secret read from Vault. Vault/Nomad integration setup required
{{with secret "secret/data/hello"}}{{.Data.data.mykey}}{{end}}
  EOH
  destination = "file557.yml"
  }
    }
  }
}