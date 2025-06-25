# Secure and Automated CI/CD Deployment of a React App with Secrets Management on AWS

## 📌 Project Overview

This project demonstrates how to securely automate the deployment of a React application using a modern DevOps stack. It includes infrastructure provisioning with Terraform, containerization with Docker, continuous integration with GitHub Actions, secure auto-deployment via webhook on AWS EC2, and secret management best practices.

## 📊 Architecture Diagram (ASCII)

```ascii
+-------------+         Push Event          +------------------+
|  Developer  | -------------------------> |  GitHub Actions  |
+-------------+                            +--------+---------+
                                                     |
                                                     | Docker Build & Push
                                                     v
                                           +--------------------------+
                                           |    Docker Hub Registry   |
                                           +------------+-------------+
                                                        |
                      GitHub Webhook (HTTP POST)        |
                                                        v
+------------------+   Trigger Auto-deploy   +--------------------------+
|   EC2 Instance   | <---------------------- |   GitHub Webhook System  |
| (Amazon Linux 2) |                         +--------------------------+
| Docker + Webhook |  Pull Image & Restart
+------------------+
```

## 🛠️ Tech Stack Used

- **AWS Free Tier**: EC2, IAM
    
- **Terraform**: Infrastructure as Code
    
- **Docker**: Containerized the React app
    
- **GitHub Actions**: CI/CD pipeline
    
- **Docker Hub**: Container registry
    
- **Webhook**: Lightweight HTTP listener for auto-deploy

## 🎯 Objectives

- Deploy a React app on AWS EC2 using CI/CD
    
- Automate infrastructure provisioning
    
- Apply cybersecurity best practices (IAM, secrets management)
    
- Use only AWS Free Tier resources to avoid billing

## 📁 Folder Structure

```ascii
secure-and-automated-cicd/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── vpc.tf
│   ├── ec2.tf
│   ├── security.tf
│   ├── iam.tf
│   ├── outputs.tf
├── react-app/
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   ├── package.json
│   └── ...
├── .github/workflows/
│   └── deploy.yml
├── deploy.sh
├── hooks.json
└── README.md
```

## ✅ Step-by-Step Reproduction
### 🔐 1. Generate SSH Key Pair in AWS Console

- Navigate to EC2 → Key Pairs → Create Key Pair (RSA or ED25519)

> I decided to use ED25519  for this project since is faster and more efficient for modern applications.
    
- Download `.pem` file securely for SSH

-  Change the file permission for the key pair

```bash
chmod 400 key-pair-name-ed25519.pem
```

### 🌍 2. Create The Terraform Infrastructure

-  variables.tf:

```hcl
# --------------------------
# VARIABLES
# --------------------------

variable "my_ip" {
  description = "Your public IP address"
  type        = string
}

variable "key_pair_name" {
  description = "Name of existing AWS EC2 key Pair"
  type        = string
}

variable "react_api_key" {
  description = "Fake or real API key for React App"
  type        = string
  sensitive   = true
}
```

-  provider.tf:

```hcl
# --------------------------
# PROVIDER AND REGION SETUP
# --------------------------

provider "aws" {
  region = "us-east-1"
}
```

-  vpc.tf:

```hcl
# --------------------------
# DATA SOURCES: USE DEFAULT VPC & SUBNETS
# --------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
```

-  iam.tf:

```hcl
# --------------------------
# IAM ROLE FOR EC2 INSTANCE
# --------------------------

resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2_ssm_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_policy" {
  name = "ssm-read-only"
  role = aws_iam_role.ec2_ssm_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:DescribeParameters"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_ssm_profile"
  role = aws_iam_role.ec2_ssm_role.name
}
```

-  security.tf:

```hcl
# --------------------------
# SECURITY GROUP FOR EC2
# --------------------------

resource "aws_security_group" "web_sg" {
  name        = "web-secgroup"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Webhook"
    from_port = 9000
    to_port = 9000
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
```

-  ec2.tf:

```hcl
# --------------------------
# EC2 INSTANCE
# --------------------------

resource "aws_instance" "react_app" {
  ami                         = "ami-0c101f26f147fa7fd" # Amazon Linux 2023 (us-east-1)
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  key_name                    = var.key_pair_name

  tags = {
    Name = "ReactAppEC2"
  }
}
```

-  ssm.tf:

```hcl
# --------------------------
# SECRET PARAMETER IN SSM
# --------------------------

resource "aws_ssm_parameter" "react_secret" {
  name  = "/react-app/api-key"
  type  = "SecureString"
  value = var.react_api_key
}
```

-  outputs.tf:

```hcl
# --------------------------
# OUTPUTS
# --------------------------

output "instance_public_ip" {
  value = aws_instance.react_app.public_ip
}

output "instance_id" {
  value = aws_instance.react_app.id
}
```

-  terraform.tfvars:

```hcl
my_ip         = "INSERT_YOUR_PUBLIC_IP_HERE"
key_pair_name = "INSERT_YOUR_KEYPAIR_NAME_HERE"
react_api_key = "INSERT_YOUR_REAL_OR_FAKE_API_HERE"
```

