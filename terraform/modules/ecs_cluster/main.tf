resource "aws_ecs_cluster" "taking_note_app_ecs_cluster" {
  name = "taking-note-app-ecs-cluster"
  
}

resource "aws_ecs_task_definition" "taking_note_app_task_definition" {
  family                   = "taking-note-app-task-def"
  execution_role_arn       = aws_iam_role.task_execution_role.arn # Make sure this role exists
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "2048" # Keep the increased memory

  container_definitions = jsonencode([
    {
      name      = "taking-note-app-container"
      image     = var.taking_note_app_ecr_repository_uri # Use the input variable for ECR URI
      cpu       = 512
      memory    = 1024 # You might need to adjust this based on app needs
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ],

      logConfiguration = { # Keep log configuration
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.taking_note_app_log_group.name, # Ensure this log group exists
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "taking-note-app-container"
        }
      },

      #  ADD Environment variables and Secrets for DB connection
      environment = [
        {
          "name" : "DB_ENDPOINT",
          "value" : var.db_endpoint # Lấy từ input mới
        },
        {
          "name" : "DB_NAME",
          "value" : var.db_name # Lấy từ input mới
        }
      ],
      secrets = [
        {
          "name" : "DB_USER",
          "valueFrom" : "${var.db_secret_arn}:username::" # Lấy từ input mới
        },
        {
          "name" : "DB_PASSWORD",
          "valueFrom" : "${var.db_secret_arn}:password::" # Lấy từ input mới
        }
      ]
    }
  ])
}

resource "aws_cloudwatch_log_group" "taking_note_app_log_group" {
  name = "ecs/taking-note-app-container"
  retention_in_days = 7
}

resource "aws_iam_role" "task_execution_role" {
  name = "talking-note-app-task-execution-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "task_execution_policy" {
  name        = "taking-note-app-task-execution-policy"
  description = "Policy for ECS task execution role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "secretsmanager:GetSecretValue" # Thêm quyền đọc Secret
        ],
        Resource = "*" 
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_execution_policy_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_policy.arn
}

resource "aws_ecs_service" "taking_note_app_service" {
  name            = "taking-note-app-ecs-service"
  network_configuration {
    subnets = var.ecs_subnet_ids
    security_groups = var.ecs_security_group_ids
    assign_public_ip = true
  }
  cluster         = aws_ecs_cluster.taking_note_app_ecs_cluster.id
  task_definition = aws_ecs_task_definition.taking_note_app_task_definition.arn
  desired_count   = 3
  launch_type     = "FARGATE"
  // iam_role        = aws_iam_role.foo.arn
  //depends_on      = [aws_iam_role_policy.foo]

  load_balancer {
    target_group_arn = var.taking_note_app_target_group_arn
    container_name   = "taking-note-app-container"
    container_port   = 5000
  }

}

# 1. Định nghĩa Service ECS là một mục tiêu có thể scale
resource "aws_appautoscaling_target" "ecs_service_target" {
  # Số task tối thiểu luôn chạy (ví dụ: 2 để đảm bảo HA)
  min_capacity       = 3  
  # Số task tối đa có thể scale lên
  max_capacity       = 5  # Tùy chỉnh theo dự kiến tải cao nhất
  
  # Định danh service ECS cần scale
  resource_id        = "service/${aws_ecs_cluster.taking_note_app_ecs_cluster.name}/${aws_ecs_service.taking_note_app_service.name}" 
  scalable_dimension = "ecs:service:DesiredCount" # Scale số lượng task mong muốn
  service_namespace  = "ecs" # Dịch vụ cần scale là ECS

  # Phụ thuộc vào service để đảm bảo service được tạo trước
  depends_on = [aws_ecs_service.taking_note_app_service]
}

# 2. Tạo chính sách scale theo CPU Utilization
resource "aws_appautoscaling_policy" "cpu_scaling_policy" {
  name               = "ecs-cpu-target-tracking-policy"
  policy_type        = "TargetTrackingScaling" # Loại chính sách: bám theo mục tiêu
  resource_id        = aws_appautoscaling_target.ecs_service_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_target.service_namespace

  target_tracking_scaling_policy_configuration {
    # Sử dụng chỉ số CPU trung bình của Service ECS
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    # Giữ CPU trung bình ở mức 70%
    target_value       = 70.0 
    
    # Thời gian chờ (giây) trước khi thực hiện scale-out/scale-in lần nữa
    scale_out_cooldown = 30 # Chờ 3 phút trước khi thêm task
    scale_in_cooldown  = 40 # Chờ 5 phút trước khi bớt task
  }
}

# Đặt lịch scale-out vào buổi tối (ví dụ: 19:00 giờ VN = 12:00 UTC)
resource "aws_appautoscaling_scheduled_action" "scale_out_evening" {
  name               = "scale-out-at-1900-vn"
  service_namespace  = aws_appautoscaling_target.ecs_service_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target.scalable_dimension
  
  # Cron expression: Chạy vào phút 0, giờ 12 UTC (19:00 VN), mỗi ngày
  schedule           = "cron(53 13 * * ? *)" 
  
  # Đặt số lượng task mong muốn khi đến giờ
  scalable_target_action {
    min_capacity = 4 # Buộc chạy ít nhất 4 task
    max_capacity = 4 # Buộc chạy nhiều nhất 4 task
  }
}

# Đặt lịch scale-in vào sáng sớm (ví dụ: 02:00 giờ VN = 19:00 UTC hôm trước)
resource "aws_appautoscaling_scheduled_action" "scale_in_early_morning" {
  name               = "scale-in-at-0200-vn"
  service_namespace  = aws_appautoscaling_target.ecs_service_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target.scalable_dimension
  
  # Cron expression: Chạy vào phút 0, giờ 19 UTC (02:00 VN hôm sau), mỗi ngày
  schedule           = "cron(7 16 * * ? *)" 
  
  # Đặt số lượng task mong muốn khi đến giờ
  scalable_target_action {
    min_capacity = 3 # Giảm về mức tối thiểu 2 task
    max_capacity = 3 
  }

  



}