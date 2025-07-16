# Stage 1: Build the app using Maven and Eclipse Temurin JDK 24
FROM eclipse-temurin:24-jdk as build

# Set work directory inside the container
WORKDIR /app

# Copy Maven wrapper and pom.xml first (so dependencies can be cached)
COPY mvnw pom.xml ./
COPY .mvn .mvn

# Download dependencies (will cache if no changes)
RUN ./mvnw dependency:go-offline

# Copy rest of the source code
COPY src ./src

# Package application (skip tests for faster build, optional)
RUN ./mvnw clean package -DskipTests

# Stage 2: Run the app using a smaller JRE 24 image
FROM eclipse-temurin:24-jre

WORKDIR /app

# Copy the jar file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port 8080 (default Spring Boot port)
EXPOSE 8080

# Start Spring Boot app
ENTRYPOINT ["java", "-jar", "app.jar"]
