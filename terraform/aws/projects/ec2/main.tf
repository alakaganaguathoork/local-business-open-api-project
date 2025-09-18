# Network
resource "aws_vpc" "ec2-project" {
  cidr_block = var.vpc_cidr_block
    
  tags = {
    Name = "ec2-project-${var.env}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ec2-project.id
}

resource "aws_subnet" "public_subnet" {
  for_each = var.apps

  vpc_id = aws_vpc.ec2-project.id
  cidr_block = each.value["subnet_cidr"]
  map_public_ip_on_launch = true
  availability_zone = each.value["availability_zone"]
}

# Routing
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.ec2-project.id
}

resource "aws_route_table_association" "rt-assoc" {
  for_each = var.apps

  route_table_id = aws_route_table.rt.id
  subnet_id = aws_subnet.public_subnet[each.key].id
}

resource "aws_route" "public-subnet-route" {
  gateway_id = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
}

# Security groups
module "security_groups" {
  source = "../../modules/networking/security-group"
  vpc_id = aws_vpc.ec2-project.id
  security_groups = var.security_groups
}

# Application Load Balancer
resource "aws_alb" "alb" {
  name = "main-alb"
  load_balancer_type = "application"
  subnets = values(aws_subnet.public_subnet)[*].id
  security_groups = [module.security_groups.sg["alb-sg"].id]
}

resource "aws_lb_target_group" "tg" {
  name     = "main-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.ec2-project.id

  health_check {
    path                = "/"
    port                = "8080"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  for_each = aws_instance.main

  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = each.value.id
  port             = 8080
}

# Instance
data "aws_ami" "amazon_linux2" {
  most_recent = true  # Always return the single most recent matching image
  owners = ["amazon"] # Owner “amazon” publishes official Amazon Linux 2 AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "main" {
  for_each = var.apps
  
  ami                    = data.aws_ami.amazon_linux2.id
  instance_type          = each.value["instance_type"]
  subnet_id              = aws_subnet.public_subnet[each.key].id
  vpc_security_group_ids = [ module.security_groups.sg["ec2-sg"].id ]
  availability_zone      = each.value["availability_zone"]

  key_name = aws_key_pair.personal.key_name
  
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras enable python3.8
    yum install -y python3 git
    pip3 install flask
    cat <<EOPY > /home/ec2-user/app.py
    from flask import Flask
    app = Flask(__name__)
    @app.route("/")
    def hello():
        return "Hello from Python app on EC2!"
    if __name__ == "__main__":
        app.run(host="0.0.0.0", port=8080)
    EOPY
    nohup python3 /home/ec2-user/app.py &
  EOF
}

resource "aws_key_pair" "personal" {
  key_name   = "personal-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
