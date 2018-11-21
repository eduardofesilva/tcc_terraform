provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

resource "aws_instance" "jenkins_master" {
  ami = "ami-09479453c5cde9639"

  instance_type = "t2.medium"

  tags {
    Name    = "jenkins-master"
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
  security_groups             = ["sg-0d6bf5dd41589ad85"]
  associate_public_ip_address = true
  # We're assuming there's a key with this name already
  key_name = "tcc"
  # This is where we configure the instance with ansible-playbook
  provisioner "local-exec" {
    command = "sleep 60; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user --private-key ~/Desktop/tcc.pem -i '${aws_instance.jenkins_master.public_ip},' --extra-vars '@../../ansible/variables.yml' ../../ansible/jenkins.yml"
  }
  provisioner "remote-exec" {
    inline = ["sudo cat /var/lib/jenkins/.ssh/id_rsa.pub"]

    connection {
      type        = "ssh"
      private_key = "${file("~/Desktop/tcc.pem")}"
      user        = "ec2-user"
      timeout     = "1m"
    }
  }
  provisioner "remote-exec" {
    inline = ["sudo cat /var/lib/jenkins/.ssh/id_rsa"]

    connection {
      type        = "ssh"
      private_key = "${file("~/Desktop/tcc.pem")}"
      user        = "ec2-user"
      timeout     = "1m"
    }
  }
}

data "template_file" "jenkinsfile" {
  template = "${file("~/tcc/templates/Jenkinsfile.tpl")}"

  vars {
    project_path      = "core/console-apps/NewTypesMsBuild/src/NewTypes"
    project_test_path = "core/console-apps/NewTypesMsBuild/test/NewTypesTests"
    git_repo          = "git@github.com:dotnet/samples.git"
    slack_channel     = "general"
    project_binary    = "NewTypes.dll"
    image_name        = "dotnetapp"
    build_tag         = "alpine"
    test_tag          = "test"
    dockerfile_name   = "Dockerfile.alpine-x64"
  }
}

data "template_file" "jenkinsfile_docker" {
  template = "${file("~/tcc/templates/Jenkinsfile.Docker.tpl")}"

  vars {
    project_path      = "core/console-apps/NewTypesMsBuild/src/NewTypes"
    project_test_path = "core/console-apps/NewTypesMsBuild/test/NewTypesTests"
    git_repo          = "git@github.com:dotnet/samples.git"
    slack_channel     = "general"
    project_binary    = "NewTypes.dll"
    image_name        = "dotnetapp"
    build_tag         = "alpine"
    test_tag          = "test"
    dockerfile_name   = "Dockerfile.alpine-x64"
    repo_name         = "eduardofesilva"
  }
}

resource "null_resource" "Jenkinsfile" {
  provisioner "local-exec" {
    command = "cat > Jenkinsfile << ${data.template_file.jenkinsfile.rendered}"
  }
}

resource "null_resource" "Jenkinsfile_Docker" {
  provisioner "local-exec" {
    command = "cat > Jenkinsfile.Docker << ${data.template_file.jenkinsfile_docker.rendered}"
  }
}
