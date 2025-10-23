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
      image     = var.taking_note_app_ecr_repository_uri # Correct variable name is likely var.taking_note_app_ecr_repository_uri based on your previous code
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
