pipeline {
    agent {
        node {
            label 'aws-ready'
            customWorkspace "${AM_DEVOPS_DIRECTORY}"
        }
    }

    environment {
        SECRET_ID                         = 'dev/AM/utopia-secrets'
        AWS_PROFILE                       = "${AWS_PROFILE_NAME}"

        ANSIBLE_AWS_SECRET_ID             = "${SECRET_ID}"
        ANSIBLE_AWS_REGION_ID             = "${AWS_REGION_ID}"
        ANSIBLE_AWS_ACCOUNT_ID            = "${AWS_ACCOUNT_ID}"

        // for t2.medium: 1930m cpu, 3332Mi, 4 pods
        ANSIBLE_EKS_CONTAINER_CPU_LIMIT   = "450m"
        ANSIBLE_EKS_CONTAINER_CPU_REQUEST = "250m"
        ANSIBLE_EKS_CONTAINER_MEM_LIMIT   = "800Mi"
        ANSIBLE_EKS_CONTAINER_MEM_REQUEST = "400Mi"
        ANSIBLE_EKS_REPLICA_COUNT         = 2

        DB_POOL_MIN               = 2
        DB_POOL_MAX               = 4

        TOWER_ENDPOINT          = "https://am-ansible.hitwc.link"
        TOWER_JOBNUM            = "14"
        TOWER_WEBHOOK           = "${TOWER_ENDPOINT}/api/v2/job_templates/${TOWER_JOBNUM}/launch/"
    }

    stages {

        stage('Load Environment') {
            steps {
                sh 'aws configure set region ${AWS_REGION_ID} --profile ${AWS_PROFILE_NAME}'
                script {
                    secret = sh(returnStdout: true, script: 'aws secretsmanager get-secret-value --secret-id ${SECRET_ID} | jq -Mr \'.SecretString\'').trim()
                    def jsonObj = readJSON text: secret
                    env.EKS_CLUSTER_NAME    = jsonObj.AWS_EKS_CLUSTER_NAME
                    env.TOWER_AUTH          = jsonObj.ANSIBLE_TOKEN
                }
            }
        }

        stage('Load Images') {
            steps {
                echo "Loading latest image hashes"
                dir("${AM_RESOURCES_DIRECTORY}") {
                    script {
                        env.ANSIBLE_USERS_API_LATEST = sh(script:'jq -Mr \'.users\' images-${AWS_REGION_ID}.json', returnStdout: true)
                        env.ANSIBLE_BOOKINGS_API_LATEST = sh(script:'jq -Mr \'.bookings\' images-${AWS_REGION_ID}.json', returnStdout: true)
                        env.ANSIBLE_FLIGHTS_API_LATEST = sh(script:'jq -Mr \'.flights\' images-${AWS_REGION_ID}.json', returnStdout: true)
                        env.ANSIBLE_AUTH_API_LATEST = sh(script:'jq -Mr \'.auth\' images-${AWS_REGION_ID}.json', returnStdout: true)
                    }
                }
            }
        }

        stage('Push EKS') {
            steps {
                echo 'Running Kubernetes Initialization'
                dir("${AM_DEVOPS_DIRECTORY}/ansible") {
                    echo "Getting required Environment Variables as YAML"
                    sh "env | grep 'ANSIBLE_' | sed -r 's/ANSIBLE_//g' | sed -r 's/[=]+/: /g' > tmp_env.yaml"

                    echo "Converting YAML to JSON"
                    sh "python -c 'import json, yaml, sys; print(json.dumps(yaml.safe_load(sys.stdin)))' < tmp_env.yaml > tmp_env.json"

                    echo "Formatting for Ansible (extra_vars: )"
                    sh "jq -n -M --argjson insert \"\$(<tmp_env.json)\" '{extra_vars: \$insert}' > tmp_env_done.json"

                    echo "Posting to Ansible Tower"
                    sh "curl -X POST -k ${TOWER_WEBHOOK} -H \"Content-Type: application/json\" -H \"Authorization: Bearer ${TOWER_AUTH}\" -d \"@tmp_env_done.json\""                }
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Cleaning temp files'
                dir("${AM_DEVOPS_DIRECTORY}/ansible") {
                    sh 'rm tmp_env*'
                }
            }
        }

        // end stages
    }
}
