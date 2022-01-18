pipeline {
    agent { label 'aws-ready' }

    environment {
        commit = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
        aws_region = 'us-west-2'
        apply = true
        terraform_directory = "terraform"
        resource_directory = "/var/lib/jenkins-worker-node/AM-resources"
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

        stage('Terraform Output') {
            steps {
                script {
                    if (env.apply == true) {
                        echo 'Exporting outputs as variables'
                        dir("${terraform_directory}") {
                            sh 'terraform output | tr -d \'\\\"\\ \' > ${resource_directory}/env.tf'
                        }
                    }
                }
            }
        }

        //end
    }
}
