def ECS_EXISTS = false
def EKS_EXISTS = false

pipeline {

    // AGENT SETUP
    agent {
        node {
            label 'aws-ready'
            customWorkspace "${AM_DEVOPS_DIRECTORY}"
        }
    }

    // ENVIRONMENT SETUP
    environment {
        // General use
        COMMIT_HASH       = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
        SERVICE_NAME      = "nginx-ingress"
        SERVICE_NAMESPACE = "nginx-ingress"
        CONTEXT_NAME      = "${AWS_PROFILE_NAME}"
        SECRET_ID         = "dev/AM/utopia-secrets"

        // Terraform passthrough
        TF_VAR_ECS_RECORD         = "${AM_ECS_RECORD_NAME}"
        TF_VAR_EKS_RECORD         = "${AM_EKS_RECORD_NAME}"
        TF_VAR_HOSTED_ZONE        = "${AWS_HOSTED_ZONE_ID}"
        TF_VAR_REGION_ID          = "${AWS_REGION_ID}"
        TF_VAR_AWS_ACCESS_KEY     = credentials('AM_AWS_ACCESS')
        TF_VAR_AWS_SECRET_KEY     = credentials('AM_AWS_SECRET')
        TF_VAR_SSH_BASTION_KEY    = credentials('AM_SSH_BASTION')
        TF_VAR_AWS_SECRET_ID      = "${AM_SECRET_ID}"
        TF_VAR_AZ_1               = "${AWS_REGION_AZ_1}"
        TF_VAR_AZ_2               = "${AWS_REGION_AZ_2}"

        AWS_PROFILE               = "${AWS_PROFILE_NAME}"
    }

    // PARAM SETUP
    parameters {
        choice(
            name: 'DestroyType',
            choices: ['ECS', 'EKS', 'Terraform'],
            description: '''Determines which infrastructure to delete.
   - ECS: Destroys ECS resources via Docker Compose Down, and leaves Terraform infrastructure intact.
   - EKS: Destroys EKS LoadBalancer and Service resources, and leaves Terraform infrastructure intact.
   - Terraform: Performs the previous two destruction methods, and then destroys all Terraform infrastructure.'''
        )
    }

    // STAGE DEFINITIONS
    stages {

        ///////////
        // SETUP //
        ///////////

        stage('Load Environment') {
            steps {
                sh 'aws configure set region ${AWS_REGION_ID} --profile ${AWS_PROFILE_NAME}'
                script {
                    secret = sh(returnStdout: true, script: 'aws secretsmanager get-secret-value --secret-id ${SECRET_ID} | jq -Mr \'.SecretString\'').trim()
                    def jsonObj = readJSON text: secret
                    env.TF_VAR_DB_USERNAME  = jsonObj.DB_USERNAME
                    env.TF_VAR_DB_PASSWORD  = jsonObj.DB_PASSWORD
                    env.EKS_CLUSTER_NAME    = jsonObj.AWS_EKS_CLUSTER_NAME
                }
            }
        }

        /////////
        // EKS //
        /////////

        // Check EKS resources exist for EKS destroy. Build failed if fail.
        stage('EKS Exists (EKS Only)') {
            when { expression { params.DestroyType == 'EKS' } }
            steps {
                echo 'Confirming EKS Resources exist...'
                EKSExists()
                script { EKS_EXISTS = true }
            }
            post {
                unsuccessful {
                    echo 'Failed to find EKS resources. Pipeline failed for EKS Only.'
                }
            }
        }

        // Check EKS resources exist for Terraform destroy. Stage Unstable if false, Stable if true.
        stage('EKS Exists (Terraform)') {
            when { expression { params.DestroyType == 'Terraform' } }
            steps {
                echo 'Confirming EKS Resources exist...'
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    EKSExists()
                }
            }
            post {
                success {
                    script {
                        EKS_EXISTS = true
                    }
                }
            }
        }

        // Destroy EKS resources. Build Failure if fail.
        stage('EKS Destroy') {
            when {
                allOf {
                    anyOf {
                        expression { params.DestroyType == 'EKS' }
                        expression { params.DestroyType == 'Terraform' }
                    }
                    expression { EKS_EXISTS == true }
                }
            }
            steps {
                echo 'Destroying EKS Resources within Cluster'
                EKSDestroy()
            }
        }

        /////////
        // ECS //
        /////////

        // Check ECS resources exist for ECS destroy. Build failed if fail.
        stage('ECS Exists (ECS Only)') {
            when { expression { params.DestroyType == 'ECS' } }
            steps {
                  echo 'Confirming ECS Resources exist...'
                  ECSExists()
                  script { ECS_EXISTS = true }
            }
            post {
                unsuccessful {
                    echo 'Failed to find ECS resources. Pipeline failed for ECS Only.'
                }
            }
        }

        // Check ECS resources exist for Terraform destroy. Stage Unstable if false, Stable if true.
        stage('ECS Exists (Terraform)') {
            when { expression { params.DestroyType == 'Terraform' } }
            steps {
                echo 'Confirming ECS Resources exist...'
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    ECSExists()
                }
            }
            post {
                success {
                    script {
                        ECS_EXISTS = true
                    }
                }
            }
        }

        // Destroy ECS resources. Build Failure if fail.
        stage('ECS Destroy') {
            when {
                allOf {
                    anyOf {
                        expression { params.DestroyType == 'ECS' }
                        expression { params.DestroyType == 'Terraform' }
                    }
                    expression { ECS_EXISTS == true }
                }
            }
            steps {
                echo 'Destroying ECS Resources within Cluster'
                ECSDestroy()
            }
        }

        ///////////////
        // Terraform //
        ///////////////

        // Destroy Terraform resources. Build Failure if fail.
        stage('Terraform Destroy') {
            when { expression { params.DestroyType == 'Terraform' } }
            steps {
                echo "Things are: ${EKS_EXISTS} and ${ECS_EXISTS} and ${params.DestroyType}"
                echo 'Destroying existing Terraform Infrastructure'
                dir("terraform") {
                    sh 'terraform refresh -no-color'
                    sh 'terraform plan -destroy -out plans/plan-destroy-${COMMIT_HASH}.tf -no-color > plans/plan-destroy-${COMMIT_HASH}.txt'
                    sh 'terraform apply -no-color -auto-approve plans/plan-destroy-${COMMIT_HASH}.tf'
                }
            }
        }

        // end stages
    }
}

///////////////
// Functions //
///////////////

def EKSExists() {
    sh 'aws eks --region ${AWS_REGION_ID} update-kubeconfig --name ${EKS_CLUSTER_NAME}'
    sh 'kubectl get service --namespace ${SERVICE_NAMESPACE} ${SERVICE_NAME}'
}

def EKSDestroy() {
    ansibleTower(
        towerServer: 'AM-Ansible-Tower-EC2',
        jobTemplate: 'AM_K8S_Destroy',
        extraVars: '''
            AWS_REGION_ID: "${AWS_REGION_ID}"
        '''
    )
}

def ECSExists() {
    dir("am-ecs") {
        sh 'docker context use ${AWS_PROFILE_NAME}'
        sh 'docker compose ps'
    }
}

def ECSDestroy() {
    dir("am-ecs") {
        sh 'docker compose down'
    }
}
