#!/bin/bash
terraform apply -auto-approve
export INVOKE_URI=$(terraform output -json | jq -r .aws_apigatewayv2_stage.value.invoke_url)
