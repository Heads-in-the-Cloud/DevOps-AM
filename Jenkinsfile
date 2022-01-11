pipeline {
    agent { label 'aws-ready' }

    environment {
        commit = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
        aws_region = 'us-west-2'
    }

    stages {
        stage('System information') {
            steps {
                echo 'Debug info:'
                sh 'ls'
                sh 'pwd'
            }
        }
        stage('AWS') {
            steps {
                echo 'logging in via AWS client'
                // sh 'aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repo}.dkr.ecr.${aws_region}.amazonaws.com'
            }
        }
        stage('Apply') {
            steps {
                echo 'Applying Terraform config'
                sh 'mkdir -p plans'
                sh 'terraform init'
                sh 'terraform plan -out plans/plan-${commit}'
                sh 'terraform apply -auto-approve plans/plan-${commit}'
            }
        }
    }
}
