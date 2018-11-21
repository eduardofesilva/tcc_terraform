pipeline{
    agent any
    stages{
        stage('Checkout'){
            steps{
                git credentialsId: 'github', url: 'git@github.com:dotnet/samples.git'
            }
        }
        stage('Build'){
            steps{
                //sh 'cd $WORKSPACE/core/console-apps/NewTypesMsBuild/src/NewTypes'
                sh 'dotnet run --project $WORKSPACE/core/console-apps/NewTypesMsBuild/src/NewTypes'
            }
        }
    }
}
