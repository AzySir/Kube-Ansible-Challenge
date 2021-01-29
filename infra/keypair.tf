# SSH Key for EC2 Instances
resource "aws_key_pair" "main_key" {
  key_name   = "everischallenge"
  public_key = var.key
}