-  To get your public IP so it can be used in the **terraform.tfvars** for communication between your aws ec2 instance and your local machine you can visit the following website **[What Is My IP Address](https://whatismyipaddress.com/)** or your can run the following command on your terminal:

```bash
curl ifconfig.me
```

-  Deploy the Infrastructure:

```bash
terraform init
terraform plan
terraform apply
```

-  Resources created:

	-  EC2 instance
	-  Security groups
	-  IAM roles
	-  Parameter Store ssm

### 🐳 3. Prepare Docker Environment

Place the `Dockerfile` inside your `react-app/`:

```Dockerfile
# Dockerfile for the calculator-app

  FROM node:20-alpine AS builder
  WORKDIR /app
  COPY . .
  RUN npm install && npm run build

  FROM nginx:alpine
  COPY --from=builder /app/dist /usr/share/nginx/html

  EXPOSE 80
  CMD ["nginx", "-g", "daemon off;"]
```

### 🔧 4. Setup GitHub Actions for CI/CD to Docker Hub

### 🧭 Goal:

- On each push to `main`, build the Docker image
    
- Tag it properly
    
- Push it to Docker Hub

### 🐳 Step 1: Create an Access Token in Docker Hub

In your Dockerhub account:

1. Sign in to your **[Docker account](https://app.docker.com/)**.

2. Select your avatar in the top-right corner and from the drop-down menu select **Account settings**.

3. Select **Personal access tokens**.

4. Select **Generate new token**.

5. Add a description for your token. Use something that indicates the use case or purpose of the token.

6. Select the expiration date for the token.

7. Set the access permissions. For this project will set the permissions as **Read & Write**, this will allow the token to be use for automation pipeline that can build and image and push it to a repository.

8. Select **Generate** and then copy the token that appears on the screen and save it. You won't be able to retrieve the token once you close this prompt.

### 🔐 Step 2: Add Secrets to GitHub Repository

In your GitHub repo:

1. Go to **Settings → Secrets and variables → Actions**
    
2. Add the following:
    
    - `DOCKER_USERNAME` → your Docker Hub username
        
    - `DOCKER_PASSWORD` → your Docker Hub access token
        

Create the following directory:

```bash
mkdir -p .github/workflows/
```

**deploy.yml** inside `.github/workflows/`:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Log in to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build and Push Docker image
      uses: docker/build-push-action@v5
      with:
        context: ./CappuccinoCalculator
        file: ./CappuccinoCalculator/Dockerfile
        push: true
        tags: ${{ secrets.DOCKER_USERNAME }}/cappuccino-calculator-app:latest
```

### 🧭 5. SSH Into the EC2 Instance

Here we are going to validate that the EC2 instance and all the aws resources are up and running, and prepare the instance to host the app.

### 🧑‍💻 Step 1: SSH Into the Instance

Use this command:

```bash
ssh -i key-pair-ed25519.pem ec2-user@<PUBLIC-IP>
```

Replace `<PUBLIC-IP>` with your public IP from your EC2 instance.

### ✅ Step 2: Verify the EC2 Role & SSM Access

Once inside the instance, test that you can access the SSM parameter:

```bash
aws ssm get-parameter --name "/react-app/api-key" --with-decryption
```

If that works that means that your IAM role and SSM access have been configured correctly.

### 📦 Step 3: Install Docker on the EC2 Instance

Run the following commands to install Docker:

```bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
```

Log out and log back in to apply group permissions.

### 🚀 6. Setup Webhook on EC2

Now we are going to set up a webhook in the EC2 instance that will do the following:

-  Detect a new image pushed to Docker Hub

-  Pull the new image

-  Restart the container automatically

### 🔧 Step 1: Install `webhook` on EC2

SSH into your EC2 instance if you are not already there and run:

```bash
# Download the latest release
wget https://github.com/adnanh/webhook/releases/download/2.8.1/webhook-linux-amd64.tar.gz

# Extract and install
tar -xvzf webhook-linux-amd64.tar.gz
sudo mv webhook-linux-amd64/webhook /usr/local/bin/
sudo chmod +x /usr/local/bin/webhook

# Test it works
webhook --version
```

### 📜 Step 2: Create `deploy.sh`

This script will:

- Pull the latest Docker image from Docker Hub
    
- Restart the container
    

Save this as: `/home/ec2-user/deploy.sh`

```bash
#!/bin/bash

APP_NAME=cappuccino-calculator-app # make sure to replace with your app name
IMAGE_TAG=latest
DOCKER_USER=yourdockerhubusername   # make sure to change this with your own Docker user name

echo "Pulling latest image..."
docker pull $DOCKER_USER/$APP_NAME:$IMAGE_TAG

echo "Stopping current container..."
docker stop $APP_NAME || true
docker rm $APP_NAME || true

echo "Starting new container..."
docker run -d \
  --name $APP_NAME \
  -p 80:80 \
  $DOCKER_USER/$APP_NAME:$IMAGE_TAG

echo "✅ Deployment complete."

```

Make it executable:

```bash
chmod +x /home/ec2-user/deploy.sh
```

### ⚙️ Step 3: Create `hooks.json`

Generate a strong random token locally

You can generate a secure token using this command:

- **Linux/macOS terminal:**

```bash
openssl rand -hex 20
```

Copy and paste the token in **passphrase** field in the following `hooks.json` script.

Save this as: `/home/ec2-user/hooks.json`

```json
[
  {
    "id": "deploy-react-app",
    "execute-command": "/home/ec2-user/deploy.sh",
    "command-working-directory": "/home/ec2-user",
    "passphrase": "YOUR_SECRET_TOKEN"
  }
]
```