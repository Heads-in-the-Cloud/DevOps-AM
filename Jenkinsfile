pipeline {
    agent { label 'aws-ready' }

    environment {
        commit = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
        aws_region = 'us-west-2'
        apply = false
        terraform_directory = "terraform"
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
        stage('Terraform Output') {
            steps {
                sh 'terraform output | tr -d \'\\\"\\ \''
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    if (env.apply == true) {
                        echo 'Applying Terraform objects'
                        dir("${terraform_directory}") {
                            sh 'terraform refresh'
                            sh 'terraform apply -auto-approve plans/plan-${commit}.tf'
                        }
                    } else {
                        echo 'Skipping Terraform Apply'
                    }
                }
            }
        }
    }
}
