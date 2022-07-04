# How to create a module.

## Creating a Module

In this section, you’ll define multiple Droplets and a Load Balancer as Terraform resources and package them into a module. You’ll also make the resulting module customizable using module inputs.

- You’ll store the module in a directory named droplet-lb, under a directory called modules. Assuming you are in the terraform-modules directory you created as part of the prerequisites, create both at once by running:

`mkdir -p modules/droplet-lb`

The -p argument instructs mkdir to create all directories in the supplied path.

- Navigate to it:

`cd modules/droplet-lb`

As was noted in the previous section, modules contain the resources and variables they use. Starting from Terraform 0.13, they must also include definitions of the providers they use. Modules do not require any special configuration to note that the code represents a module, as Terraform regards every directory containing HCL code as a module, even the root directory of the project.

- Variables defined in a module are exposed as its inputs and can be used in resource definitions to customize them. The module you’ll create will have two inputs: the number of Droplets to create and the name of their group. Create and open for editing a file called variables.tf where you’ll store the variables:

`nano variables.tf`

- Add the following lines:

`variable "droplet_count" {}`

`variable "group_name" {}`

Save and close the file.

- You’ll store the Droplet definition in a file named droplets.tf. Create and open it for editing:

`nano droplets.tf`

Add the following lines:

`resource "digitalocean_droplet" "droplets" {
  count  = var.droplet_count
  image  = "ubuntu-20-04-x64"
  name   = "${var.group_name}-${count.index}"
  region = "fra1"
  size   = "s-1vcpu-1gb"
}`


- For the count parameter, which specifies how many instances of a resource to create, you pass in the droplet_count variable. Its value will be specified when the module is called from the main project code. The name of each of the deployed Droplets will be different, which you achieve by appending the index of the current Droplet to the supplied group name. Deployment of the Droplets will be in the fra1 region and they will run Ubuntu 20.04.

When you are done, save and close the file.

With the Droplets now defined, you can move on to creating the Load Balancer. You’ll store its resource definition in a file named lb.tf. Create and open it for editing by running:

`nano lb.tf`

Add its resource definition:

`
resource "digitalocean_loadbalancer" "www-lb" {
  name   = "lb-${var.group_name}"
  region = "fra1"
`
`
  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  `healthcheck {
    port     = 22
    protocol = "tcp"
  }
`
`  droplet_ids = [
    for droplet in digitalocean_droplet.droplets:
      droplet.id
  ]
}`

You define the Load Balancer with the group name in its name in order to make it distinguishable. You deploy it in the fra1 region together with the Droplets. The next two sections specify the target and monitoring ports and protocols.

The highlighted droplet_ids block takes in the IDs of the Droplets, which should be managed by the Load Balancer. Since there are multiple Droplets, and their count is not known in advance, you use a for loop to traverse the collection of Droplets (digitalocean_droplet.droplets) and take their IDs. You surround the for loop with brackets ([]) so that the resulting collection will be a list.

Save and close the file.

You’ve now defined the Droplet, Load Balancer, and variables for your module. You’ll need to define the provider requirements, specifying which providers the module uses, including their version and where they are located. Since Terraform 0.13, modules must explicitly define the sources of non-Hashicorp maintained providers they use; this is because they do not inherit them from the parent project.


- You’ll store the provider requirements in a file named provider.tf. Create it for editing by running:

`nano provider.tf`

- Add the following lines to require the digitalocean provider:

`terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}`

- Save and close the file when you’re done. The droplet-lb module now requires the digitalocean provider.

Modules also support outputs, which you can use to extract internal information about the state of their resources. You’ll define an output that exposes the IP address of the Load Balancer, and store it in a file named outputs.tf. Create it for editing:

`nano outputs.tf`


Add the following definition:

`output "lb_ip" {
  value = digitalocean_loadbalancer.www-lb.ip
}`

This output retrieves the IP address of the Load Balancer. Save and close the file.

- The droplet-lb module is now functionally complete and ready for deployment. You’ll call it from the main code, which you’ll store in the root of the project. First, navigate to it by going upward through your file directory two times:

`cd ../..`

Then, create and open for editing a file called main.tf, in which you’ll use the module:

`nano main.tf`

- Add the following lines:

`module "groups" {
  source = "./modules/droplet-lb"
`

`
  droplet_count = 3
  group_name    = "group1"
}
`

`
output "loadbalancer-ip" {
  value = module.groups.lb_ip
}
`

In this declaration you invoke the droplet-lb module located in the directory specified as source. You configure the input it provides, droplet_count and group_name, which is set to group1 so you’ll later be able to discern between instances.

Since the Load Balancer IP output is defined in a module, it won’t automatically be shown when you apply the project. The solution to this is to create another output retrieving its value (loadbalancer_ip).

Save and close the file when you’re done.

- Initialize the module by running:

`terraform init`