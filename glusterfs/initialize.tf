#-----
# initialize the remote state with these values 
# (only need to run this once via terraform init)
#-----

#Using local state for this project

# terraform {
#   backend "s3" {
#     bucket = "terraform-statefiles.thenuclei.org"
#     key    = "testing.tfstate"
#     region = "us-west-2"
#     encrypt = "true"
#     profile = "default"
#     dynamodb_table = "terraform-locker"
#   }
# }
