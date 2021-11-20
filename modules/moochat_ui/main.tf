resource "aws_s3_bucket" "s3_moochat_ui" {
  bucket = "${terraform.workspace}-moochat-ui"
  acl = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "block_all_public_access" {
  bucket = aws_s3_bucket.s3_moochat_ui.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


data "aws_acm_certificate" "moochat_ui_certificate" {
  domain = "moochat.awesomepossum.dev"
}

resource "aws_cloudfront_distribution" "cf_moochat_ui_cache" {
	origin {
		domain_name = aws_s3_bucket.s3_moochat_ui.bucket_regional_domain_name
		origin_id = aws_s3_bucket.s3_moochat_ui.id

		s3_origin_config {
		  origin_access_identity = aws_cloudfront_origin_access_identity.cf_moochat_ui_oai.cloudfront_access_identity_path
		}
	}

	aliases = [
		"moochat.awesomepossum.dev",
		"www.moochat.awesomepossum.dev"
	]

	enabled = true
	is_ipv6_enabled = true
	comment = "CF Distro for User File Storage Cache"
  default_root_object = "index.html"

	custom_error_response {
		error_code = 403
		response_code = 200
		response_page_path = "/index.html"
	}

	default_cache_behavior {
		allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
		cached_methods = ["GET", "HEAD"]
		target_origin_id = aws_s3_bucket.s3_moochat_ui.id

		viewer_protocol_policy = "allow-all"
		min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

		forwarded_values {
		  query_string = false

		  cookies {
			  forward = "none"
		  }
		}
	}

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = ["US", "CA"]
    }
  }

	tags = {
		Environment = "${terraform.workspace}"
	}

	viewer_certificate {
		acm_certificate_arn = data.aws_acm_certificate.moochat_ui_certificate.arn
		minimum_protocol_version       = "TLSv1"
	  cloudfront_default_certificate = false
		ssl_support_method             = "sni-only"
	}
}

resource "aws_cloudfront_origin_access_identity" "cf_moochat_ui_oai" {
	comment = "origin access identity for s3_moochat_ui bucket"
}

data "aws_iam_policy_document" "moochat_ui_s3_policy" {
	statement {
		actions = ["s3:GetObject"]
		resources = ["${aws_s3_bucket.s3_moochat_ui.arn}/*"]

		principals {
			type = "AWS"
			identifiers = [
				aws_cloudfront_origin_access_identity.cf_moochat_ui_oai.iam_arn
			]
		}
	}
}

resource "aws_s3_bucket_policy" "s3_cloud_drive_front_end_policy_attach" {
	bucket = aws_s3_bucket.s3_moochat_ui.id
	policy = data.aws_iam_policy_document.moochat_ui_s3_policy.json
}

output "moochat_ui_bucket_name" {
  value = resource.aws_s3_bucket.s3_moochat_ui.id
}

output "moochat_cf_distribution" {
  value = resource.aws_cloudfront_distribution.cf_moochat_ui_cache.id
}
