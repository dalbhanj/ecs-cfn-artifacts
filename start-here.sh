#!/bin/bash

echo "This script will launch CloudFormation templates for creating infrastructure resources such as VPC, ELB and ECS cluster"

set -o errexit -o xtrace
echo -n "Enter S3 Bucket to host the templates and scripts > "
read bucket
echo -n "Enter stackname to create or update the stack > "
read stackname

zip deploy/templates.zip base.yaml templates/*

aws s3 cp deploy/templates.zip "s3://${bucket}" --acl public-read
aws s3 cp base.yaml "s3://${bucket}" --acl public-read
aws s3 cp --recursive templates/ "s3://${bucket}/templates" --acl public-read
aws s3api put-bucket-versioning --bucket "${bucket}" --versioning-configuration Status=Enabled
aws cloudformation deploy --stack-name $stackname --template-file base.yaml --capabilities CAPABILITY_NAMED_IAM --parameter-overrides GitHubUser=$GitHubUser GitHubToken=$GitHubToken TemplateBucket=$bucket