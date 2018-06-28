def builderImageName = "omisegoimages/ewallet-builder"
def builderImage

def runtimeImageName = "omisegoimages/ewallet-runtime"
def runtimeImage

def label = "img-ewallet-${UUID.randomUUID().toString()}"
def buildMsg
def gitCommit

def yamlSpec = """
spec:
  nodeSelector:
    cloud.google.com/gke-preemptible: "true"
  tolerations:
    - key: dedicated
      operator: Equal
      value: worker
      effect: NoSchedule
"""

podTemplate(
    label: label,
    yaml: yamlSpec,
    containers: [
        containerTemplate(
            name: 'jnlp',
            image: 'omisegoimages/jenkins-slave:3.19-alpine',
            args: '${computer.jnlpmac} ${computer.name}',
            resourceRequestCpu: '200m',
            resourceLimitCpu: '500m',
            resourceRequestMemory: '256Mi',
            resourceLimitMemory: '1024Mi',
            envVars: [
                containerEnvVar(key: 'DOCKER_HOST', value: 'tcp://localhost:2375')
            ]
        ),
        containerTemplate(
            name: 'dind',
            image: 'docker:18.05-dind',
            privileged: true,
            resourceRequestCpu: '700m',
            resourceLimitCpu: '1000m',
            resourceRequestMemory: '1024Mi',
            resourceLimitMemory: '2048Mi',
        ),
    ],
) {
    try {
        notifySlack('STARTED', null)

        node(label) {

            /* ------------------------------------------------------------------------
             * Stage: Checkout
             * ------------------------------------------------------------------------ */

            try {
                stage('Checkout') {
                    checkout scm
                    gitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                }
            } catch(e) {
                currentBuild.result = "FAILURE"
                buildMsg = "Build failed during checkout"
                throw e
            }

            /* ------------------------------------------------------------------------
             * Stage: Build
             * ------------------------------------------------------------------------ */

            try {
                stage('Build') {
                    builderImage = docker.build("${builderImageName}:${gitCommit}", "builder/")
                    runtimeImage = docker.build("${runtimeImageName}:${gitCommit}", "runtime/")
                }
            } catch(e) {
                currentBuild.result = "FAILURE"
                buildMsg = "Build failed during building image"
                throw e
            }

            /* ------------------------------------------------------------------------
             * Stage: Publish
             * Only run on master branch.
             * ------------------------------------------------------------------------ */

            if (env.BRANCH_NAME == 'master') {
                try {
                    stage('Publish') {
                        withDockerRegistry(credentialsId: 'd56e0a36-71d1-4c1b-a2c1-d8763f28d7f2') {
                            builderImage.push()
                            builderImage.push('latest')
                            runtimeImage.push()
                            runtimeImage.push('latest')
                        }
                    }
                } catch(e) {
                    currentBuild.result = "FAILURE"
                    buildMsg = "Build failed during publishing image"
                    throw e
                }
            }
        }
    } finally {
        notifySlack(currentBuild.result, buildMsg)
    }
}

def notifySlack(String buildStatus = 'STARTED', String buildMsg) {
    def statusColor
    def statusName
    def statusMsg

    buildStatus = buildStatus ?: 'SUCCESSFUL'

    switch (buildStatus) {
        case 'STARTED':
            statusColor = "#3377aa"
            statusName = 'Started:'
            break
        case 'SUCCESSFUL':
            statusColor = '#77aa33'
            statusName = 'Success:'
            break
        case 'WARN':
            statusColor = '#eeaa22'
            statusName = 'Soft failure:'
            break
        default:
            statusColor = '#dd4455'
            statusName = 'Failure:'
            break
    }

    statusMsg = "${statusName} <${env.RUN_DISPLAY_URL}|${env.JOB_NAME} #${env.BUILD_NUMBER}>\n"
    if (buildMsg != null) {
        statusMsg = "${statusMsg}\n${buildMsg}"
    }

    slackSend(
        channel: "#sandbox",
        color: statusColor,
        message: statusMsg
    )
}
