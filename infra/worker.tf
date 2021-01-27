resource "aws_instance" "worker" {
  ami                    = var.ami
  instance_type          = var.type
  key_name               = aws_key_pair.main_key.key_name
  user_data              = data.template_file.worker_user_data.rendered
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.everis_sg.id]
  root_block_device {
    volume_size = var.size
  }

  tags = {
    Name = "${var.name}-worker"
  }

  # This is for security group rules
  depends_on = [aws_instance.master]
}

resource "aws_eip" "worker_eip" {
  instance = aws_instance.worker.id
  vpc      = true
}

data "template_file" "worker_user_data" {
  template = file("./user_data/worker.sh")
  vars = {
    masteraddress = aws_instance.master.public_ip
  }
}