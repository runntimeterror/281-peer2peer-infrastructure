# moo-chat-infrastructure
- Additional Repos: [UI](https://github.com/runntimeterror/moo-chat), [Socket Server](https://github.com/runntimeterror/moo-chat-socket-server)
- University Project for www.sjsu.edu.
- Course: [Cloud Technology](http://info.sjsu.edu/web-dbgen/catalog/courses/CMPE281.html)
- Professor: [Sanjay Garje](https://www.linkedin.com/in/sanjaygarje/)


Students:
- [Soham Bhattacharjee](mailto:soham.bhattacharjee@sjsu.edu)
- [Gabriel Chen](mailto:gabriel.chen@sjsu.edu)
- [Rajat Banerjee](mailto:rajat.banerjee@sjsu.edu)
- [Rohan Patel](mailto:rohan.patel@sjsu.edu)

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
