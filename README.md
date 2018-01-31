# Kubernetes on AWS

The script `kaws` is going to help you to create a secure Kubernetes cluster on AWS. It's based on the project [kube-aws-secure](https://github.com/camilb/kube-aws-secure) and uses [kube-aws](https://github.com/kubernetes-incubator/kube-aws) to create the Kubernetes cluster.

The script `kaws` was modified to be non-interactive, now it can be used in automation projects to create the Kubernetes cluster with minimun human intervention and the templates were updated to the latest version of kube-aws.

## Quick Start

After clonning the repository, create a configuration file with the minimun requirements:

* AWS Key Pair Name
* AWS Route53 Domain Name
* AWS S3 Bucket Name

These 3 parameters can be also provided to the script in environment variables or by command arguments.

For example, create the file `kaws.conf` with the following content:

  KAWS_KEY_NAME=kube-keypair
  KAWS_DOMAIN_NAME=mycompany.com
  KAWS_BUCKET=mycompany-kube-bucket

Now execute `kaws install` with the name of the stack for the VPC:

  ./kaws install --stack somename

This will create a `./vpc/vpc.yaml` file with the CloudFormation Template for the VPC and will create it. Then will use `kube-aws` to generate all the required certificates, create all the CloudFormation Templates to create the Kubernetes cluster, and create the cluster with Kubernetes running.

When done or if something fails, destroy the cluster and stacks with:

  ./kaws destroy --stack somename

Or, start over running the `clean` subcommand: `./kaws clean`

There is more information reading the help: `./kaws help`

## TODO

- [ ] The install is not yet creating the CFT for Kubernetes. There is a `locksmithd.service` error.
- [ ] Integrate other add-ons
- [ ] Integrate IAM to Kubernetes
- [ ] Configure the VPN

# Acknowledgements

Thank to [Camil](https://github.com/camilb) for the great job done on [kube-aws-secure](https://github.com/camilb/kube-aws-secure) and to the great team of [kube-aws](https://github.com/kubernetes-incubator/kube-aws) for this great tool.