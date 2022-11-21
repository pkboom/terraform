output "app_eip" {
  # *: return all of public_ip
  # In our case, it's 0,1 but in other cases, it could be 0,1,2,3,4,5,6,7,8,9
  value = aws_eip.cloudcasts_addr.*.public_ip
}

output "app_instance" {
  value = aws_instance.cloudcasts_web.id
}
