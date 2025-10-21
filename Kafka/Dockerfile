FROM maven:3.9.9 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=builder /app/target/producer-jar-with-dependencies.jar ./producer.jar
COPY --from=builder /app/target/consumer-jar-with-dependencies.jar ./consumer.jar