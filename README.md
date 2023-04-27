# Yusuf's Liatrio Exercise
Repository for my exercise with Liatrio

## Environmental Assumptions
- The `setup.sh` script will be run on a Mac. This uses brew to install required applications.
- The AWS environment will be launched in the `us-east-1` region.
- Already installed is `awscli` and an AWS configuration is already created.
- The AWS credentials that are used has the permissions to create and destroy the following:
  * IAM Roles and policies
  * VPCs, Subnets, VPC endpoints, Internet Gateways, NAT Gateways, Security Groups, Route Tables, and EIPs
  * EKS Clusters and Node Groups
  * ECR Repositories
- Docker is already installed.

## How to Run the Script
Simply run `./setup.sh` from the root directory of this repository.

## What is being run
Brew is used to install the requisite applications. These applications are:
- jq
- terraform
- helm

Terraform is then used to deploy the AWS infrastructure. This includes the VPC and neccessary components, IAM roles and policies, an EKS cluster, and an ECR repository.

Docker is then used to log into the ECR repo, build the image, and push the image to the repo.

Next, Helm is used in order to deploy the image to the EKS cluster. After a one minute wait, the publicly accessible endpoint will be displayed. 

## How to Cleanup the environment
To cleanup the environment, run `./cleanup.sh` from the root directory of this repository. This script will delete the AWS environment, and clear any ENV variables.