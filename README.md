# AM DevOps Repository

This Repository contains all files pertaining to DevOps management.
The repository structure is as follows:


### Source files

    .
    ├── am-ecs                  # ECS creation files (docker-compose)
    │   └── Jenkinsfile             # ECS Jenkinsfile
    ├── ansible                 # Ansible scripts for Ansible Tower
    ├── cloudformation          # Cloudformation infrastructure templates
    ├── kubernetes              # EKS and local creation files (yamls)
    │   ├── Jenkinsfile             # EKS Jenkinsfile (Create)
    │   └── Update.Jenkinsfile      # EKS Jenkinsfile (Update)
    ├── kubernetes              # EKS and local creation files (yamls)
    ├── terraform               # Terraform AWS Infrastructure
    │   ├── modules                 # Terraform submodules
    │   ├── Jenkinsfile             # Terraform Jenkinsfile (Apply)
    │   └── Destroy.Jenkinsfile     # Destroy Jenkinsfile (Terraform, ECS, EKS)
    └── README.md


### File Descriptions

1. Terraform Jenkinsfile is used to set up base Infrastructure. Cloudformation is an alternative.
2. ECS can be launched by using docker-compose up, handled by am-ecs Jenkinsfile.
3. EKS can be launched by calling Tower with variable injection, handled by kubernetes Jenkinsfile.
4. EKS can be updated similarly to launching, handled by kubernetes Update.Jenkinsfile.
5. Terraform Destroy.Jenkinsfile handles destruction of ECS, EKS and Terraform through parameters.
