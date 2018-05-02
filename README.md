# wordpress-cookbook

## Prerequisite

- Install Homebrew
```
$ 
```

- Install AWS-Cli
```
$ brew install awscli
```

- Set your creadential
```
$ cat ~/.aws/credentials
[default]
aws_access_key_id = (your key id)
aws_secret_access_key = (your secrete key)
region = (your region)
```

## How to set up

### Set environment variables

```
# Copy template file
$ cp ./.env/init/params.sample ./.env/init/params

# Input your aws account number
$ vim ./.env/init/params

# Set environment
$ cat ./.env/init/params >> ~/.bashrc
$ source ~/.bashrc
```

### Set layer configuration

```
# Copy template file
$ cp ./.env/layer/layer.json.sample ./.env/layer/layer.json

# Input your domain
$ vim ./.env/layer/layer.json
```

### EC2

- Create Key pair
```
$ mkdir ~/.ssh
$ aws ec2 create-key-pair --key-name $key_name | grep KeyMaterial | cut -d\" -f4 | perl -pe 's/\\n/\n/g' > ~/.ssh/$key_name.pem
$ chmod 400 ~/.ssh/$key_name.pem
```

### IAM

- Create Role
```
$ aws iam create-role --role-name WatchInstance --assume-role-policy-document file://./.env/roles/instance-role.json
$ aws iam create-role --role-name OpsworksService --assume-role-policy-document file://./.env/roles/opsworks-role.json
```
- Create Policy
```
$ aws iam create-instance-profile --instance-profile-name OpsworksInstance
$ aws iam create-policy --policy-name aws-opsworks-service-policy --policy-document file://./.env/policies/opsworks.json
```
- Attach Policy
```
$ aws iam attach-role-policy --role-name WatchInstance --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess
$ aws iam attach-role-policy --role-name OpsworksService --policy-arn arn:aws:iam::$my_aws_account:policy/aws-opsworks-service-policy
$ aws iam add-role-to-instance-profile --instance-profile-name OpsworksInstance --role-name WatchInstance
```

### Opsworks
- Create stack
```
$ aws opsworks create-stack --name $stack_name --service-role-arn arn:aws:iam::"$my_aws_account":role/OpsworksService --default-instance-profile-arn arn:aws:iam::"$my_aws_account":instance-profile/OpsworksInstance --stack-region ap-southeast-1 --default-os 'Amazon Linux 2017.09' --configuration-manager Name='Chef',Version=12 --custom-cookbooks-source Type=git,Url=https://github.com/taxkeller/wordpress-cookbook.git --use-custom-cookbooks --default-root-device-type ebs | grep StackId | cut -d\" -f4 > ./.env/opsworks-ids/stack-id
```

- Create Layer
```
$ aws opsworks create-layer --stack-id `cat ./.env/opsworks-ids/stack-id` --type custom --name wordpress --shortname wp --custom-json file://./.env/layer/layer.json --auto-assign-public-ips --custom-recipes Setup=environment,php,nginx,git,mariadb,logs,wp | grep LayerId | cut -d\" -f4 > ./.env/opsworks-ids/layer-id
```

- Create Instance
```
$ aws opsworks create-instance --stack-id `cat ./.env/opsworks-ids/stack-id` --layer-ids `cat ./.env/opsworks-ids/layer-id` --instance-type t2.micro --ssh-key-name $key_name | grep InstanceId | cut -d\" -f4 > ./.env/opsworks-ids/instance-id
```

- Start Instance
```
$ aws opsworks start-instance --instance-id `cat ./.env/opsworks-ids/instance-id`
```

## How to remove

- Remove opwsorks

```
$ aws opsworks stop-instance --instance-id `cat ./.env/opsworks-ids/instance-id`
$ aws opsworks delete-instance --instance-id `cat ./.env/opsworks-ids/instance-id`
$ aws opsworks delete-layer --layer-id `cat ./.env/opsworks-ids/layer-id`
$ aws opsworks delete-stack --stack-id `cat ./.env/opsworks-ids/stack-id`
```

- Remove role & policies

```
$ aws iam remove-role-from-instance-profile --instance-profile-name OpsworksInstance --role-name WatchInstance
$ aws iam detach-role-policy --role-name OpsworksService --policy-arn arn:aws:iam::$my_aws_account:policy/aws-opsworks-service-policy
$ aws iam detach-role-policy --role-name WatchInstance --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess
$ aws iam delete-policy --policy-arn arn:aws:iam::$my_aws_account:policy/aws-opsworks-service-policy
$ aws iam delete-instance-profile --instance-profile-name OpsworksInstance
$ aws iam delete-role --role-name OpsworksService
$ aws iam delete-role --role-name WatchInstance
```

- Remove key

```
$ aws ec2 delete-key-pair --key-name $key_name
```
