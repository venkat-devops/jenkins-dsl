//pipeline job
def slurper = new ConfigSlurper()
slurper.classLoader = this.class.classLoader
def config = slurper.parse(readFileFromWorkspace('microservices.dsl'))

//create job for every microservice
config.microservices.each { name, data ->
  createBuildJob(name,data)
  createITestJob(name,data)
  createDeployJob(name,data)
}

//create build pipeline view for every microservice
config.microservices.each {name, data ->
  buildPipelineView("${name}Service") {
    filterBuildQueue()
    filterExecutors()
    title("${name}Service CI Pipeline")
    displayedBuilds(5)
    selectedJob("${name}Service-Build")
    alwaysAllowManualTrigger()
    showPipelineParameters()
    refreshFrequency(60)
  }
}

nestedView('Build Pipeline') {
  description('Shows the service build pipelines')
  columns {
    status()
    weather()
  }
  views {
     config.microservices.each { name,data ->
        println "creating build pipeline subview for ${name}"
        buildPipelineView("${name}Service") {
           selectedJob("${name}Service-*")
           triggerOnlyLatestJob(true)
         alwaysAllowManualTrigger(true)
         showPipelineParameters(true)
           showPipelineParametersInHeaders(true)
         showPipelineDefinitionHeader(true)
         startsWithParameters(true)
        }
     }
  }
}

def createBuildJob(name,data) {
  freeStyleJob("${name}Service-Build") {
    scm {
      git {
        remote {
          url(data.url)
        }
        branch(data.branch)
      }
    }
    triggers {
      scm('H/15 * * * *')
    }

    steps {
      shell'''
        echo "Its a Job created by Seed Job"
      '''
    }

    publishers {
      downstream("${name}Service-ITest", 'SUCCESS')
    }
  }
}

def createITestJob(name,data) {
  freeStyleJob("${name}Service-ITest") {
    steps {
      shell'''
        echo "Integration Tests to be added...."
      '''
    }
    publishers {
      downstream("${name}Service-Deploy", "SUCCESS")
    }
  }
}

def createDeployJob(name,data) {
  freeStyleJob("${name}Service-Deploy") {
    steps {
      shell'''
        echo "Deploy job steps to be added"
      '''
    }
  }
}
