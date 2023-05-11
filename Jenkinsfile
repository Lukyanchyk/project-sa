pipeline {
    triggers { pollSCM 'H/5 * * * *' }
	environment {
		registry = "lukyanchyk/project-sa"
		registryCredential = 'dockerhub'
    }
    agent {label 'master'}
    stages {
		stage('Cloning Git') {
			steps {
				git url: 'https://github.com/Lukyanchyk/project-sa.git', branch: 'main'
				sh 'ls -l'
			}
		}
		stage ("Lint dockerfile") {
			agent {
				docker {
					image 'hadolint/hadolint:latest-debian'
					label 'master'
				}
			}
			steps {
				sh 'hadolint Dockerfile | tee -a hadolint_lint.txt'
			}
			post {
				always {
					archiveArtifacts 'hadolint_lint.txt'
				}
			}
		}
		stage('Building image') {
			steps{ 
				script {
					dockerImage = docker.build registry + ":$BUILD_NUMBER" , "./Docker"
					//dockerImage = docker.build registry + ":$BUILD_NUMBER" , "--network host ."
				}
			}
		}
		stage('Push Image to repo') {
			steps{
				script {
					docker.withRegistry( '', registryCredential ) {
						dockerImage.push()
					}
				}
			}
		}
		stage('Remove Unused docker image') {
			steps{
				sh "docker rmi $registry:$BUILD_NUMBER"
			}
		}
        stage('Deploy Worpress') {
            steps{
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE'){
                        try{
                            sh """
                            sed -i 's/50/$BUILD_NUMBER/' ./wordpress/values.yaml
                            sed -i 's/0.0.15/$BUILD_NUMBER/' ./wordpress/Chart.yaml
                            helm dependency update ./wordpress
                            helm upgrade --install --set mariadb.enabled=false,externalDatabase.host=192.168.201.12,externalDatabase.user=db_wp_admin,externalDatabase.password=db_wp_admin,externalDatabase.database=wordpress,global.storageClass=nfs-wordpress,wordpressUsername=wp_admin,wordpressPassword=wp_admin,livenessProbe.initialDelaySeconds=600,readinessProbe.initialDelaySeconds=60 --debug --wait --timeout 3m --namespace=wordpress wordpress5 ./helm-source
                            """
                        }
                        catch(err){
                            sh "helm rollback wordpress5 --namespace=wordpress"
                        }
                    }
                }
            }
        }
    }
	post {
		success {
			slackSend (color: '#00FF00', message: "\1 Deployment was successfuly done:\1 \n\n Job name --> ${env.JOB_NAME} \n Build number --> ${env.BUILD_NUMBER}    (${env.BUILD_URL})")
		}
		failure {
			slackSend (color: '#FF0000', message: "Deployment was failed: \n\n Job name --> ${env.JOB_NAME} \n Build number --> ${env.BUILD_NUMBER}    (${env.BUILD_URL})")
		}
	}
}