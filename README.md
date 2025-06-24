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
