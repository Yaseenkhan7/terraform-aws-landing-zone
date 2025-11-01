# This module deploys a standard 3-tier IaaS application stack.

variable "application_name" {
  description = "A unique name for the application (e.g., 'my-awesome-app')."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the application into."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs for the Application Load Balancer."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the application instances."
  type        = list(string)
}

variable "ami_id" {
  description = "The AMI ID for the application instances. Should be a 'Golden AMI'."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type for the application servers."
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "The port the application listens on."
  type        = number
  default     = 8080
}

variable "min_instances" {
  description = "The minimum number of instances for the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "max_instances" {
  description = "The maximum number of instances for the Auto Scaling Group."
  type        = number
  default     = 5
}

# --- Security Groups ---

resource "aws_security_group" "alb_sg" {
  name        = "${var.application_name}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "${var.application_name}-app-sg"
  description = "Security group for the Application Instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Application Load Balancer ---

resource "aws_lb" "main" {
  name               = "${var.application_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "main" {
  name     = "${var.application_name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# --- Auto Scaling Group ---

resource "aws_launch_template" "main" {
  name_prefix   = "${var.application_name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    security_groups = [aws_security_group.app_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.application_name}-instance"
    }
  }
}

resource "aws_autoscaling_group" "main" {
  name                = "${var.application_name}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  desired_capacity    = var.min_instances
  min_size            = var.min_instances
  max_size            = var.max_instances

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.main.arn]
}

# --- Outputs ---

output "alb_dns_name" {
  description = "The DNS name of the application load balancer."
  value       = aws_lb.main.dns_name
}
