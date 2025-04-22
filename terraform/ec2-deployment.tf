resource "aws_instance" "ec2-deployment" {
    ami = "ami-05b10e08d247fb927"
    instance_type = "t2.micro"

    availability_zone = "us-east-1a"

    key_name = aws_key_pair.ssh_key.key_name

    user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nmap python3-pip docker
              systemctl start docker
              systemctl enable docker
              pip3 install ansible
              EOF
            )

    security_groups = [aws_security_group.ec2-sg.name]

    depends_on = [aws_security_group.ec2-sg, aws_key_pair.ssh_key]
}

resource "aws_default_vpc" "default" {
}

resource aws_security_group "ec2-sg" {
    name = "EC2-Deployment-SG"
    vpc_id = aws_default_vpc.default.id

    ingress {
        description = "TLS from VPC"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "tls_private_key" "this" {
   algorithm = "ED25519"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "id_ed25519.pem"
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_sensitive_file" "pem_file" {
  filename = "${path.module}/${aws_key_pair.ssh_key.key_name}"
  content = tls_private_key.this.private_key_openssh
  file_permission = "0400"

}

resource local_file "ip_addr" {
    filename = "ip.txt"
    content = aws_instance.ec2-deployment.public_ip
    depends_on = [aws_instance.ec2-deployment]
}

output "vpc-id" {
    value = "${aws_default_vpc.default.id}"
}
