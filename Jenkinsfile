pipeline {
    agent {
        node {
            label 'aws-ready'
            customWorkspace "${AM_TERRAFORM_DIRECTORY}"
        }
    }

    environment {
        COMMIT_HASH = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
        AWS_REGION_ID = "${sh(script:'aws configure get region', returnStdout: true).trim()}"
        AWS_ACCOUNT_ID = "${sh(script:'aws sts get-caller-identity --query "Account" --output text', returnStdout: true).trim()}"
        SECRET_ID = "dev/AM/utopia-secrets"
        SECRET_ID_PUSH = "dev/AM/utopia-secrets-NE4x9z"
    }

    parameters {
        booleanParam(name: "APPLY", defaultValue: false)
    }

    stages {

        stage('Terraform Plan') {
            steps {
                echo 'Planning terraform infrastructure'
                dir("terraform") {
                    sh 'mkdir -p plans'
                    sh 'terraform init -no-color'
                    sh 'terraform plan -out plans/plan-${COMMIT_HASH}.tf -no-color > plans/plan-${COMMIT_HASH}.txt'
                }
            }
        }

        stage('Terraform Apply') {
            when { expression { params.APPLY } }
            steps {
                echo 'Applying Terraform objects'
                dir("terraform") {
                    sh 'terraform apply -no-color -auto-approve plans/plan-${COMMIT_HASH}.tf'
                }
            }
        }

        stage('Terraform Output') {
            when { expression { params.APPLY } }
            steps {
                echo 'Exporting outputs as secrets'
                dir("terraform") {
                    sh 'terraform refresh'
                    sh 'terraform output | tr -d \'\\\"\\ \' > env.tf'
                }
            }
        }

        stage('Update Secrets') {
            when { expression { params.APPLY } }
            steps {
                echo 'Writing output to Secrets'
                script {
                    withCredentials([
                        string (credentialsId: env.SECRET_ID,
                        variable: 'DB_CREDS')
                    ]) {
                        // json objects
                        def creds = readJSON text: DB_CREDS
                        def outputs = readProperties file: 'terraform/env.tf'

                        // secret keys
                        creds.AWS_VPC_ID          = outputs.AWS_VPC_ID
                        creds.AWS_RDS_ENDPOINT    = outputs.AWS_RDS_ENDPOINT
                        creds.AWS_ALB_ID          = outputs.AWS_ALB_ID

                        // rewrite secret
                        String jsonOut = writeJSON returnText: true, json: creds
                        sh "aws secretsmanager update-secret --secret-id 'arn:aws:secretsmanager:${AWS_REGION_ID}:${AWS_ACCOUNT_ID}:secret:${SECRET_ID_PUSH}' --secret-string '${jsonOut}'"
                    }
                }
            }
        }

        stage('Cleanup') {
            when { expression { params.APPLY } }
            steps {
                echo 'Removing temp files'
                sh 'rm -f terraform/env.tf'
            }
        }

        //end
    }
}
