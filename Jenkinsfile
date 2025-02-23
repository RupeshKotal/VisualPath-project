pipeline {
    agent {
        node {
            label 'maven'
        }
    }

    environment {
        
        PATH = "/opt/apache-maven-3.9.2/bin:$PATH"
    }

  stages {
    stage('Code Clone') {
        steps {
            git branch: 'main' url: ''
        }
    }

    stage('Buil Stage') {
        steps {
            sh 'mvn clean deploy'
        }
    }

    stage('Code Clone') {
        steps {
            git branch: 'main' url: ''
        }
    }


  }

}