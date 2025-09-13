output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.my_ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.my_ec2.public_dns
}

output "my_vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.my_vpc.id
}

output "my_subnet_id" {
  description = "ID of the Subnet"
  value       = aws_subnet.my_subnet.id
}

# Output repository URL (used in Jenkins pipeline)
output "ecr_repository_url" {
  value = aws_ecr_repository.node_app_repo.repository_url
}