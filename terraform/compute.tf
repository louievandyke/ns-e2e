resource "aws_instance" "server" {
  ami                    = "ami-0ee8a4aed49bc258a"
  instance_type          = var.instance_type
  key_name               = module.keys.key_name
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.server_count
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  availability_zone      = var.availability_zone

  user_data = file("${path.root}/userdata/ubuntu-bionic.sh")

  # Instance tags
  tags = {
    Name           = "${local.random_name}-server-${count.index}"
    ConsulAutoJoin = "auto-join"
    SHA            = var.nomad_sha
    User           = data.aws_caller_identity.current.arn
  }
}

resource "aws_instance" "client_ubuntu_bionic_amd64" {
  #ami                    = data.aws_ami.ubuntu_bionic_amd64.image_id
  #ami                    = "ami-0ee8a4aed49bc258a"
  ami                    = "ami-058a2ccd7936e2bad"
  instance_type          = var.instance_type
  key_name               = module.keys.key_name
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.client_count_ubuntu_bionic_amd64
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  availability_zone      = var.availability_zone

  user_data = file("${path.root}/userdata/ubuntu-bionic.sh")

  # Instance tags
  tags = {
    Name           = "${local.random_name}-client-ubuntu-bionic-amd64-${count.index}"
    ConsulAutoJoin = "auto-join"
    SHA            = var.nomad_sha
    User           = data.aws_caller_identity.current.arn
  }
}

resource "aws_instance" "client_windows_2016_amd64" {
  ami                    = data.aws_ami.windows_2016_amd64.image_id
  #ami                    = "ami-02d0cffb9f5c2655b"	
  instance_type          = var.instance_type
  key_name               = module.keys.key_name
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.client_count_windows_2016_amd64
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  availability_zone      = var.availability_zone

  user_data = file("${path.root}/userdata/windows-2016.ps1")

  # Instance tags
  tags = {
    Name           = "${local.random_name}-client-windows-2016-${count.index}"
    ConsulAutoJoin = "auto-join"
    SHA            = var.nomad_sha
    User           = data.aws_caller_identity.current.arn
  }
}

resource "aws_instance" "client_windows_2019_amd64" {
  ami                    = "ami-02259e3619ab4b8ce"
  #ami                    = "ami-018dbd34974bc0884"
  #ami                    = "ami-0eb094e87f216f6d8"
  #ami                    = "ami-02d0cffb9f5c2655b"	
  instance_type          = var.instance_type
  key_name               = module.keys.key_name
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.client_count_windows_2019_amd64
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  availability_zone      = var.availability_zone

  user_data = file("${path.root}/userdata/windows-2019.ps1")

  # Instance tags
  tags = {
    Name           = "${local.random_name}-client-windows-2019-${count.index}"
    ConsulAutoJoin = "auto-join"
    SHA            = var.nomad_sha
    User           = data.aws_caller_identity.current.arn
  }
}

data "aws_ami" "ubuntu_bionic_amd64" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["nomad-e2e-*"]
  }
}

data "aws_ami" "windows_2016_amd64" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["nomad-e2e-windows-2016-amd64-*"]
  }
}

data "aws_ami" "windows_2019_amd64" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["nomad-e2e-windows-2019-amd64-*"]
  }
}
