# Get latest Amazon Linux 2023 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  subnet_id = aws_subnet.private_app[0].id

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  associate_public_ip_address = false

  user_data = <<-EOF
  #!/bin/bash
  set -eux

  apt-get update -y
  apt-get install -y docker.io

  systemctl enable docker
  systemctl start docker

  docker run -d \
    --name nginx \
    --restart unless-stopped \
    -p 80:80 \
    nginx:alpine
EOF

  user_data_replace_on_change = true

  depends_on = [
    aws_route.private_app_nat
  ]

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
  }
}

# Register EC2 instance in ALB target group
resource "aws_lb_target_group_attachment" "app_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 80
}