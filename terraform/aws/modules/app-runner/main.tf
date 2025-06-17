resource "aws_apprunner_service" "main" {
  service_name = ""
  source_configuration {
  }

}

resource "aws_apprunner_vpc_connector" "main" {
  vpc_connector_name = ""
  subnets            = []
  security_groups    = []
}

resource "aws_apprunner_deployment" "main" {
  service_arn = ""

}