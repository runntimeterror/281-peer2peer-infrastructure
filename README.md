# 281-peer2peer-infrastructure

## Architecture Diagram
![Architecture Diagram](./diagrams/281p2-InfrastructureDiagramV1.jpg "V1")

## Sequence Diagram
![Sequence Diagram](./diagrams/moochat-sessions-sequence.jpeg)

## Run
```
# Install Terraform
$ aws configure # access/secret key, region...
$ terraform login # requires terraform cloud account
$ terraform init -reconfigure # prevents migrating local state into cloud
$ terraform plan # check changes
$ terraform apply # provision aws resources
```
