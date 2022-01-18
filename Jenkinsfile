pipeline {
    agent { label 'aws-ready' }

    environment {
        commit = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
        aws_region = 'us-west-2'
        terraform_directory = "terraform"
        resource_directory = "/var/lib/jenkins-worker-node/AM-resources"
    }

    parameters {
        booleanParam(name: "APPLY", defaultValue: true)
    }

    stages {

        stage('System information') {
            steps {
                echo 'Debug info:'
                sh 'ls'
                sh 'pwd'
            }
        }

        stage('Terraform Plan') {
            steps {
                echo 'Planning terraform infrastructure'
                dir("${terraform_directory}") {
                    sh 'mkdir -p plans'
                    sh 'terraform init'
                    sh 'terraform plan -out plans/plan-${commit}.tf -no-color > plans/plan-${commit}.txt'
                }
            }
        }

        stage('Terraform Apply') {
            when { expression { params.APPLY } }
            steps {
                echo 'Applying Terraform objects'
                dir("${terraform_directory}") {
                    sh 'terraform refresh'
                    sh 'terraform apply -auto-approve plans/plan-${commit}.tf'
                }
            }
        }

        stage('Terraform Output') {
            when { expression { params.APPLY } }
            steps {
                echo 'Exporting outputs as variables'
                dir("${terraform_directory}") {
                    sh 'terraform output | tr -d \'\\\"\\ \' > ${resource_directory}/env.tf'
                }
            }
        }

        //end
    }
}
