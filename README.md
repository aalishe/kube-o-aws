# Kubernetes on AWS

The script `kaws` is going to help you to create a Kubernetes cluster on AWS. It uses [kube-aws](https://github.com/kubernetes-incubator/kube-aws) to create the all the required certificates, CloudFormation templates and UserData to create Kubernetes cluster.

KAWS is non-interactive, it require the inputs in command flags or environment variables exported or defined in the config file `kaws.conf`.

## Requirements

1. An AWS account
2. AWS CLI installed and configure
3. An EC2 Key Pair
4. A Route 53 domain name
5. Kubectl installed and configured, only for testing the created cluster.

## Quick Start

Make sure AWS CLI is installed and configure, verify it wit: `aws configure list`

Create a configuration file with the minimun requirements:

* AWS Key Pair Name
* AWS Route53 Domain Name

These 2 parameters can be provided to the script in environment variables, the config file or parameters.

Create the file `kaws.conf` with the following content. It is not required but recommended to provide the cluster name. Example:

    KAWS_KEY_NAME=mykeypair
    KAWS_DOMAIN_NAME=demo.acme.com
    KAWS_CLUSTER_NAME=kubedemo

Or, pass them to the script like this: `--key-pair mykeypair --domain demo.acme.com --cluster kubedemo`.

Use the subcommand `up` to create the Kubernetes cluster:

    ./kaws up

The configuration files will be in the directory `./kube-aws-kubedemo`.

When the cluster is no needed anymore, destroy it with:

    ./kaws down

The configuration files will continue in the directory `./kube-aws-kubedemo`. To create the cluster again, with the same configuration, use `./kaws up` (without paramaters).

To start over, or create a different cluster, execute the `clean` subcommand: `./kaws clean`

There is more information reading the help: `./kaws help`

## Modify the cluster

The cluster modification can be done in two different ways: recreate or update the cluster after modify the configuration files.

### Recreate the cluster

The `kaws` script uses the `kube-aws` tool to create all the required certificates and CloudFormation Templates for the Kubernetes cluster. All these configuration settings are in the file `cluster.yaml` located in the config directory `./kube-aws-<cluster_name>`.

Use the command `init` to create all the configuration files, CFT and certificates before create the cluster. When done, go to the config directory and modify the `cluster.yaml` file to have a customized cluster.

    ./kaws init

Optionally, use the sumcommand `min` to have a minimized version (no commented lines) of the `cluster.yaml` named `cluster.min.yaml`.

    ./kaws min

After modify the files, execute the subcommand `up` to launch the cluster with the modifications.

    ./kaws up

### Update the cluster

If the cluster is already running and it's required to modify it, do the required changes in `config.yaml` and execute the `update` subcommand.

    ./kaws update

Notice that this latest method may not work for some changes (i.e. etcd modifications). More information about updates [here](https://kubernetes-incubator.github.io/kube-aws/getting-started/step-4-update.html).

## Optional: KMS Key

Besides the requirements defined above, it's optional to provide a **KMS Key**. If not given, the script will create it for you and the config file will have this variable `KAWS_KMS` with the KMS ARN.

To create the KMS Key using the console follow the instructions [here](https://docs.aws.amazon.com/kms/latest/developerguide/create-keys.html#create-keys-console) or use AWS CLI to create it, like this:

        aws kms --region=<your-region> create-key --description="simple kube-o-aws kms"

Provide the KMS ARN ID, which is something like this `arn:aws:kms:us-west-2:xxxxxxxxx:key/xxxxxxxxxxxxxxxxxxx`, into the configuration file `kaws.conf` with the variable `KAWS_KMS`.

Example:

    KAWS_KMS=arn:aws:kms:us-east-1:xxxxxxxxx:key/xxxxxxxxxxxxxxxxxxx

## Optional: S3 Bucket

KAWS requires an S3 Bucket so `kube-aws` can export all the CloudFormation templates and UserData. Define the environment variable `KAWS_BUCKET` with the bucket name or uses the flag `--s3`.

If the S3 Bucket does not exists, or not provided, `kaws` will create it and saves the variable `KAWS_BUCKET` in the config file with the bucket name.

## Optional: Cluster architecture

You may define how many (and where) workers, masters (controllers) and etcd nodes to create in the cluster. This is defined with the variables:

    KAWS_WORKERS=
    KAWS_MASTERS=
    KAWS_ETCDS=

The values this variables accept are:

* **1:1**: This is the default option for `kube-aws`. It is one node in one AZ. For Masters and Workers, there will be a AutoScaling Group amonth all the AZ.
* **1:N**: This option will create one node (worker, master or etcd) on each AZ (there are 3 AZ).

**IMPORTANT**: The option **1:N** for etcd nodes (`KAWS_ETCDS=1:N`) is not working at this time. This will be fix in the future.