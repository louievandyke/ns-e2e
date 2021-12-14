job "sleepy-cmd-dispatch" {
  datacenters = ["dc1"]
  type = "batch"
  parameterized {
    meta_required = ["SECONDS", "VOLUME_SOURCE"]
  }
  group "sleepy" {
    task "sleepy-cmd" {
      driver = "docker"
      config {
        # image = "mcr.microsoft.com/powershell:preview"
        # http://mcr.microsoft.com/windows/nanoserver:10.0.14393.1066
        #image = "mcr.microsoft.com/powershell"
        # docker pull mcr.microsoft.com/dotnet/framework/runtime # at least 6 or 7GB
        # mcr.microsoft.com/powershell:preview-nanoserver-1803
        image = "mcr.microsoft.com/windows/nanoserver:10.0.14393.1066"
        command = "cmd.exe"
        args = ["/K", "echo Contents of volume ${NOMAD_META_VOLUME_SOURCE} & dir c:\\mount-example & echo Sleeping ${NOMAD_META_SECONDS} & timeout /t ${NOMAD_META_SECONDS}"]
        #command = "pwsh.exe"
        #args = ["-c", "Write-Host Contents of volume ${NOMAD_META_VOLUME_SOURCE}; dir c:/mount-example; Write-Host Sleeping ${NOMAD_META_SECONDS} seconds...; Start-Sleep ${NOMAD_META_SECONDS}"]
        volumes = [
            # Use absolute paths to mount arbitrary paths on the host
            "C:\\mount-test:C:\\mount-test"
            # Use relative paths to rebind paths already in the allocation dir
            #"relative/to/task:/also/in/container"
        ]
#        mounts = [
#          # Volume mount example
#          {
#            type = "volume"
#            target = "c:/mount-example"
#            source = "${NOMAD_META_VOLUME_SOURCE}"
#            readonly = false
#          }
#        ]
      }
      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}