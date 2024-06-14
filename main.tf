terraform {
  cloud {
    organization = var.organization

    workspaces {
      name = var.workspace
    }
  }
}

output "api_gateway_invoke_url" {
  value = "${aws_api_gateway_stage.practice-api.invoke_url}/path1"
}