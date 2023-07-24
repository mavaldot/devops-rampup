#Run the "Hello, World" Docker container. Make sure you understand the concepts of Container Registry, pulling and pushing an image to a Registry.

docker run --rm hello-world:latest

#Run a program that you want from a Docker container. It can be a web server, a database or even a programming language.

docker run --rm --name postgres-container -e POSTGRES_PASSWORD=postgres -dp 8080:8080 postgres:latest

#Run a container based on this image devopsdockeruh/simple-web-service:ubuntu. The image creates a container that outputs logs into a file. Go inside the container and use tail -f command to follow the logs. What's the secret message it outputs?

docker run --rm --name web-service-container -d devopsdockeruh/simple-web-service:ubuntu

# Secret message is: 'You can find the source code here: https://github.com/docker-hy'

#Given the following script, create an image from it.

# Created in the folder hello-image

# When you pass the server command to the devopsdockeruh/simple-web-service image, it will create a container with a web service running on port 8080. Access it from your localhost address. You will get a message like this: "{ message: "You connected to the following path: ..."

docker run --rm --name web-service-container -dp 8080:8080 devopsdockeruh/simple-web-service:ubuntu bash -c 'server'

# Make sure you understand the docker-compose command. How to install it and what we need it for. Here you can find information about it.
# Create a Dockerfile for every microservice in our microservice application. After that, run each microservice separately.
# Finally, create a docker-compose file to run all the microservices at once.