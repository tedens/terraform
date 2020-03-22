provider "aws" {
    profile = "default"
    region = "us-east-1"
    version = "~> 2.7"

}


# module "r53" {
#     source = "./modules/r53"


# }