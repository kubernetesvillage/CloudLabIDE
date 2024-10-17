# main.tf

provider "aws" {
  region = var.region
}

# Variables
variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-west-2"
}

variable "ami_parameter_store_name" {
  description = "AMI Parameter Store Name"
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

variable "code_server_version" {
  description = "Version of Code Server to use"
  default     = "4.91.1"
}

variable "stack_name" {
  description = "The name of the CloudFormation stack"
  default     = "eks-workshop"
}

# Generate a random suffix for the secret name
resource "random_string" "secret_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Secrets Manager for VSCode Password
resource "aws_secretsmanager_secret" "vscode_password" {
  name = "${var.stack_name}-password-secret-${random_string.secret_suffix.result}"
}

resource "random_password" "vscode_password" {
  length  = 32
  special = false


}

resource "aws_secretsmanager_secret_version" "vscode_password_value" {
  secret_id     = aws_secretsmanager_secret.vscode_password.id
  secret_string = jsonencode({
    password = random_password.vscode_password.result
  })
}

# VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks_vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks_igw"
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {}

# Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
}

# Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "public_route_table"
  }
}

# Internet Gateway Route
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Route Table Association
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Data source to get CloudFront's managed prefix list
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# Security Group
resource "aws_security_group" "ide_security_group" {
  vpc_id = aws_vpc.eks_vpc.id

  # Allow HTTP from CloudFront
  ingress {
    description     = "Allow HTTP from CloudFront"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }

  # Allow traffic on port 1337 from all IPs
  ingress {
    description = "Allow all traffic on port 1337"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ide_sg"
  }
}

# IAM Role for EC2 Instance
resource "aws_iam_role" "ide_instance_role" {
  name = "eks-workshop-ide-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = ["ec2.amazonaws.com", "ssm.amazonaws.com"]
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for EC2 to access Secrets Manager
resource "aws_iam_policy" "secretsmanager_access" {
  name   = "EksWorkshopIdeSecretsManagerPolicy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = aws_secretsmanager_secret.vscode_password.arn
      }
    ]
  })
}

# Attach policies to EC2 instance role
resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.ide_instance_role.name
  policy_arn = aws_iam_policy.secretsmanager_access.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ide_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach AdministratorAccess policy to EC2 instance role
resource "aws_iam_role_policy_attachment" "ec2_admin_access_attach" {
  role       = aws_iam_role.ide_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ide_instance_profile" {
  name = "eks_workshop_ide_instance_profile"
  role = aws_iam_role.ide_instance_role.name
}

# SSM Parameter for AMI
data "aws_ssm_parameter" "ami" {
  name = var.ami_parameter_store_name
}

# EC2 Instance for code-server
resource "aws_instance" "eks_instance" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ide_security_group.id]
  iam_instance_profile        = aws_iam_instance_profile.ide_instance_profile.id
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e
    yum install -y git tar gzip vim nodejs npm make gcc g++ awscli jq yum-utils less
    curl -Ls -o /tmp/coderinstall.rpm https://github.com/coder/code-server/releases/download/v4.91.1/code-server-4.91.1-amd64.rpm
    sudo rpm -U "/tmp/coderinstall.rpm"
    systemctl enable code-server@ec2-user
    PASSWORD_SECRET=$(aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.vscode_password.id} --query 'SecretString' --output text)
    IDE_PASSWORD=$(echo "$PASSWORD_SECRET" | jq -r '.password')
    HASHED_PASSWORD=$(echo -n "$IDE_PASSWORD" | npx argon2-cli -e)
    sudo -u ec2-user mkdir -p /home/ec2-user/.config/code-server/
    sudo -u ec2-user touch /home/ec2-user/.config/code-server/config.yaml

    sudo -u ec2-user bash << EOF_USER
    cat << 'CONFIG_EOF' > /home/ec2-user/.config/code-server/config.yaml
    bind-addr: 0.0.0.0:8080
    auth: password
    hashed-password: "$HASHED_PASSWORD"
    cert: false
    CONFIG_EOF
    EOF_USER
    # Start code-server service
    systemctl start code-server@ec2-user
  EOF

  tags = {
    Name = "eks-workshop-ide"
  }
}

# CloudFront Distribution for code-server Access
resource "aws_cloudfront_distribution" "vscode_distribution" {
  origin {
    domain_name = aws_instance.eks_instance.public_dns
    origin_id   = "eks-vscode-origin"

    custom_origin_config {
      http_port              = 8080
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled = true

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "eks-vscode-origin"
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }

      headers = ["*"]
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "eks-workshop-cloudfront"
  }
}

# Output CloudFront URL and Secrets Manager URL
output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.vscode_distribution.domain_name}"
}

output "secrets_manager_url" {
  value = "https://console.aws.amazon.com/secretsmanager/home?region=${var.region}#/secret?name=${aws_secretsmanager_secret.vscode_password.name}"
}
