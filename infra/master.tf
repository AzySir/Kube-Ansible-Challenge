resource "aws_instance" "master" {
  ami                    = var.ami
  instance_type          = var.type
  key_name               = aws_key_pair.main_key.key_name
  user_data              = file("./user_data/master.sh")
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.everis_sg.id]
  root_block_device {
    volume_size = var.size
  }

  tags = {
    Name = "${var.name}-master"
  }
}

resource "aws_eip" "master_eip" {
  instance = aws_instance.master.id
  vpc      = true
}