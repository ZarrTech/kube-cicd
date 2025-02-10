def COLOR_MAP = [
    "SUCCESS": 'good',
    "FAILURE": 'danger',
    "UNSTABLE": 'warning',
    "ABORTED" : 'gray'
]

pipeline{

    agent any

    environment {
        JAVA_HOME = '/opt/java/openjdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        S3_BUCKET_NAME = 'vproartifact'
        S3_BUCKET_REGION = 'us-east-1'
        s3Credentials= 's3Credencials'
    }

    tools{
        maven 'maven'
        jdk 'jdk17'
    }

    stages{
        stage('clone repo'){
            steps{
                git branch: 'atom', url: 'https://github.com/ZarrTech/CI-CD-project.git'
            }
        }
        stage('Fetch files') {
            steps {
                sh """
                    rm -rf temp-repo
                    git clone git@github.com:ZarrTech/CI-CD-project.git temp-repo
                    cp -r temp-repo/Jenkinsfile temp-repo/app temp-repo/configs temp-repo/db temp-repo/docker-compose.yaml temp-repo/jenkins temp-repo/web .
                    rm -rf temp-repo
                """
            }
        }
        stage('Verify JAVA_HOME') {
            steps {
                sh 'echo $JAVA_HOME'
                sh '/opt/java/openjdk/bin/java -version'
            }
        }
        stage('build'){
            steps{
                sh 'mvn -X clean package'
            }
        }
        stage('Unit test'){
            steps{
                sh "mvn -Djava.home=$JAVA_HOME test"
                sh 'mvn test'
            }
        }
        stage('checkstyle'){
            steps{
                sh 'mvn checkstyle:checkstyle'
            }
        }
        stage('sonarqube analysis'){
            environment{
                scannerHome = tool 'sonar7.0'
            }
            steps{
                withSonarQubeEnv('sonarserver'){
                    sh"""
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=vprofile \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=src/ \
                        -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                        -Dsonar.junit.reportsPath=target/surefire-reports/ \
                        -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml \
                        -Dsonar.host.url=http://192.168.56.20:9000 \
                        -Dsonar.ws.timeout=60
                    """
                }
            }
        }
        // stage('quality gate'){
        //     steps{
        //         timeout(time: 1, unit: 'HOURS'){
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }
        // stage('docker build'){
        //     steps{
        //         script{
        //         docker.build('vproapp', './app')
        //         }
        //         sh"""
        //            docker-compose up -d vproapp
        //         """
        //     }
        // }
        // stage('upload to s3'){
        //     steps{
        //       script{
        //         try {
        //             withAWS(credentials: s3Credentials, region: S3_BUCKET_REGION) {
        //                 echo 'uploading to s3'
                        
        //                 //define bucket name and artifact
        //                 def BUCKET_NAME = 'vproartifact'
        //                 def ARTIFACT_PATH = 'target/vprofile-v2.war'

        //                 sh"""
        //                  if [ ! -f "$ARTIFACT_PATH" ] || [ ! -s "$ARTIFACT_PATH" ]; then
        //                     echo "Artifact not found or empty"
        //                     exit 1
        //                  fi
        //                     aws --version
        //                     aws s3 ls s3://${BUCKET_NAME} --region ${S3_BUCKET_REGION}
        //                     ls -l target/
        //                     echo "uploading ${ARTIFACT_PATH} to s3://${BUCKET_NAME}"      
        //                     aws s3 cp ${ARTIFACT_PATH} s3://${BUCKET_NAME}/ --storage-class STANDARD --expected-size 83500000
        //                 """
        //             }
        //         }
        //         catch (Exception e) {
        //             echo "error occured during artifact upload: ${e.getMessage()}"
        //             currentBuild.result = 'FAILURE'
        //             error('stopping the pipline due to s3 upload failure.')
        //         }
        //       }
        //     }
        // }
        stage('deploy to app server'){
            steps{
                withAWS(credentials: s3Credentials, region: S3_BUCKET_REGION) {
                    echo 'deploying to app server'
                    sh"""
                        #validte the artifact
                        if aws s3 ls s3://${S3_BUCKET_NAME}/vprofile-v2.war --region ${S3_BUCKET_REGION}; then
                            echo "Artifact found"
                        else
                            echo "Artifact not found"
                            exit 1
                        fi
                        #download the artifact
                        aws s3 cp s3://${S3_BUCKET_NAME}/vprofile-v2.war ./ROOT.war

                        # Copy the WAR file to the Tomcat container
                        docker cp ./ROOT.war vproapp:/usr/local/tomcat/webapps/ROOT.war
                        docker-compose restart vproapp
                    """
                }
            }
        }
    }
    // post {
    //     always {
    //         echo 'slack notification'
    //         slackSend channel: '#devOps-cicd',
    //                   color: COLOR_MAP[currentBuild.result],
    //                   message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n more details at ${env.BUILD_URL}"
    //     }
    // }
}