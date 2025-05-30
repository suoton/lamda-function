pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    // Zip Lambda function
                    sh 'zip lambda_function.zip lambda_function.py'
                    // Upload to S3
                    sh 'aws s3 cp lambda_function.zip s3://suoton/'
                }
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    // Initialize Terraform
                    sh 'terraform init'
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    // Apply Terraform configuration
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
