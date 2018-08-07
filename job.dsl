def slurper = new ConfigSlurper()
slurper.classLoader = this.class.classLoader
def config = slurper.parse(readFileFromWorkspace('microservices.dsl'))

// create job for every microservice
config.microservices.each { name, data ->
  createBuildJob(name,data)
}

def createBuildJob(name,data) {
  freeStyleJob("${name}Service)") {
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
  }
}
