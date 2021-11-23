# moochat-infrastructure

## Architecture Diagram
![Architecture Diagram](./diagrams/281p2-InfrastructureDiagramV2.jpeg "V2")

## Infrastructure As Code
![IAC Diagram](./diagrams/InfrastructureAsCodeDiagram.jpeg "IAC")

## Run
```
# Install Terraform
$ aws configure # access/secret key, region... alternatively utilize aws-vault
$ terraform login # requires terraform cloud account
$ terraform init -reconfigure # prevents migrating local state into cloud
$ terraform plan # check changes
$ terraform apply # provision aws resources
```
