provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

resource "aws_instance" "jenkins_master" {
  ami = "ami-0ff8a91507f77f867"

  instance_type = "t2.medium"

  tags {
    Name    = "jenkins-master"
    owner   = "Eduardo Fonseca"
    projeto = "tcc"
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
    command = "cat > Jenkinsfile <<EOL${data.template_file.jenkinsfile.rendered}EOL"
  }
}

resource "null_resource" "Jenkinsfile_Docker" {
  provisioner "local-exec" {
    command = "cat > Jenkinsfile.Docker <<EOL${data.template_file.jenkinsfile_docker.rendered}EOL"
  }
}
