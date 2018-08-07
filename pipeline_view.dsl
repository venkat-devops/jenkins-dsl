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
  buildPipelineView(name) {
    selectedJob("${name}Service")
  }
}


def createBuildJob(name,data) {
  freeStyleJob("${name}Service") {
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
