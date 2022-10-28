# terraform-k8s-docker-registry-simple
This repository for practice setup docker registry by using IaC Terraform and create template modules for other projects.

# RUN 

## exec dev shell
```bash
nix-shell 
```
## init clusters 

```bash
init-clusters
```
## create certs for docker 
```bash
init-certs-docker-registry
```
## chose storage provider nfs/aws/gcp
### nfs
if u not have nfs server start simple nfs server 
```bash
start-nfs-server-docker
```
and put ip for kubernetes storage class in env/nfs/variables.<br>
Then init and apply terraform
```bash
terraform -chdir=./env/nfs init
terraform -chdir=./env/nfs apply
```
destroy
```bash
destroy-clusters
``` 



# TODO
1) create storage class into k8s
- [x] nfs storage provider 
- [] aws storage provider
- [] gcp storage provider
2) create docker registry 
- [x] init certs for domain
- [] create simple ci for test pull/push image
- [] add rotate image by date/count

