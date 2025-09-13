
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for Subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_availability_zone" {
  description = "AZ for the subnet"
  type        = string
  default     = "ap-south-1b"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ec2_ami_id" {
  description = "AMI ID for EC2"
  type        = string
  default     = "ami-02d26659fd82cf299" 
}

variable "disk_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 25
}