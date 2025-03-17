terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.108.0"
    }
  }

  backend "s3" {
    bucket = "remote-state-example-gus-ferreira"
    key    = "pipeline-github/terraform.tfstate"
    region = "sa-east-1"
  }
}

provider "aws" {
  region = "sa-east-1"

  default_tags {
    tags = {
      owner      = "gustavo-ferreira"
      managed-by = "terraform"
    }
  }
}

provider "azurerm" {
  features {}
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "remote-state-example-gus-ferreira"
    key    = "aws-vpc/terraform.tfstate"
    region = "sa-east-1"
  }
}

data "terraform_remote_state" "vnet" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-curso-terraform-gus"
    storage_account_name = "terraformremotestategus"
    container_name       = "remote-state-container-terraform"
    key                  = "azure-vnet/terraform.tfstate"
  }
}