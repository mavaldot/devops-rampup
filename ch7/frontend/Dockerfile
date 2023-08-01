FROM node:8.17-alpine

WORKDIR /usr/src/app

ENV PORT=8080
ENV AUTH_API_ADDRESS=http://127.0.0.1:8000
ENV TODOS_API_ADDRESS=http://127.0.0.1:8082

COPY . .

RUN apk upgrade && apk add python2 python3
RUN npm install
RUN npm run build

ENTRYPOINT npm start
