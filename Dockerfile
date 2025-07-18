# Build stage: Compile the application
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /build

# Copy pom.xml first for better caching
COPY pom.xml .
# Download dependencies (will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src/

# Build the application
RUN mvn package -DskipTests

# Runtime stage: Setup the actual runtime environment
FROM bellsoft/liberica-openjre-debian:21-cds

# Add metadata
LABEL maintainer="AmaliTech Training Academy" \
    description="TalentRadar Service Discovery" \
    version="1.0"

# Set environment variables
# These are expected to be provided at runtime with docker run -e
# ARG is used to suppress Docker linter warnings while allowing runtime ENV injection
ARG SERVER_PORT
ARG SPRING_APPLICATION_NAME
ARG SPRING_CLOUD_CONFIG_URI
ENV SERVER_PORT=${SERVER_PORT} \
    SPRING_APPLICATION_NAME=${SPRING_APPLICATION_NAME} \
    SPRING_CLOUD_CONFIG_URI=${SPRING_CLOUD_CONFIG_URI} \
    SPRING_PROFILES_ACTIVE=production \
    HOSTNAME=service-discovery

# Create a non-root user
RUN useradd -r -u 1001 -g root serviceuser

WORKDIR /application

# Copy the jar file from the build stage
COPY --from=builder --chown=serviceuser:root /build/target/*.jar ./application.jar

# Configure container
USER 1001
# Expose the service discovery port
EXPOSE 8086

# Use the standard JAR execution
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-Djava.security.egd=file:/dev/./urandom", "-jar", "application.jar"]
