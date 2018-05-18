# Create a instance of the AMI

# variable "aws_access_key" { }
# variable "aws_secret_key" { }

variable "base_ami" {
  default = "ami-0401747497a0373fe"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_availability_zone" {
  default = "a"
}

provider "aws" {
  # These seem to be reading correctly from the environment
  # If there is an issue with these not being set, these values can be set
  # directory here or could set above in the variable declaration above.

  # access_key = "${var.aws_access_key}"
  # secret_key = "${var.aws_secret_key}"

  region = "${var.aws_region}"
}

resource "aws_instance" "running_with_scissors" {
  ami                         = "${var.base_ami}"
  instance_type               = "t2.large"
  associate_public_ip_address = true
}

output "instance.ip" {
  value = "${aws_instance.running_with_scissors.public_ip}"
}

output "instance.user" {
  value = "chef"
}

output "instance.password" {
  value = "Cod3Can!"
}
