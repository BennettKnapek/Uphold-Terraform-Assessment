//
//   UPHOLD TERRAFORM ASSESSMENT
//   Bennett Knapek - 2/9/2022
//

// Allows for VPC resources to be used
provider "aws" {
  region = "us-east-2" // Ohio region
  access_key = ""                     // This is redacted because they are sensitive to my account
  secret_key = "" // This is redacted because they are sensitive to my account
}

// Create the Virtual Private Network that will
// encapsulate all of the resources below
resource "aws_vpc" "uphold_assesment_vpc" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Assessment VPC"
  }
}

// Create the public subnet
resource "aws_subnet" "uphold_assessment_public_subnet" {
  vpc_id = aws_vpc.uphold_assesment_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Assessment Public Subnet"
  }
}

// Create the private subnet
resource "aws_subnet" "uphold_assessment_private_subnet" {
  vpc_id = aws_vpc.uphold_assesment_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
      Name = "Assessment Private Subnet"
  }
}

// Create internet gateway that connects the AWS VPC and
// the Internet. 2-way street
resource "aws_internet_gateway" "uphold_assessment_igw" {
  vpc_id = aws_vpc.uphold_assesment_vpc.id

  tags = {
    Name = "Assessment Internet Gateway"
  }
}

// Associate an elastic IP address with the VPC. This can be
// used for dynamic cloud computing
resource "aws_eip" "uphold_assessment_nat_eip" {
  vpc = true
  depends_on = [aws_internet_gateway.uphold_assessment_igw]

  tags = {
    Name = "Assessment NAT Gateway Elastic IP"
  }
}

// Create NAT gateway which connects the private subnet
// in our VPC to connect to the internet. 1-way 
resource "aws_nat_gateway" "uphold_assessment_nat" {
    allocation_id = aws_eip.uphold_assessment_nat_eip.id
    subnet_id = aws_subnet.uphold_assessment_public_subnet.id
    
    tags = {
      Name = "Assessment NAT Gateway"
    }
}

// Create routing table that tells network traffic from public
// subnet to go.
resource "aws_route_table" "uphold_assessment_public_rt" {
    vpc_id = aws_vpc.uphold_assesment_vpc.id

    route = [ {
      carrier_gateway_id = ""
      cidr_block = "0.0.0.0/0"
      destination_prefix_list_id = ""
      egress_only_gateway_id = ""
      gateway_id = aws_internet_gateway.uphold_assessment_igw.id
      instance_id = ""
      ipv6_cidr_block = ""
      local_gateway_id = ""
      nat_gateway_id = ""
      network_interface_id = ""
      transit_gateway_id = ""
      vpc_endpoint_id = ""
      vpc_peering_connection_id = ""
    } ]

    tags = {
      Name = "Assessment Public Route Table"
    }

    depends_on = [aws_internet_gateway.uphold_assessment_igw]
}

// Associate the public subnet with the routing table created
// above
resource "aws_route_table_association" "uphold_assessment_public_associations" {
    subnet_id = aws_subnet.uphold_assessment_public_subnet.id
    route_table_id = aws_route_table.uphold_assessment_public_rt.id
}

// Create routing table that tells network traffic from private
// subnet to go.
resource "aws_route_table" "uphold_assessment_private_rt" {
    vpc_id = aws_vpc.uphold_assesment_vpc.id

    route = [ {
      carrier_gateway_id = ""
      cidr_block = "0.0.0.0/0"
      destination_prefix_list_id = ""
      egress_only_gateway_id = ""
      gateway_id = ""
      instance_id = ""
      ipv6_cidr_block = ""
      local_gateway_id = ""
      nat_gateway_id = aws_nat_gateway.uphold_assessment_nat.id
      network_interface_id = ""
      transit_gateway_id = ""
      vpc_endpoint_id = ""
      vpc_peering_connection_id = ""
    } ]

    tags = {
      Name = "Assessment Private Route Table"
    }

    depends_on = [aws_nat_gateway.uphold_assessment_nat]
}

// Associate the private subnet with the routing table above. 
resource "aws_route_table_association" "uphold_assessment_private_associations" {
    subnet_id = aws_subnet.uphold_assessment_private_subnet.id
    route_table_id = aws_route_table.uphold_assessment_private_rt.id
}