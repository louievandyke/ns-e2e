locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "latest_windows_2019" {
  ami_name       = "nomad-e2e-windows-2019-amd64-${local.timestamp}"
  communicator   = "ssh"
  instance_type  = "t2.medium"
  region         = "us-east-1"
  user_data_file = "windows-2019-amd64/userdata.ps1" # enables ssh
  ssh_timeout    = "10m"
  ssh_username   = "Administrator"
  source_ami     = "ami-02e188c5eabfa5c8d"
  tags = {
    OS = "Windows2019"
  }
}

build {
  sources = ["source.amazon-ebs.latest_windows_2019"]

  provisioner "powershell" {
    scripts = [
      "windows-2019-amd64/disable-windows-updates.ps1",
      "windows-2019-amd64/fix-tls.ps1",
      "windows-2019-amd64/install-nuget.ps1"
    ]
  }

  provisioner "file" {
    destination = "/opt"
    source      = "../config"
  }

  provisioner "file" {
    destination = "/opt/provision-2019.ps1"
    source      = "./windows-2019-amd64/provision-2019.ps1"
  }

  provisioner "file" {
    destination = "/opt/install-nomad.ps1"
    source      = "./windows-2019-amd64/install-nomad.ps1"
  }

  provisioner "file" {
    destination = "/opt/install-consul.ps1"
    source      = "./windows-2019-amd64/install-consul.ps1"
  }

  provisioner "file" {
    destination = "/opt/install-docker.ps1"
    source      = "./windows-2019-amd64/install-docker.ps1"
  }

  provisioner "file" {
    destination = "/opt/IISCryptoCli.exe"
    source      = "./windows-2019-amd64/IISCryptoCli.exe"
  }

  provisioner "powershell" {
    inline = ["/opt/provision-2019.ps1 -nomad_version 1.2.6 -nostart"]
  }

  provisioner "powershell" {
    inline = ["/opt/IISCryptoCli.exe /template default"]
  }

  # this restart is required for adding the "containers feature", but we can
  # wait to do it until right before we do sysprep, which makes debugging
  # builds slightly faster
  provisioner "windows-restart" {}

  provisioner "powershell" {
    inline = [
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SendWindowsIsReady.ps1 -Schedule",
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule",
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SysprepInstance.ps1 -NoShutdown",
    ]
  }
}
