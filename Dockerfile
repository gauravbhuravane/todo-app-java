# build stage
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app
# cache dependencies when pom.xml unchanged
COPY pom.xml mvnw ./
COPY .mvn .mvn
RUN chmod +x mvnw
RUN ./mvnw -B -DskipTests dependency:go-offline

# copy source & build
COPY src ./src
RUN ./mvnw -B -DskipTests package

# run stage
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
# copy jar (assumes single jar in target/)
COPY --from=build /app/target/*.jar ./app.jar

# Use an unprivileged user (optional)
USER 1000

# Expose typical port (just documentation — Render passes actual PORT via env)
EXPOSE 8080

# Start
ENTRYPOINT ["java","-jar","/app/app.jar"]
