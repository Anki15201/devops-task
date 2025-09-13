pipeline {
  agent any

  environment {
    AWS_REGION   = "ap-south-1"       // change to your region
    ECR_REPO     = "my-node-app"       // your ECR repo name
    IMAGE_TAG    = "latest"           // or use ${BUILD_NUMBER} for unique tags
    CONTAINER_NAME = "my-app"         // docker container name
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/Anki15201/devops-task.git'
      }
    }

    stage('Test') {
      steps {
        sh '''
          echo "Installing dependencies..."
          npm install
          
          echo "Running tests..."
          npm test || echo "No tests found"
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          sh '''
            echo "Building Docker image..."
            docker build -t ${ECR_REPO}:${IMAGE_TAG} .
          '''
        }
      }
    }

    stage('Login & Push to ECR') {
      steps {
        withCredentials([
          string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            set -e
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

            ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --region ${AWS_REGION})
            ECR_URI=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}

            echo "Logging into ECR..."
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $ECR_URI

            echo "Tagging image..."
            docker tag ${ECR_REPO}:${IMAGE_TAG} $ECR_URI:${IMAGE_TAG}

            echo "Pushing image to ECR..."
            docker push $ECR_URI:${IMAGE_TAG}
          '''
        }
      }
    }

    stage('Deploy') {
      steps {
        withCredentials([
          string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            set -e
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

            ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --region ${AWS_REGION})
            ECR_URI=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}

            echo "Deploying container on same EC2..."

            # Login to ECR
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $ECR_URI

            # Pull latest image
            docker pull $ECR_URI:${IMAGE_TAG}

            # Stop & remove old container if running
            docker stop ${CONTAINER_NAME} || true
            docker rm ${CONTAINER_NAME} || true

            # Run new container
            docker run -d --name ${CONTAINER_NAME} -p 3000:3000 $ECR_URI:${IMAGE_TAG}
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ Pipeline completed successfully! App deployed on EC2."
    }
    failure {
      echo "❌ Pipeline failed! Check logs."
    }
  }
}
