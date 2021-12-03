# Terraform Project about AWS EC2 and S3
Terraform is a most popular open-source tool for cloud administration for any provider. In the next steps I’ll explain how to configure a simple S3 bucket and EC2 instance.


## Prerequisites

Software
- Terraform, version v1.0.10
- AWS Client, version: aws-cli/2.3.4
- Language Go, version: go1.17.3

AWS account with administration capabilities
- Access key ID
- Secret access key
- Region, for example: us-west-2

Github Account
- Public repository

## Quick configuration with aws configure

For general use, the aws configure command is the fastest way to set up your AWS CLI installation. When you enter this command, the AWS CLI prompts you for four pieces of information:
- Access key ID
- Secret access key
- AWS Region
- Output format

The AWS CLI stores this information in a profile (a collection of settings) named default in the credentials file. By default, the information in this profile is used when you run an AWS CLI command that doesn't explicitly specify a profile to use. For more information on the credentials file, see Configuration and credential file settings

The following example shows sample values. Replace them with your own values as described in the following sections.


```sh
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-west-2
Default output format [None]: json
```
Downloads Terraform project and execute the sentences in main directory. You can change the AWS Region in the file `main.tf`  

```sh
$ terraform init
$ terraform plan
$ terraform apply
```
Connect to AWS Console with the user with administration role. Check the resources created:

- Amazon S3 bucket: bucket-s3-cmerchan
- Amazon EC2 instance: Flugel

For testing the project, you can use the script `ec2_s3_test.go` . First, you can execute the sentences:

```sh
$ go mod init github.com/<YOUR_USERNAME>/<YOUR_REPO_NAME>
$ go mod vendor
$ go test -v -run TestS3EC2 -timeout 30m

```

# Terraform Project about AWS ECS and ALB

Terraform is a most popular open-source tool for cloud administration for any provider. In the next steps I’ll explain how to configure an AWS ECS cluster with ALB and a Nginx docker application for test.

# Prerequisites

Software:
- Terraform, version v1.0.10
- AWS Client, version: aws-cli/2.3.4
- Docker desktop, version: 20.10.10
- Language Go, version: go1.17.3
- Git, version: 2.30.1

AWS account with administration capabilities
- Access key ID
- Secret access key
- Key Pair
- Region, for example: us-west-2

New repository in AWS Elastic Container Registry, for save a Pyhton’ docker image with Nginx application. 

Two networks’ segments for application and administration access
- App sources cidr, for example: 10.20.100.0/24
- Admin sources cidr, for example: 10.20.0.0/24

# Configure docker for upload image in AWS ECR

Run the command in terminal for configure docker for upload image in Amazon Elastic Container Registry (previously AWS Client must be configured). For example:

```sh
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 704246131615.dkr.ecr.us-west-2.amazonaws
```

Terraform project have a structure:
- alb.tf
- ecs-policy.tf
- ecs.tf
- container.tf
- security-groups.tf
- vpc.tf
- variables.tf

File: `alb.tf` contains instructions for create an Amazon load balancing. A script block that defines ALB’ basic information, like as name, description and tags. Another script block defines a target group that processing the request from ALB, define values like as port, protocol, vpc and health check parameters. The last script block defines parameters about ALB expose for receive client’ requirements, port and protocol and default action: forward

File: `ecs-policy.tf` contains instructions for create a IAM policy’ groups that used when create a cluster in Amazon ECS. Policies uses too many specific roles for management and running task on instance Amazon EC2 or containers.

File: `ecs.tf` contains instructions for create a cluster AWS Elastic Container Service with two nodes or instances for default. A script block creates a relation between cluster and policy created previously. Cluster are created with many parameters, the most important are:

- Instance type = EC2 instance type of ECS Cluster Runner
- VPC security group = a virtual firewall for the new instance to control inbound and outbound traffic
- Key name = Key used for login to instance’ EC2 for ssh
- IAM instance profile = Amazon EC2 uses an instance profile as a container for an IAM role. When you create an IAM role using the IAM console, the console creates an instance profile automatically and gives it the same name as the role to which it corresponds.
- User data = When you launch an instance in Amazon EC2, you have the option of passing user data to the instance that can be used to perform common automated configuration tasks and even run scripts after the instance starts. This parameter contains a file templates\cluster_user_data.sh. This file is used to configure the hard drive partition of EC2 instances:

