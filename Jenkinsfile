pipeline {
    agent none

    environment {
        REPO_URL        = 'https://github.com/anirban-pal-web/InfluxDB-OCI.git'
        TF_BRANCH       = 'master'
        ANSIBLE_BRANCH  = 'role'
        TF_DIR          = 'terraform-influxdb-modular'
        TF_BINARY       = '/usr/bin/terraform'
    }

    stages {

        // ==============================
        // TERRAFORM STAGES (built-in)
        // ==============================

        stage('Checkout Terraform') {
            agent { label 'built-in' }
            steps {
                cleanWs()
                git branch: "${TF_BRANCH}", url: "${REPO_URL}"
            }
        }

        stage('Terraform FMT, Init & Validate') {
            agent { label 'built-in' }
            steps {
                dir("${TF_DIR}") {
                    sh "${TF_BINARY} fmt -recursive"
                    sh "${TF_BINARY} init"
                    sh "${TF_BINARY} validate"
                }
            }
        }

        stage('Select Action') {
            agent { label 'built-in' }
            steps {
                script {
                    def userChoice = input(
                        message: "Select Action",
                        parameters: [
                            choice(
                                name: 'ACTION',
                                choices: ['apply', 'destroy'],
                                description: 'Choose Action'
                            )
                        ]
                    )
                    env.ACTION = userChoice
                }
            }
        }

        stage('Terraform Plan') {
            agent { label 'built-in' }
            steps {
                dir("${TF_DIR}") {
                    sh "${TF_BINARY} plan -out=tfplan"
                }
            }
        }

        stage('Approval') {
            agent { label 'built-in' }
            steps {
                script {
                    input message: "Approve ${env.ACTION}?"
                }
            }
        }

        stage('Terraform Execute') {
            agent { label 'built-in' }
            steps {
                dir("${TF_DIR}") {
                    script {

                        if (env.ACTION == 'apply') {

                            sh "${TF_BINARY} apply -auto-approve tfplan"

                            env.INFLUX_HOST = sh(
                                script: "${TF_BINARY} output -raw influx_private_ip",
                                returnStdout: true
                            ).trim()

                            env.ALB_URL = sh(
                                script: "${TF_BINARY} output -raw influxdb_url",
                                returnStdout: true
                            ).trim()

                        } else {

                            input message: "⚠️ Confirm Destroy?"
                            sh "${TF_BINARY} destroy -auto-approve"

                        }
                    }
                }
            }
        }

        // ==============================
        // ANSIBLE STAGE (role branch)
        // ==============================

        stage('Run Ansible (role branch)') {
            when {
                expression { env.ACTION == 'apply' }
            }
            agent { label 'ansible-agent' }
            steps {

                dir('role-branch') {

                    deleteDir()

                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "*/${ANSIBLE_BRANCH}"]],
                        userRemoteConfigs: [[
                            url: "${REPO_URL}"
                        ]]
                    ])

                    sh """
                          export PATH=\$PATH:/home/ubuntu/.local/bin
                          ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
                          -i infludDB-ROLE/aws_ec2.yaml \
                          --private-key=/home/ubuntu/Ansible/test15.pem \
                          -u ubuntu \
                          infludDB-ROLE/deploy.yml
                    """
                }
            }
        }

        // ==============================
        // HEALTH CHECK
        // ==============================

        stage('Health Check') {
            when {
                expression { env.ACTION == 'apply' }
            }
            agent { label 'built-in' }
            steps {
                sh "curl -f ${ALB_URL}/health"
            }
        }
    }

    // ==============================
    // POST SECTION
    // ==============================

    post {

        success {
            emailext(
                subject: "✅ ${env.ACTION?.toUpperCase()} SUCCESS | Build #${env.BUILD_NUMBER}",
                body: """
Action      : ${env.ACTION}
Primary IP  : ${env.INFLUX_HOST}
ALB URL     : ${env.ALB_URL}
Build       : ${env.BUILD_NUMBER}

Status: SUCCESS ✅
""",
                to: "mr.anirbanp@gmail.com"
            )
        }

        failure {
            emailext(
                subject: "❌ ${env.ACTION?.toUpperCase()} FAILED | Build #${env.BUILD_NUMBER}",
                body: """
Action      : ${env.ACTION}
Build       : ${env.BUILD_NUMBER}

Status: FAILED ❌
Check Jenkins Console Logs.
""",
                to: "mr.anirbanp@gmail.com"
            )
        }

        aborted {
            emailext(
                subject: "⚠️ BUILD ABORTED | Build #${env.BUILD_NUMBER}",
                body: """
Action      : ${env.ACTION}
Build       : ${env.BUILD_NUMBER}

Pipeline was aborted.
""",
                to: "mr.anirbanp@gmail.com"
            )
        }

        always {
            echo "Pipeline completed at ${new Date()}"
        }
    }
}
