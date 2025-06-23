# --------------------------
# EC2 INSTANCE
# --------------------------

resource "aws_instance" "react_app" {
  ami                         = "ami-0c101f26f147fa7fd" # Amazon Linux 2023 (us-east-1)
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet_ids.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  key_name                    = var.key_pair_name

  tags = {
    Name = "ReactAppEC2"
  }
}