```sh
#!/bin/bash
if [ -e /dev/nvme1n1 ]; then
  if ! file -s /dev/nvme1n1 | grep -q filesystem; then
    mkfs.ext4 /dev/nvme1n1
  fi  
  cat >> /etc/fstab <<-EOF
  /dev/nvme1n1  /data  ext4  defaults,noatime,nofail  0  2
  EOF
  
  mkdir /data
  mount /data
fi 
echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config
systemctl try-restart ecs --no-block
```

Another configuration is the control of traffic ingress and egress. Ingress only for admin network and egress for default.

File `container.tf` defines a structure for creation of container, in this project the container will have a Nginx image with Python. At beginning of this process is necessary to create a new image based in a public image from hub.docker.com chrismerchan/uwsgi-nginx-flask:python3.10. The new image will upload to AWS ECR for the next steps in the creation of containers.

File `security-group.tf` defines the virtual firewall to control inbound and outbound traffic, in from ALB and target group of containers.

File `vpc.tf` define configurations about new Amazon Virtual Private Cloud. There are some configurations about subnets, Internet gateways (used to provide internet access to public subnets) and routes to the internet.

Downloads Terraform project and execute the sentences in main directory. You can change the AWS Region in the file `main.tf`  

```sh
$ terraform init
$ terraform plan
$ terraform apply
```
Connect to AWS Console with the user with administration role. Check the resources created:

- Amazon ECS 
- Amazon EC2 instances
- Amazon VPC
- Amazon Security group
- Amazon Load Balancing with target group
- New docker image in Amazon Elastic Repository

Finally, for testing the project, you can use the script `ecs_test.go` .First, you can execute the sentences:

```sh
$ go mod init github.com/<YOUR_USERNAME>/<YOUR_REPO_NAME>
$ go mod vendor
$ go test -v -run TestECS -timeout 30m
```

This test gets the value of variable `nginx_dns_lb` that contains the public DNS where the service run. Next, scripts open URL (after wait 2 minutes for the creation’ task finished) and get two values: the HTTP Code, for success most be 200, and HTTP body that don’t be null.

For example:
http://mynginx-load-balancer-813914422.us-west-2.elb.amazonaws.com/

Output:
# AWS EC2 Tag Instances:
my-ecs-app-ecs-cluster-runner-0
my-ecs-app-ecs-cluster-runner-1 

## License

Apache Software 

**Free Software, Hell Yeah!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [dill]: <https://github.com/joemccann/dillinger>
   [git-repo-url]: <https://github.com/joemccann/dillinger.git>
   [john gruber]: <http://daringfireball.net>
   [df1]: <http://daringfireball.net/projects/markdown/>
   [markdown-it]: <https://github.com/markdown-it/markdown-it>
   [Ace Editor]: <http://ace.ajax.org>
   [node.js]: <http://nodejs.org>
   [Twitter Bootstrap]: <http://twitter.github.com/bootstrap/>
   [jQuery]: <http://jquery.com>
   [@tjholowaychuk]: <http://twitter.com/tjholowaychuk>
   [express]: <http://expressjs.com>
   [AngularJS]: <http://angularjs.org>
   [Gulp]: <http://gulpjs.com>

   [PlDb]: <https://github.com/joemccann/dillinger/tree/master/plugins/dropbox/README.md>
   [PlGh]: <https://github.com/joemccann/dillinger/tree/master/plugins/github/README.md>
   [PlGd]: <https://github.com/joemccann/dillinger/tree/master/plugins/googledrive/README.md>
   [PlOd]: <https://github.com/joemccann/dillinger/tree/master/plugins/onedrive/README.md>
   [PlMe]: <https://github.com/joemccann/dillinger/tree/master/plugins/medium/README.md>
   [PlGa]: <https://github.com/RahulHP/dillinger/blob/master/plugins/googleanalytics/README.md>
   
