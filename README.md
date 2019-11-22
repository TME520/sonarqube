# sonarqube
Build a Docker image running the latest version of SonarQube (Ubuntu + MySQL)
## Build it

`docker build -t sonarqube:flanflan -f ./Dockerfile .`

## Run it

`docker run -p 9000:9000 sonarqube:flanflan`

## Access it

Simply open _http://localhost:9000_
