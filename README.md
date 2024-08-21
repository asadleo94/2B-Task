# Terraform Setup Instructions

## Step 1: Install Az CMD

Install the Azure Command-Line Interface (CLI) if it's not already installed on your system.

## Step 2: Install Terraform

Please install Terraform and set up the environment. You can find the installation instructions at:
- [Terraform Installation Guide](https://developer.hashicorp.com/terraform/install)
- [AWS Getting Started Tutorial](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Step 3: Set Up Your Working Directory

Create a directory for your Terraform configuration files (also known as "Terraform scripts"):


mkdir my-terraform-project

##  Step 4: Clone the git

## Step 5: Validate the Configuration
Validate that the syntax in your .tf files is correct:


terraform validate

If the configuration is valid, you’ll see a success message. If not, Terraform will point out errors.

## Step 6: Create an Execution Plan
Generate an execution plan that shows what Terraform will do without making any changes:

terraform plan
Note: Terraform will to provide the Password for all Virtual Machines.
Terraform will display the resources it plans to create, update, or destroy.

## Step 7: Apply the Terraform Script
Run the following command to apply the changes and create the resources defined in your script:

terraform apply
Note: Please provide the Password for all Virtual Machines.

Terraform will show a summary of actions and ask for confirmation. Type yes to proceed.

## Step 8: Destroy the Infrastructure (Optional)
To clean up and destroy the resources created by Terraform, use:

terraform destroy


