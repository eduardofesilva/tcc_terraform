pipeline{
agent any
    stages{
        stage('Checkout'){
            steps{
                //cleanWs()
                git credentialsId: 'github', url: '${git_repo}'
            }
        }
        stage('Build'){
            steps{
                sh 'cd $WORKSPACE/{project_test_path} && dotnet clean && dotnet restore && dotnet build'
            }
        }
        stage('Test') {
          steps{
            sh 'cd $WORKSPACE/{project_test_path} && dotnet test'
          }
        }
        stage('Run') {
          steps{
            sh 'dotnet run --project $WORKSPACE/{project_path}'
          }
        }
        stage('Release'){
            steps{
                sh 'cd $WORKSPACE/{project_test_path} && dotnet publish -c Release -o published'
            }
        }
        stage('Deploy'){
            steps{
                sh 'cd $WORKSPACE/{project_path}/bin/Release/netcoreapp2.1/ && dotnet ${project_binary}'
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
