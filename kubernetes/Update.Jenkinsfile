pipeline {
    agent {
        node {
            label 'aws-ready'
            customWorkspace "${AM_DEVOPS_DIRECTORY}"
        }
    }

    environment {
        // AWS References
        AWS_PROFILE               = "${AWS_PROFILE_NAME}"
        AWS_REGION_ID             = "${AWS_REGION_ID}"
        AWS_ACCOUNT_ID            = "${AWS_ACCOUNT_ID}"

        // Ansible API info
        // for t2.medium: 1930m cpu, 3332Mi, 4 pods
        EKS_CONTAINER_CPU_LIMIT   = "450m"
        EKS_CONTAINER_CPU_REQUEST = "250m"
        EKS_CONTAINER_MEM_LIMIT   = "800Mi"
        EKS_CONTAINER_MEM_REQUEST = "400Mi"
        EKS_REPLICA_COUNT         = 2
        DB_POOL_MIN               = 2
        DB_POOL_MAX               = 4

        // Exists Information
        EKS_SERVICE_NAME  = "nginx-ingress"
        EKS_INGRESS_NS    = "nginx-ingress"
    }

    stages {

        stage('Load Environment') {
            steps {
                sh 'aws configure set region ${AWS_REGION_ID} --profile ${AWS_PROFILE_NAME}'
                script {
                    // Load from AWS Secret
                    secret = sh(returnStdout: true, script: 'aws secretsmanager get-secret-value --secret-id ${AM_SECRET_ID} | jq -Mr \'.SecretString\'').trim()
                    def jsonObj = readJSON text: secret
                    env.AWS_RDS_ENDPOINT    = jsonObj.AWS_RDS_ENDPOINT
                    env.FLIGHTS_API_LATEST  = jsonObj.FLIGHTS_API_LATEST
                    env.BOOKINGS_API_LATEST = jsonObj.BOOKINGS_API_LATEST
                    env.USERS_API_LATEST    = jsonObj.USERS_API_LATEST
                    env.AUTH_API_LATEST     = jsonObj.AUTH_API_LATEST
                    env.EKS_CLUSTER_NAME    = jsonObj.EKS_CLUSTER_NAME
                }
            }
        }

        stage('Check EKS Exists') {
            steps {
                script {
                    EKSExists()
                }
            }
        }

        stage('Push EKS') {
            steps {
                echo 'Running Kubernetes Initialization'
                script {
                  ansibleTower(
                        towerServer: 'AM-Ansible-Tower-EC2',
                        jobTemplate: 'AM_K8S_Update',
                        extraVars: '''
                            AWS_REGION_ID: "${AWS_REGION_ID}"
                            AWS_ACCOUNT_ID: "${AWS_ACCOUNT_ID}"
                            AWS_SECRET_ID: "${AM_SECRET_ID}"

                            EKS_CONTAINER_CPU_LIMIT: "${EKS_CONTAINER_CPU_LIMIT}"
                            EKS_CONTAINER_CPU_REQUEST: "${EKS_CONTAINER_CPU_REQUEST}"
                            EKS_CONTAINER_MEM_LIMIT: "${EKS_CONTAINER_MEM_LIMIT}"
                            EKS_CONTAINER_MEM_REQUEST: "${EKS_CONTAINER_MEM_REQUEST}"
                            EKS_REPLICA_COUNT: "${EKS_REPLICA_COUNT}"

                            FLIGHTS_API_LATEST: "${FLIGHTS_API_LATEST}"
                            BOOKINGS_API_LATEST: "${BOOKINGS_API_LATEST}"
                            USERS_API_LATEST: "${USERS_API_LATEST}"
                            AUTH_API_LATEST: "${AUTH_API_LATEST}"
                        '''
                    )
                }
            }
        }

        // end stages
    }
}

def EKSExists() {
    sh 'aws eks --region ${AWS_REGION_ID} update-kubeconfig --name ${EKS_CLUSTER_NAME}'
    sh 'kubectl get service --namespace ${EKS_INGRESS_NS} ${EKS_SERVICE_NAME}'
}
