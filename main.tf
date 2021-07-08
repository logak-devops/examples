// 1) Provide your own access and secret keys so terraform can connect
//    and create AWS resources (e.g. our lambda function)
provider "aws" {
        shared_credentials_file = "/root/.aws/credential"
        region="us-east-1"
}

// 2) Setup our lambda parameters and .zip file that will be uploaded to AWS
locals {
        // The name of our lambda function when is created in AWS
        function_name = "hello-world-lambda1"
        // When our lambda is run / invoked later on, run the "handler"
        // function exported from the "index" file
        handler = "index.handler"
        // Run our lambda in node v14
        runtime = "python3.8"
        // By default lambda only runs for a max of 3 seconds but our
        // "hello world" is printed after 5 seconds. So, we need to
        // increase how long we let our lambda run (e.g. 6 seconds)
        timeout = 6

        // The .zip file we will create and upload to AWS later on
        zip_file = "hello-world-lambdai1.zip"
}

// 3) Let terraform create a .zip file on your local computer which contains
//    only our "hellowold.py" file by ignoring any Terraform files (e.g. our .zip)
data "archive_file" "zip" {

        source_file = "hello.py"
        type = "zip"

        // Create the .zip file in the same directory as the index.js file
        output_path = "${path.module}/${local.zip_file}"
}

// 4) Use gitrepo terrafore module to deploy your lambda for yo
module "hello-world-lambda" {
        source = "github.com/logak-devops/terraform-modules.git//v0.15/aws-lambda/v2"

        excluded_files = [
                ".env",
                ".terraform",
                ".terraform.lock.hcl",
                "main.tf",
                "terraform.tfstate",
                "terraform.tfstate.backup",
        ]
        handler = local.handler
        name =  local.function_name
        runtime = local.runtime
        source_directory = path.module

        timeout_after_seconds = 6
}
