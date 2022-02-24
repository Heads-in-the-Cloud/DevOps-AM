pipeline {
    agent {
        node {
            label 'aws-ready'
            customWorkspace "${AM_DEVOPS_DIRECTORY}"
        }
    }

    environment {
        SECRET_ID                 = 'dev/AM/utopia-secrets'
        AWS_PROFILE               = "${AWS_PROFILE_NAME}"
        AWS_REGION_ID             = "${AWS_REGION_ID}"
        AWS_ACCOUNT_ID            = "${AWS_ACCOUNT_ID}"

        // for t2.medium: 1930m cpu, 3332Mi, 4 pods
        EKS_CONTAINER_CPU_LIMIT   = "450m"
        EKS_CONTAINER_CPU_REQUEST = "250m"
        EKS_CONTAINER_MEM_LIMIT   = "800Mi"
        EKS_CONTAINER_MEM_REQUEST = "400Mi"
        EKS_REPLICA_COUNT         = 2

        DB_POOL_MIN               = 2
        DB_POOL_MAX               = 4
    }

    stages {

        stage('Load Images') {
            steps {
                echo "Loading latest image hashes"
                dir("${AM_RESOURCES_DIRECTORY}") {
                    script {
                        env.USERS_API_LATEST = sh(script:'jq -Mr \'.users\' images-${AWS_REGION_ID}.json', returnStdout: true)
                        env.BOOKINGS_API_LATEST = sh(script:'jq -Mr \'.bookings\' images-${AWS_REGION_ID}.json', returnStdout: true)
                        env.FLIGHTS_API_LATEST = sh(script:'jq -Mr \'.flights\' images-${AWS_REGION_ID}.json', returnStdout: true)
                        env.AUTH_API_LATEST = sh(script:'jq -Mr \'.auth\' images-${AWS_REGION_ID}.json', returnStdout: true)
                    }
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
                            AWS_ACCOUNT_ID: "${}"
                            AWS_SECRET_ID:

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
