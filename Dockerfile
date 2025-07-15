# Use an official OpenJDK runtime as base image
FROM openjdk:17-jdk-slim

ENV CONFIG-SERVER-URL=${CONFIG-SERVER-URL} \
    SERVER_PORT=${SERVER_PORT} \
    HOSTNAME=service-discovery

# Set the working directory
WORKDIR /app

# Copy the jar file into the image
COPY target/service-discovery-0.0.1-SNAPSHOT.jar app.jar

# Expose the application port
EXPOSE ${SERVER_PORT}

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
