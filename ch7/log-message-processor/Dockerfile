FROM alpine:latest

WORKDIR /usr/app/src

COPY . .

RUN apk upgrade && apk add python3 py3-pip

ENV REDIS_HOST=redis-cont
ENV REDIS_PORT=6379
ENV REDIS_CHANNEL=log_channel

RUN pip3 install -r requirements.txt

ENTRYPOINT python3 main.py