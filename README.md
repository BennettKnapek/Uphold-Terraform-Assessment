########### Uphold Terraform Assessment ###########

#### Overview ####
main.tf is the Terraform file that will provision a VPC through
my Amazon Web Services account. In this VPC, there is a public subnet
and a private subnet. The public subnet has its own routing table and 
association resource to connect the Internet Gateway to the VPC. The Private
subnet has the same but for a NAT Gateway instead of Internet Gateway. Also,
I created an Elastic IP Address that can be used to mask any failures if I decided
to use this VPC for some cloud computing.

## Provider ## 
The provider of the cloud services is "aws" which is linked to my personl AWS account through the access_key and secret_key. I redacted both of those keys because they are sensitive to my personal AWS account and I am placing this on my publicly viewable Github page. Also, the region is 'us-east-2' which relates to 'Ohio' region because I am in the Midwest.

## Resources ##
# VPC #
The VPC created here facilitates resources on the AWS cloud platform. This VPC has a cidr (Classless Inter-Domain Routing) which aids the private cloud's allocation of IP addrs. Contained in this VPC are the other resources below. 

# Public Subnet #
The Public Subnet is used to connect the VPC to the rest of the internet or other AWS services through an Internet Gateway (2-way). The subnet itself is defined first, then the routing table and associations are defined later in the main.tf file. 

# Private Subnet # 
The Private Subnet is used to connect the VPC to mainly back-end operations through the NAT Gateway (1-way). Again, the subnet itself is defined first and then the routing table and associations are defined later in the main.tf file. 

# Routing Tables #
Each subnet has a routing table that defines rules (routes) that are used to direct network traffic through the gateway, whether its a NAT Gateway or Internet Gateway. I use "depends_on" in the routing table instantiation because the gateway IDs aren't generated until 'apply' is executed. This prevents the compilation error from occuring when 'apply' is executed. 

# Table Associations #
This fairly simple resource connects tells the VPC to connect the aforementioned routing table and subnet. 

# Elastic IP #
The Elastic IP will act like error handling by masking a faulty instance of any cloud computing in this VPC. Again, this uses "depends_on" because this cannot be initialized until a Internet Gateway is established. 



#### Notes ####
I realize that there are two more ways I could structure this Provisioning. 

1. Separate the different resources into their own file. If I did this, I would probably put each subnet into its own file. Also, I could create a varables.tf file so my long resource names don't have to be continuously typed/referenced. 

2. Terraforms "module" structure. Which could dumb this code down to less than 30 lines.


###### Terraform Commands Used (in order) ######
terraform init  - intitializes providers/plugins so resources are accessible
terraform plan  - gives overview of the resource structure the main.tf file contains
terraform apply - compiles configuations so that AWS is able to build the VPC