provider "aws" {
  region = "ap-southeast-2"
}
variable "name" {
  type = string
  default = "zip-apigw-canary-demo"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "lambda" {
  name                  = var.name
  assume_role_policy    = data.aws_iam_policy_document.assume_role.json
  force_detach_policies = true
}

data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_file  = "${path.module}/index.js"
  output_path = "${path.module}/lambda_function.zip"
}

module "apig_lambda" {
  source = "github.com/comtravo/terraform-aws-lambda?ref=5.0.0"

  file_name     = "${data.archive_file.lambda_function_zip.output_path}"
  function_name = var.name
  handler       = "index.handler"
  role          = aws_iam_role.lambda.arn
  trigger = {
    type = "api-gateway"
  }
  environment = {
    "stage" = "demo"
  }
  region = "ap-southeast-2"
  tags = {
    "project" : var.name
  }
}

module "apig" {
  source = "github.com/comtravo/terraform-aws-api-gateway-v2?ref=1.3.0"

  name          = var.name
  stage         = var.name
  protocol_type = "HTTP"
  tags = {
    Name        = var.name
    environment = "demo"
  }
  body = <<EOF
---
openapi: "3.0.1"
x-amazon-apigateway-importexport-version: "1.0"
info:
  title: "test"
paths:
  /:
    x-amazon-apigateway-any-method:
      responses:
        default:
          description: "Default response for ANY /"
      x-amazon-apigateway-integration:
        payloadFormatVersion: "2.0"
        type: "aws_proxy"
        httpMethod: "POST"
        uri: "${module.apig_lambda.invoke_arn}"
        connectionType: "INTERNET"
EOF
}

output "aws_apigatewayv2_api" {
  value = module.apig.aws_apigatewayv2_api
}

output "aws_apigatewayv2_deployment" {
  value = module.apig.aws_apigatewayv2_deployment
}

output "aws_apigatewayv2_stage" {
  value = module.apig.aws_apigatewayv2_stage
}

output "aws_apigatewayv2_domain_name" {
  value = module.apig.aws_apigatewayv2_domain_name
}

output "aws_route53_record" {
  value = module.apig.aws_route53_record
}

output "aws_cloudwatch_log_group" {
  value = module.apig.aws_cloudwatch_log_group
}
