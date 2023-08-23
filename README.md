# terraform-React

Terraform code to deploy a React application with S3, CloudFront, SSL, and WAF on AWS while storing the state remotely in S3.

This code is using the `aws` provider to specify the AWS region as `us-west-2`. It is also using the `backend` configuration to store the Terraform state remotely in an S3 bucket named "example-terraform-state". It is creating an S3 bucket named "example-bucket" with public-read access and a website configuration that specifies the index and error documents. It is also creating a CloudFront distribution that uses the S3 bucket as the origin and enables IPv6, with a default cache behavior that redirects HTTP to HTTPS. It is also creating a WAFv2 web ACL named "example-waf" with a rule that allows all requests and an association with the CloudFront distribution. Finally, it is creating a Route 53 record that points to the CloudFront distribution.
