# Lightweight Alpine Java 17 Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Ensure uploads directory exists
RUN mkdir -p /app/uploads

# Copy the pre-built Spring Boot jar
COPY target/campus-cart-backend-1.0.0.jar app.jar

EXPOSE 8080

# Memory limits optimized for AWS EC2 t2.micro / t3.micro (1GB RAM)
ENTRYPOINT ["java", "-Xmx350m", "-Xms200m", "-jar", "app.jar"]
