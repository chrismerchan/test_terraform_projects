/**************************************
*
* Elastic Cloud Service configuration
*
***************************************/


provider "aws" {
  region = var.aws_region
}

resource "aws_ecs_cluster" "aws-ecs" {
  name = var.app_name
}

/////////////////////////////////////////
// ECS Instance AMI 
/////////////////////////////////////////

data "aws_ami" "ecs-ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.*"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecs-cluster-runner-policy" {
  statement {
    actions = ["ec2:Describe*", "ecr:Describe*", "ecr:BatchGet*"]
    resources = ["*"]
  }
  statement {
    actions = ["ecs:*"]
    resources = ["arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/${var.app_name}/*"]
  }
}

data "template_file" "user_data_cluster" {
  template = "${file("${path.module}/templates/cluster_user_data.sh")}"
  vars = { 
    ecs_cluster = aws_ecs_cluster.aws-ecs.name
  }
}

/////////////////////////////////////////
// ECS Role & Policy Definition
/////////////////////////////////////////

resource "aws_iam_role_policy" "ecs-cluster-runner-role-policy" {
  name = "${var.app_name}-cluster-runner-policy"
  role = aws_iam_role.ecs-cluster-runner-role.name
  policy = data.aws_iam_policy_document.ecs-cluster-runner-policy.json
}

resource "aws_iam_role" "ecs-cluster-runner-role" {
  name = "${var.app_name}-cluster-runner-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role.json
}

resource "aws_iam_instance_profile" "ecs-cluster-runner-profile" {
  name = "${var.app_name}-cluster-runner-iam-prof"
  role = aws_iam_role.ecs-cluster-runner-role.name
}

/////////////////////////////////////////
// ECS Cluster Definition
/////////////////////////////////////////

resource "aws_instance" "ecs-cluster-runner" {
  ami = data.aws_ami.ecs-ami.id 
  instance_type = var.cluster_runner_type
  subnet_id = element(aws_subnet.aws-subnet.*.id, 0)
  vpc_security_group_ids = [aws_security_group.ecs-cluster-host.id]
  associate_public_ip_address = true
  key_name = var.aws_key_pair_name
  user_data = data.template_file.user_data_cluster.rendered
  count = var.cluster_runner_count
  iam_instance_profile = aws_iam_instance_profile.ecs-cluster-runner-profile.name

  tags = {
    Name = "${var.app_name}-ecs-cluster-runner-${count.index}"
    Environment = var.app_environment
    Role = "ecs-cluster"
  }
  volume_tags = {
    Name = "${var.app_name}-ecs-cluster-runner"
    Environment = var.app_environment
    Role = "ecs-cluster"
  }
}

resource "aws_security_group" "ecs-cluster-host" {
  name = "${var.app_name}-ecs-cluster-host"
  description = "${var.app_name}-ecs-cluster-host"
  vpc_id = aws_vpc.aws-vpc.id
  
  tags = {
    Name = "${var.app_name}-ecs-cluster-host"
    Environment = var.app_environment
    Role = "ecs-cluster"
  }
}

resource "aws_security_group_rule" "ecs-cluster-host-ssh" {
  security_group_id = aws_security_group.ecs-cluster-host.id
  description = "admin SSH access to ecs cluster"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = var.admin_sources_cidr
}

resource "aws_security_group_rule" "ecs-cluster-egress" {
  security_group_id = aws_security_group.ecs-cluster-host.id
  description = "ecs cluster egress"
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

output "ecs_cluster_runner_ip" {
  description = "External IP of ECS Cluster"
  value = [aws_instance.ecs-cluster-runner.*.public_ip]
}

output "ecs-cluster-tag-runner" {
  description = "External tags of ECS Cluster"
  value = [aws_instance.ecs-cluster-runner.*.tags.Name]
}