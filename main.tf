provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "example-terraform-state"
    key    = "example.tfstate"
    region = "us-west-2"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  acl = "public-read"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_cloudfront_distribution" "example" {
  origin {
    domain_name = aws_s3_bucket.example.bucket_regional_domain_name
    origin_id = aws_s3_bucket.example.id
  }

  enabled = true
  is_ipv6_enabled = true
  comment = "example distribution"
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.example.id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }
  price_class = "PriceClass_100"
  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/abcdef01-2345-6789-abcd-ef0123456789"
    ssl_support_method = "sni-only"
  }
}

resource "aws_wafv2_web_acl" "example" {
  name = "example-waf"
  scope = "REGIONAL"
  default_action {
    block {}
  }
  rule {
    name = "example-rule"
    priority = 1
    action {
      allow {}
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name = "example-rule"
      sampled_requests_enabled = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "example" {
  resource_arn = aws_cloudfront_distribution.example.arn
  web_acl_arn = aws_wafv2_web_acl.example.arn
}

resource "aws_route53_record" "example" {
  zone_id = "Z0123456789ABCDEF"
  name = "example.com"
  type = "A"
  alias {
    name = aws_cloudfront_distribution.example.domain_name
    zone_id = aws_cloudfront_distribution.example.hosted_zone_id
    evaluate_target_health = false
  }
}