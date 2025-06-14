pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    // Zip Lambda function
                    sh 'zip lambda_function.zip lambda_function.py'
                    // Upload to S3 with AWS credentials
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh 'aws s3 cp lambda_function.zip s3://suoton/'
                    }
                }
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    // Initialize Terraform
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh 'terraform init'
                    }
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    // Apply Terraform configuration
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
    }
}
