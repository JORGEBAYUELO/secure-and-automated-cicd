# --------------------------
# SECRET PARAMETER IN SSM
# --------------------------

resource "aws_ssm_parameter" "react_secret" {
  name  = "/react-app/api-key"
  type  = "SecureString"
  value = var.react_api_key
}
