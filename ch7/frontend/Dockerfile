FROM node:8.17-alpine

WORKDIR /usr/src/app

ARG PORT=8080
ARG AUTH_API_ADDRESS=http://127.0.0.1:8000
ARG TODOS_API_ADDRESS=http://127.0.0.1:8082

COPY . .

RUN apk upgrade && apk add python2 python3
RUN npm install
RUN npm run build

ENTRYPOINT PORT=${PORT} AUTH_API_ADDRESS=${AUTH_API_ADDRESS} TODOS_API_ADDRESS=${TODOS_API_ADDRESS} npm start