FROM golang:latest

WORKDIR /usr/src/app

COPY *.go ./

RUN export GO111MODULE=on
RUN go mod init github.com/bortizf/microservice-app-example/tree/master/auth-api
RUN go mod tidy
RUN go build
RUN JWT_SECRET=PRFT AUTH_API_PORT=8000 USERS_API_ADDRESS=http://127.0.0.1:8083

EXPOSE 8000

ENTRYPOINT AUTH_API_PORT=8000 ./auth-api
