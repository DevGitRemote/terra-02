provider "aws" {
  region = "us-east-1"
  secret_key = ""
  access_key = ""
  }

resource "aws_vpc" "vpc-project" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = "1"
  enable_dns_hostnames = "1"
  tags = {
  Name = "vpc-project"
  }
 }
 
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc-project.id}" 
  tags = {
  Name = "igw"
  }
 }

resource "aws_instance" "controller" {
  ami = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet1.id}"
  user_data = <<-EOL
  sudo apt update -y
  EOL
  tags = {
  Name = "controller"
  }
 }

resource "aws_instance" "kube-master" {
  ami = "ami-007855ac798b5175e"
  instance_type ="t2.medium"
  subnet_id = "${aws_subnet.subnet1.id}"
  user_data = <<-EOL
  sudo apt update -y
  EOL
  tags = {
  Name = "kube-master"
  }
 }
 
resource "aws_instance" "kube-node1" {
  ami = "ami-007855ac798b5175e"
  instance_type = "t2.medium"
  subnet_id = "${aws_subnet.subnet1.id}"
  user_data = <<-EOL
  sudo apt update -y
  EOL
  tags = {
  Name = "kube-node1"
  }
 }
 
resource "aws_subnet" "subnet1" {
  vpc_id = "${aws_vpc.vpc-project.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.0.32.0/19"
  map_public_ip_on_launch = "1"
  tags = {
  Name = "public_subnet"
  }
 }
 
resource "aws_default_security_group" "sg" {
  ingress {
    from_port = "0"
	to_port = "0"
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
	}
  
  egress {
    from_port = "0"
	to_port = "0"
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
	}
  
  vpc_id = "${aws_vpc.vpc-project.id}"
  tags = {
  Name = "allow-all"
  }
 }
 
resource "aws_route" "to_internet" {
  route_table_id = "${aws_vpc.vpc-project.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
  }
  
resource "aws_route_table_association" "a" {
  subnet_id = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_vpc.vpc-project.default_route_table_id}"
  }
  
resource "aws_network_interface" "ni" {
  subnet_id = "${aws_subnet.subnet1.id}"
  tags = {
  Name = "network_interface"
  }
 }
resource "aws_network_interface" "nj" {
  subnet_id = "${aws_subnet.subnet1.id}"
  tags = {
  Name = "network_interface"
  }
 }
 
resource "aws_network_interface" "nk" {
  subnet_id = "${aws_subnet.subnet1.id}"
  tags = {
  Name = "network_interface"
  }
 }
 
resource "aws_network_interface_attachment" "na" {
  instance_id = "${aws_instance.kube-master.id}"
  network_interface_id = "${aws_network_interface.ni.id}"
  device_index = 1
 }

resource "aws_network_interface_attachment" "nb" {
  instance_id = "${aws_instance.kube-node1.id}"
  network_interface_id = "${aws_network_interface.nj.id}"
  device_index = 1
 }
 
resource "aws_network_interface_attachment" "nc" {
  instance_id = "${aws_instance.controller.id}"
  network_interface_id = "${aws_network_interface.nk.id}"
  device_index = 1
 }
 
output "Public_IP_KUBE-MASTER"{
   value = "kube-master---${aws_instance.kube-master.public_ip}"
   }
output "Public_IP_KUBE-NODE" {
  value = "kube-node1---${aws_instance.kube-node1.public_ip}"
}
output "Public_IP_CONTROLLER" {
  value = "controller---${aws_instance.controller.public_ip}"
}
output "STATUS-terra" {
  value = "All_ok"
}