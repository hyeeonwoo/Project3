terraform {
  required_version = ">= 1.0.0, <2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2" #Asia Pacific (seoul) region
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1" #Asia Pacific (seoul) region
}
