locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "latest_windows_2016" {
  ami_name       = "nomad-e2e-windows-2019-amd64-${local.timestamp}"
  communicator   = "ssh"
  instance_type  = "t2.medium"
  region         = "us-east-1"
  user_data_file = "windows-2016-amd64/userdata.ps1" # enables ssh
  ssh_timeout    = "10m"
  ssh_username   = "Administrator"

  source_ami_filter {
    filters = {
      name                = "Windows_Server-2019-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  tags = {
    OS = "Windows2019"
  }
}

build {
  sources = ["source.amazon-ebs.latest_windows_2016"]

  provisioner "powershell" {
    scripts = [
      "windows-2019-amd64/disable-windows-updates.ps1",
      "windows-2019-amd64/fix-tls.ps1",
      "windows-2019-amd64/install-nuget.ps1",
      "windows-2019-amd64/install-docker.ps1"
    ]
  }

  provisioner "file" {
    destination = "/opt"
    source      = "../config"
  }

  provisioner "file" {
    destination = "/opt/provision.ps1"
    source      = "./windows-2016-amd64/provision.ps1"
  }

  provisioner "powershell" {
    inline = ["/opt/provision.ps1 -nomad_version 1.2.6 -nostart"]
  }

  # this restart is required for adding the "containers feature", but we can
  # wait to do it until right before we do sysprep, which makes debugging
  # builds slightly faster
  provisioner "windows-restart" {}

  provisioner "powershell" {
    inline = [
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SendWindowsIsReady.ps1 -Schedule",
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule",
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SysprepInstance.ps1 -NoShutdown"
    ]
  }
}
