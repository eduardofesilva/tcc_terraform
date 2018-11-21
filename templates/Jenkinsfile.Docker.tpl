pipeline{
    agent {label 'ec2'}
    stages{
        stage('Checkout')
        {
            steps{
                git credentialsId: 'github', url: 'git@github.com:dotnet/dotnet-docker.git'
            }
        }
        stage('Build')
        {
            steps{
                dir('./samples/dotnetapp') {
                    sh 'docker build --pull -t ${image_name}:${build_tag} -f ${dockerfile_name} .'
                }
            }
        }
        stage('Test')
        {
            steps{
                dir('./samples/dotnetapp') {
                    sh 'docker build --pull --target testrunner -t ${image_name}:${test_tag} -f ${dockerfile_name} .'
                }
            }
        }
        stage('Publish')
        {
            steps{
                    withCredentials([usernamePassword(credentialsId: 'docker_credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh 'docker login -u $${USER} -p $${PASS}'
                        sh 'docker tag ${image_name}:${build_tag} ${repo_name}/${image_name}:latest'
                        sh 'docker push ${repo_name}/${image_name}:latest'
                    }
            }
        }
    }
    post{
        success{
            slackSend baseUrl: 'https://eduardofonseca.slack.com/services/hooks/jenkins-ci/', botUser: true, channel: '${slack_channel}', color: 'good', failOnError: true, message: "Build $${JOB_NAME} #$${BUILD_NUMBER} finalizado com sucesso", tokenCredentialId: 'slack'
        }
        failure{
            slackSend baseUrl: 'https://eduardofonseca.slack.com/services/hooks/jenkins-ci/', botUser: true, channel: '${slack_channel}', color: 'danger', failOnError: true, message: "Build $${JOB_NAME} #$${BUILD_NUMBER} falhou", tokenCredentialId: 'slack'
    }
    }
}
