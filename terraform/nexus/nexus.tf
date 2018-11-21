provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

resource "aws_instance" "nexus" {
  ami = "ami-9887c6e7" #centos ami

  instance_type = "t2.medium"

  tags {
    Name    = "nexus-server"
    owner   = "Eduardo Fonseca"
    projeto = "tcc"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "80"
    delete_on_termination = "true"
  }

  # We're assuming the subnet and security group have been defined earlier on

  subnet_id                   = "subnet-1435f538"
  security_groups             = ["sg-0c5736e9da88ebe09"]
  associate_public_ip_address = true
  # We're assuming there's a key with this name already
  key_name = "tcc"
  # This is where we configure the instance with ansible-playbook
  provisioner "local-exec" {
    command = "sleep 40; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos --private-key ~/Desktop/tcc.pem -i '${aws_instance.nexus.public_ip},' --extra-vars '@../../ansible/variables.yml' ../../ansible/nexus.yml"
  }
}
