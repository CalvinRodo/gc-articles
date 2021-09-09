locals {
  # Rules that must be excluded from the AWSManagedRulesCommonRuleSet for WordPress to work
  wpadmin_rules         = ["GenericRFI_QUERYARGUMENTS", "GenericRFI_BODY", "GenericRFI_URIPATH"]
  file_upload_rules     = ["SizeRestrictions_BODY", "CrossSiteScripting_BODY"]
  common_excluded_rules = var.allow_wordpress_uploads ? concat(local.wpadmin_rules, local.file_upload_rules) : local.wpadmin_rules
}

#
# CloudFront access control
#
resource "aws_wafv2_web_acl" "wordpress_waf" {
  provider = aws.us-east-1

  name        = "wordpress_waf"
  description = "WAF for Wordpress protection"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        dynamic "excluded_rule" {
          for_each = local.common_excluded_rules
          content {
            name = excluded_rule.value
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesPHPRuleSet"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesPHPRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesPHPRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesWordPressRuleSet"
    priority = 6

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesWordPressRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesWordPressRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # TODO: request WAF capacity unit increase when this moves to production AWS account
  # TODO: add known bad IPs rule
  #   rule {
  #     name     = "WordpressRateLimit"
  #     priority = 101

  #     action {
  #       block {}
  #     }

  #     statement {
  #       rate_based_statement {
  #         limit              = 10000
  #         aggregate_key_type = "IP"
  #       }
  #     }

  #     visibility_config {
  #       cloudwatch_metrics_enabled = true
  #       metric_name                = "WordpressRateLimit"
  #       sampled_requests_enabled   = true
  #     }
  #   }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "wordpress"
    sampled_requests_enabled   = false
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}

#
# ALB access control: block if custom header not specified
#
resource "aws_wafv2_web_acl" "wordpress_waf_alb" {
  name  = "wordpress_waf_alb"
  scope = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "CloudFrontCustomHeader"
    priority = 201

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        positional_constraint = "EXACTLY"
        field_to_match {
          single_header {
            name = var.cloudfront_custom_header_name
          }
        }
        search_string = var.cloudfront_custom_header_value
        text_transformation {
          priority = 1
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CloudFrontCustomHeader"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "CloudFrontCustomHeader"
    sampled_requests_enabled   = false
  }

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}

#
# WAF association
#
resource "aws_wafv2_web_acl_association" "wordpress_waf_alb" {
  resource_arn = aws_lb.wordpress.arn
  web_acl_arn  = aws_wafv2_web_acl.wordpress_waf_alb.arn
}

#
# WAF logging
#
resource "aws_wafv2_web_acl_logging_configuration" "firehose_waf_logs_cloudfront" {
  provider = aws.us-east-1

  log_destination_configs = [aws_kinesis_firehose_delivery_stream.firehose_waf_logs_us_east.arn]
  resource_arn            = aws_wafv2_web_acl.wordpress_waf.arn
}

resource "aws_wafv2_web_acl_logging_configuration" "firehose_waf_logs_alb" {
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.firehose_waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.wordpress_waf_alb.arn
}
