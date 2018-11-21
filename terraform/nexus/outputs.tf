output "jenkins_ip" {
  value = "${aws_instance.nexus.public_ip}"
}

output "jenkins_dns" {
  value = "${aws_instance.nexus.public_dns}"
}
