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
