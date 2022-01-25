# AM DevOps Repository

This Repository contains all files pertaining to DevOps management.
The repository structure is as follows:


### Source files

    .
    ├── am-ecs                  # ECS creation files (docker-compose)
    │   └── Jenkinsfile             # ECS Jenkinsfile
    ├── kubernetes              # EKS and local creation files (yamls)
    │   └── Jenkinsfile             # EKS Jenkinsfile
    ├── terraform               # Terraform AWS Infrastructure
    │   ├── modules                 # Terraform submodules
    │   └── Jenkinsfile             # Terraform Jenkinsfile
    └── README.md


### Using Files

1. Terraform Jenkinsfile should be run first to initialize AWS resources.
2. ECS can be launched by using docker-compose up.
3. EKS can be launched by injecting environment variables and running eks-init.
4. ECS or EKS are launched in a more stable manner by using their Jenkinsfiles.
