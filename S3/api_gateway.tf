resource "aws_api_gateway_rest_api" "apigateway" {
  name        = "MyAPIGateway"
  description = "API Gateway for Apigee integration"
}

resource "aws_api_gateway_resource" "s3_resource" {
  rest_api_id = aws_api_gateway_rest_api.apigateway.id
  parent_id   = aws_api_gateway_rest_api.apigateway.root_resource_id
  path_part   = "s3"
}

resource "aws_api_gateway_method" "s3_method" {
  rest_api_id   = aws_api_gateway_rest_api.apigateway.id
  resource_id   = aws_api_gateway_resource.s3_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "s3_integration" {
  rest_api_id             = aws_api_gateway_rest_api.apigateway.id
  resource_id             = aws_api_gateway_resource.s3_resource.id
  http_method             = aws_api_gateway_method.s3_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:s3:path/<your_bucket_name>/{proxy}"
}

resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.apigateway.id
  parent_id   = aws_api_gateway_rest_api.apigateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_integration" "nlb_integration" {
  rest_api_id             = aws_api_gateway_rest_api.apigateway.id
  resource_id             = aws_api_gateway_resource.proxy_resource.id
  http_method             = "ANY"
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.nlb.dns_name}/{proxy}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.apigateway.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.apigateway.id
  stage_name  = "prod"
}
