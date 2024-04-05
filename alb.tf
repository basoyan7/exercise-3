resource "aws_lb" "alb" {
  name               = "My-Site-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.my_sub0.id, aws_subnet.my_sub1.id]
}

resource "aws_lb_target_group" "s3_target_group" {
  name        = "My-Site-ALB-TG"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "ip"
  health_check {
    port                = 80
    protocol            = "HTTP"
    path                = "/"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200,307,405"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.s3_target_group.arn
  }
}

locals {
  ids = tolist(aws_vpc_endpoint.s3_endpoint.network_interface_ids)
}

data "aws_network_interface" "eni1" {
  id = local.ids[0]
}

data "aws_network_interface" "eni2" {
  id = local.ids[1]
}

resource "aws_lb_target_group_attachment" "s3_target_attachment_1" {
  target_group_arn = aws_lb_target_group.s3_target_group.arn
  target_id        = data.aws_network_interface.eni1.private_ip
}

resource "aws_lb_target_group_attachment" "s3_target_attachment_2" {
  target_group_arn = aws_lb_target_group.s3_target_group.arn
  target_id        = data.aws_network_interface.eni2.private_ip
}

