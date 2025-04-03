resource "aws_autoscaling_group" "app_asg" {
  count                     = var.vpc_count
  name                      = "app-asg-${var.vpc_name}-${count.index}"
  min_size                  = var.min_capacity_asg
  max_size                  = var.max_capacity_asg
  desired_capacity          = var.des_capacity_asg
  default_cooldown          = 60
  health_check_type         = var.health_check_type
  health_check_grace_period = 300
  vpc_zone_identifier       = [for i in range(length(var.availability_zones)) : aws_subnet.public_subnets[count.index * length(var.availability_zones) + i].id]
  target_group_arns         = [aws_lb_target_group.app_tg[count.index].arn]

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Webapp-Instance-${var.vpc_name}"
    propagate_at_launch = true
  }
}

# Scale up policy
resource "aws_autoscaling_policy" "scale_up" {
  count                  = var.vpc_count
  name                   = "scale-up-policy-${count.index}"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg[count.index].name
}

# Scale down policy
resource "aws_autoscaling_policy" "scale_down" {
  count                  = var.vpc_count
  name                   = "scale-down-policy-${count.index}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg[count.index].name
}

# CloudWatch Alarm for high CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count               = var.vpc_count
  alarm_name          = "high-cpu-alarm-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.period
  statistic           = "Average"
  threshold           = var.scale_up_threshold
  alarm_description   = "Scale up if CPU utilization is above 6.85%"
  alarm_actions       = [aws_autoscaling_policy.scale_up[count.index].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg[count.index].name
  }
}

# CloudWatch Alarm for low CPU
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  count               = var.vpc_count
  alarm_name          = "low-cpu-alarm-${count.index}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.period
  statistic           = "Average"
  threshold           = var.scale_down_threshold
  alarm_description   = "Scale down if CPU utilization is below 6.25%"
  alarm_actions       = [aws_autoscaling_policy.scale_down[count.index].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg[count.index].name
  }
}