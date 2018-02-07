# Kubernetes on AWS

The script `kaws` is going to help you to create a Kubernetes cluster on AWS. It uses [kube-aws](https://github.com/kubernetes-incubator/kube-aws) to create the all the required certificates, CloudFormation templates and UserData to create Kubernetes cluster.

KAWS is non-interactive, it require the inputs in command flags or environment variables exported or defined in the config file `kaws.conf`.

## Requirements

1. An AWS account
2. AWS CLI installed and configure
3. Kubectl installed and configured
4. An EC2 Key Pair
5. A Route 53 domain name

## Quick Start

After clonning the repository, create a configuration file with the minimun requirements:

* AWS Key Pair Name
* AWS Route53 Domain Name

These 3 parameters can be also provided to the script in environment variables.

For example, create the file `kaws.conf` with the following content:

    KAWS_KEY_NAME=kube-keypair
    KAWS_DOMAIN_NAME=example.com

Using the subcommand `up`:

    ./kaws up

Using the `kube-aws` tool, it creates all the required certificates and CloudFormation Templates to create the Kubernetes cluster, then launch the cluster with Kubernetes running.

When done or if something fails, destroy the cluster with:

    ./kaws down

Or, start over running the `clean` subcommand: `./kaws clean`

There is more information reading the help: `./kaws help`

## Modify the cluster

The cluster modification can be done in two different ways: modify the configuration before create it and update the cluster.

The `kube-aws` tool uses the file `kube-aws/config.yaml` to create all the CFT's and launch the Kubernetes cluster. To customize the Kubernetes cluster it's required to modify this config file.

Execute the subcommand `init` to get the `config.yaml` file and every other required files (certificates, userdata, etc...) in the directory `./kube-aws/`. After modify the files, execute the subcommand `up` to launch the cluster with the modifications.

    ./kaws init
    ./kaws up

If the cluster is already running and it's required to modify it, do the required changes in `config.yaml` and execute the `update` subcommand.

    ./kaws update

Notice that this latest method may not work for some changes (i.e. etcd modifications). More information about updates [here](https://kubernetes-incubator.github.io/kube-aws/getting-started/step-4-update.html).

## Optional KMS

Besides the common requirements defined in the project [README](../README.md#requirements), it's optional to provide a **KMS Key**. If not given, the script will create it for you.

To create the KMS Key using the console follow the instructions [here](https://docs.aws.amazon.com/kms/latest/developerguide/create-keys.html#create-keys-console) or use AWS CLI to create it, like this:

        aws kms --region=<your-region> create-key --description="simple kube-o-aws kms"

Provide the KMS ARN ID, which is something like this `arn:aws:kms:us-west-2:xxxxxxxxx:key/xxxxxxxxxxxxxxxxxxx`, into the configuration file `kaws.conf` in the variable `KAWS_KMS`. If the KMS is not provided, it will be created by the script and the config file will have this variable with the KMS ARN. 

## Optional S3 Bucket

KAWS requires an S3 Bucket so `kube-aws` can export all the CloudFormation templates and UserData. Define the environment variable `KAWS_BUCKET` with the bucket name or uses the flag `--s3`.

If the S3 Bucket does not exists `kaws` will create it and saves the variable `KAWS_BUCKET` in the config file with the bucket name.
