# --- Stage 1: Build the Application ---
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# 依存関係のキャッシュ効率を上げるため、pom.xmlだけ先にコピーして依存解決
COPY pom.xml .
RUN mvn dependency:go-offline

# ソースコードをコピーしてビルド (テストはスキップしますが、必要なら -DskipTests を外してください)
COPY src ./src
RUN mvn package -DskipTests

# --- Stage 2: Runtime Environment ---
FROM eclipse-temurin:21-jre
WORKDIR /app

# OpenTelemetry Java Agent のバージョン指定
ARG OTEL_AGENT_VERSION=2.23.0
# ダウンロードURL
ARG OTEL_AGENT_URL=https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_AGENT_VERSION}/opentelemetry-javaagent.jar

# 1. OTEL Agent をダウンロード
ADD ${OTEL_AGENT_URL} /app/opentelemetry-javaagent.jar

# 2. ビルドステージから生成されたJarファイルをコピー
# pom.xml の設定に基づき、bootstrap_api_demo-0.0.1-SNAPSHOT.jar という名前を想定しています
COPY --from=build /app/target/bootstrap_api_demo-0.0.1-SNAPSHOT.jar /app/app.jar

# 3. 実行ユーザーの作成（セキュリティ推奨）
RUN useradd -m appuser && chown -R appuser /app
USER appuser

# 環境変数のデフォルト値（実行時に docker run -e で上書き可能）
ENV OTEL_SERVICE_NAME=bootstrap-api-demo
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_METRICS_EXPORTER=otlp
ENV OTEL_LOGS_EXPORTER=otlp
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317

# 4. エントリーポイントの設定
# 実行時に引数として config.yaml のパスを渡す必要があります
ENTRYPOINT ["java", "-javaagent:/app/opentelemetry-javaagent.jar", "-jar", "/app/app.jar"]
CMD ["/app/config.yaml"]