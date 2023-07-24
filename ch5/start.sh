#!/bin/bash
 
sudo apt update && sudo apt upgrade
sudo apt install -y openjdk-8-jdk golang-go npm python3 python3-pip redis-server python2
 
directory=`pwd`
if [ ! -d logs ]; then
	mkdir logs
fi
 
if [ ! -d zipkin ]; then
	mkdir zipkin
fi
 
sudo service redis-server start
 
cd $directory/zipkin
curl -sSL https://zipkin.io/quickstart.sh | bash -s
java -jar zipkin.jar &
 
export JWT_SECRET=PRFT 
cd $directory/users-api
echo "*** Running ./mvnw clean install..."
./mvnw clean install > $directory/logs/users-api-install
echo "*** Starting users-api..."
SERVER_PORT=8083 java -jar target/users-api-0.0.1-SNAPSHOT.jar &
 
cd $directory/auth-api
export GO111MODULE=on
echo "*** Initializing auth-api..."
go mod init github.com/bortizf/microservice-app-example/tree/master/auth-api
go mod tidy
echo "*** Building auth-api..."
go build > $directory/logs/auth-api-build
echo "** Starting auth-api..."
AUTH_API_PORT=8000 USERS_API_ADDRESS=http://127.0.0.1:8083 ./auth-api &
 
cd $directory/todos-api
echo "*** Installing todo-api...."
rm package-lock.json
npm cache clean --force
npm install
TODO_API_PORT=8082 npm start &
 
cd $directory/log-message-processor
echo "*** Installing log message processor"
pip3 install -r requirements.txt
REDIS_HOST=127.0.0.1 REDIS_PORT=6379 REDIS_CHANNEL=log_channel python3 main.py &
 
cd $directory/frontend
echo "*** Installing frontend"
rm package-lock.json
npm cache clean --force
npm install
npm run build
PORT=8080 AUTH_API_ADDRESS=http://127.0.0.1:8000 TODOS_API_ADDRESS=http://127.0.0.1:8082 npm start &
 
 
echo "============= Done =================="