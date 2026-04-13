

# Sample Dockerfile for demonstration only

FROM eclipse-temurin:21-jdk
WORKDIR /app
COPY target/spring-boot-web.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]
