# Stage 1: Build with JDK
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app

# Copy Maven files first (better caching)
COPY pom.xml .
# Download dependencies (cached unless pom.xml changes)
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime with JRE only (SMALL!)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy only the built jar from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Non-root user for security
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

EXPOSE 8085
ENTRYPOINT ["java", "-jar", "app.jar"]
