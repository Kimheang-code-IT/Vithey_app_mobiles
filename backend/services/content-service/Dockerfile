# syntax=docker/dockerfile:1

FROM maven:3.9.11-eclipse-temurin-21-alpine AS build
WORKDIR /workspace

COPY pom.xml .
COPY shared/vithey-test-support/pom.xml shared/vithey-test-support/pom.xml
COPY shared/vithey-test-support/src shared/vithey-test-support/src
COPY infrastructure/eureka-server/pom.xml infrastructure/eureka-server/pom.xml
COPY infrastructure/config-server/pom.xml infrastructure/config-server/pom.xml
COPY services/api-gateway/pom.xml services/api-gateway/pom.xml
COPY services/auth-service/pom.xml services/auth-service/pom.xml
COPY services/user-profile-service/pom.xml services/user-profile-service/pom.xml
COPY services/file-service/pom.xml services/file-service/pom.xml
COPY services/content-service/pom.xml services/content-service/pom.xml
COPY services/career-service/pom.xml services/career-service/pom.xml
COPY services/finance-service/pom.xml services/finance-service/pom.xml
COPY services/chat-service/pom.xml services/chat-service/pom.xml
COPY services/notification-service/pom.xml services/notification-service/pom.xml
COPY services/map-service/pom.xml services/map-service/pom.xml
COPY services/content-service/src services/content-service/src

RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -q -pl services/content-service -am -Dmaven.test.skip=true package && \
    cp services/content-service/target/*.jar app.jar

FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

RUN apk add --no-cache wget grep && \
    addgroup -S vithey && adduser -S vithey -G vithey

LABEL org.opencontainers.image.title="vithey-content-service" \
      org.opencontainers.image.vendor="Vithey App"

ARG SERVICE_PORT=8084
ENV SERVER_PORT=${SERVICE_PORT}

COPY --from=build /workspace/app.jar app.jar

USER vithey
EXPOSE ${SERVICE_PORT}

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD wget -qO- "http://localhost:${SERVER_PORT}/actuator/health" | grep -q '"status":"UP"' || exit 1

# Heap is env-driven: JAVA_TOOL_OPTIONS (compose/backend .env) overrides this default.
ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
