# Terraform

## What is Infrastructure as Code with Terraform?
---

Infrastructure as code (IaC) tools allow you to manage infrastructure with configuration files rather than through a graphical user interface. IaC allows you to build, change, and manage your infrastructure in a safe, consistent, and repeatable way by defining resource configurations that you can version, reuse, and share.

Terraform is HashiCorp's infrastructure as code tool. It lets you define resources and infrastructure in human-readable, declarative configuration files, and manages your infrastructure's lifecycle. Using Terraform has several advantages over manually managing your infrastructure:

Terraform can manage infrastructure on multiple cloud platforms.
The human-readable configuration language helps you write infrastructure code quickly.
Terraform's state allows you to track resource changes throughout your deployments.
You can commit your configurations to version control to safely collaborate on infrastructure.


## What are modules?
---

### Modules
---
Modules are containers for multiple resources that are used together. A module consists of a collection of .tf and/or .tf.json files kept together in a directory.

Modules are the main way to package and reuse resource configurations with Terraform.

### The Root Module
---
Every Terraform configuration has at least one module, known as its root module, which consists of the resources defined in the .tf files in the main working directory.

### Child Modules
---

A Terraform module (usually the root module of a configuration) can call other modules to include their resources into the configuration. A module that has been called by another module is often referred to as a child module.

Child modules can be called multiple times within the same configuration, and multiple configurations can use the same child module.


### Published Modules
---

In addition to modules from the local filesystem, Terraform can load modules from a public or private registry. This makes it possible to publish modules for others to use, and to use modules that others have published.

The Terraform Registry hosts a broad collection of publicly available Terraform modules for configuring many kinds of common infrastructure. These modules are free to use, and Terraform can download them automatically if you specify the appropriate source and version in a module call block.

Also, members of your organization might produce modules specifically crafted for your own infrastructure needs. Terraform Cloud and Terraform Enterprise both include a private module registry for sharing modules internally within your organization.

### Using Modules
---

- Module Blocks documents the syntax for calling a child module from a parent module, including meta-arguments like for_each.

https://www.terraform.io/language/modules/syntax

![Calling a child module](./Terraform_images/Calling_a_Child_Module.jpg)


- Module Sources documents what kinds of paths, addresses, and URIs can be used in the source argument of a module block.

https://www.terraform.io/language/modules/sources

![module resource](./Terraform_images/module_resource.jpg)

- The Meta-Arguments section documents special arguments that can be used with every module, including providers, depends_on, count, and for_each.

- Providers - https://www.terraform.io/language/meta-arguments/module-providers

In a module call block, the optional providers meta-argument specifies which provider configurations from the parent module will be available inside the child module.

https://www.terraform.io/language/meta-arguments/module-providers

![providers](./Terraform_images/providers.jpg)

- Depend_on - https://www.terraform.io/language/meta-arguments/depends_on

![depend on](./Terraform_images/depend_on.jpg)

- Count - https://www.terraform.io/language/meta-arguments/count

![Count](./Terraform_images/count.jpg)

- For-each - https://www.terraform.io/language/meta-arguments/for_each

- Map:

`resource "azurerm_resource_group" "rg" {
  for_each = {
    a_group = "eastus"
    another_group = "westus2"
  }
  name     = each.key
  location = each.value
}
`

- Set of strings:

`resource "aws_iam_user" "the-accounts" {
  for_each = toset( ["Todd", "James", "Alice", "Dottie"] )
  name     = each.key
}
`

- Child Module:

`# my_buckets.tf
module "bucket" {
  for_each = toset(["assets", "media"])
  source   = "./publish_bucket"
  name     = "${each.key}_bucket"
}
`

`# publish_bucket/bucket-and-cloudfront.tf
variable "name" {} # this is the input parameter of the module`


`resource "aws_s3_bucket" "example" {`
`  # Because var.name includes each.key in the calling`
`  # module block, its value will be different for`
`  # each instance of this module.`
`  bucket = var.name`
}
`

`
resource "aws_iam_user" "deploy_user" {
  // ...
}
`



