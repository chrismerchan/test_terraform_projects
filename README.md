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

## License

Apache Software 