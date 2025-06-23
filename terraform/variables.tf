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
