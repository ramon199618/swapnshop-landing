#!/bin/bash

# 🚀 Swap&Shop Webhook Server - Production Deployment Script
# 
# Dieses Script deployt den Webhook-Server in die Produktionsumgebung
# 
# Verwendung:
#   ./deploy.sh [environment]
# 
# Environment-Optionen:
#   - production: Live-Umgebung
#   - staging: Test-Umgebung
#   - development: Lokale Entwicklung

set -e  # Exit on any error

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging-Funktionen
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Konfiguration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="swapshop-webhook-server"
DOCKER_IMAGE_NAME="swapshop/webhook-server"

# Environment bestimmen
ENVIRONMENT=${1:-development}
case $ENVIRONMENT in
    production|prod)
        ENVIRONMENT="production"
        PORT=8080
        DOMAIN="swapshop.ch"
        ;;
    staging|stage)
        ENVIRONMENT="staging"
        PORT=8081
        DOMAIN="staging.swapshop.ch"
        ;;
    development|dev)
        ENVIRONMENT="development"
        PORT=8080
        DOMAIN="localhost"
        ;;
    *)
        log_error "Unbekanntes Environment: $ENVIRONMENT"
        log_info "Verfügbare Optionen: production, staging, development"
        exit 1
        ;;
esac

log_info "🚀 Deploye Webhook-Server für Environment: $ENVIRONMENT"
log_info "📍 Domain: $DOMAIN"
log_info "🔌 Port: $PORT"

# Prüfe ob Docker installiert ist
if ! command -v docker &> /dev/null; then
    log_error "Docker ist nicht installiert!"
    log_info "Installiere Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Prüfe ob Docker läuft
if ! docker info &> /dev/null; then
    log_error "Docker läuft nicht!"
    log_info "Starte Docker und versuche es erneut"
    exit 1
fi

# Environment-spezifische Konfiguration
case $ENVIRONMENT in
    production)
        # Produktions-Umgebungsvariablen
        export STRIPE_WEBHOOK_SECRET="${STRIPE_WEBHOOK_SECRET:-whsec_live_secret}"
        export PAYREXX_WEBHOOK_SECRET="${PAYREXX_WEBHOOK_SECRET:-payrexx_live_secret}"
        export STRIPE_PUBLISHABLE_KEY="${STRIPE_PUBLISHABLE_KEY:-pk_live_...}"
        export STRIPE_SECRET_KEY="${STRIPE_SECRET_KEY:-sk_live_...}"
        export PAYREXX_API_KEY="${PAYREXX_API_KEY:-payrexx_live_key}"
        ;;
    staging)
        # Staging-Umgebungsvariablen
        export STRIPE_WEBHOOK_SECRET="${STRIPE_WEBHOOK_SECRET:-whsec_test_secret}"
        export PAYREXX_WEBHOOK_SECRET="${PAYREXX_WEBHOOK_SECRET:-payrexx_test_secret}"
        export STRIPE_PUBLISHABLE_KEY="${STRIPE_PUBLISHABLE_KEY:-pk_test_...}"
        export STRIPE_SECRET_KEY="${STRIPE_SECRET_KEY:-sk_test_...}"
        export PAYREXX_API_KEY="${PAYREXX_API_KEY:-payrexx_test_key}"
        ;;
    development)
        # Entwicklungs-Umgebungsvariablen
        export STRIPE_WEBHOOK_SECRET="${STRIPE_WEBHOOK_SECRET:-whsec_test_secret}"
        export PAYREXX_WEBHOOK_SECRET="${PAYREXX_API_KEY:-payrexx_test_secret}"
        export STRIPE_PUBLISHABLE_KEY="${STRIPE_PUBLISHABLE_KEY:-pk_test_...}"
        export STRIPE_SECRET_KEY="${STRIPE_SECRET_KEY:-sk_test_...}"
        export PAYREXX_API_KEY="${PAYREXX_API_KEY:-payrexx_test_key}"
        ;;
esac

# Dockerfile erstellen
log_info "📝 Erstelle Dockerfile..."
cat > "$SCRIPT_DIR/Dockerfile" << EOF
FROM dart:stable AS build

WORKDIR /app
COPY . .

# Dependencies installieren
RUN dart pub get

# App kompilieren
RUN dart compile exe webhook_server.dart -o webhook_server

# Runtime Image
FROM debian:bullseye-slim

# Runtime Dependencies installieren
RUN apt-get update && apt-get install -y \\
    ca-certificates \\
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Kompilierte App kopieren
COPY --from=build /app/webhook_server /app/webhook_server

# Environment-Variablen setzen
ENV ENVIRONMENT=$ENVIRONMENT
ENV STRIPE_WEBHOOK_SECRET=\$STRIPE_WEBHOOK_SECRET
ENV PAYREXX_WEBHOOK_SECRET=\$PAYREXX_WEBHOOK_SECRET

# Port exponieren
EXPOSE $PORT

# Health Check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD curl -f http://localhost:$PORT/health || exit 1

# App starten
CMD ["/app/webhook_server"]
EOF

log_success "Dockerfile erstellt"

# Docker Compose File erstellen
log_info "📝 Erstelle docker-compose.yml..."
cat > "$SCRIPT_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
  webhook-server:
    build: .
    container_name: ${PROJECT_NAME}-${ENVIRONMENT}
    restart: unless-stopped
    ports:
      - "$PORT:$PORT"
    environment:
      - ENVIRONMENT=$ENVIRONMENT
      - STRIPE_WEBHOOK_SECRET=\${STRIPE_WEBHOOK_SECRET}
      - PAYREXX_WEBHOOK_SECRET=\${PAYREXX_WEBHOOK_SECRET}
      - STRIPE_PUBLISHABLE_KEY=\${STRIPE_PUBLISHABLE_KEY}
      - STRIPE_SECRET_KEY=\${STRIPE_SECRET_KEY}
      - PAYREXX_API_KEY=\${PAYREXX_API_KEY}
    volumes:
      - ./logs:/app/logs
    networks:
      - webhook-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:$PORT/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  webhook-network:
    driver: bridge

volumes:
  logs:
EOF

log_success "Docker Compose File erstellt"

# Logs-Verzeichnis erstellen
mkdir -p "$SCRIPT_DIR/logs"
log_success "Logs-Verzeichnis erstellt"

# Docker Image bauen
log_info "🔨 Baue Docker Image..."
docker build -t "$DOCKER_IMAGE_NAME:$ENVIRONMENT" .

if [ $? -eq 0 ]; then
    log_success "Docker Image erfolgreich gebaut"
else
    log_error "Fehler beim Bauen des Docker Images"
    exit 1
fi

# Bestehenden Container stoppen und entfernen
log_info "🛑 Stoppe bestehenden Container..."
docker-compose down --remove-orphans 2>/dev/null || true

# Neuen Container starten
log_info "🚀 Starte neuen Container..."
docker-compose up -d

# Warte auf Container-Start
log_info "⏳ Warte auf Container-Start..."
sleep 10

# Health Check
log_info "🏥 Führe Health Check durch..."
if curl -f "http://localhost:$PORT/health" > /dev/null 2>&1; then
    log_success "Health Check erfolgreich!"
else
    log_warning "Health Check fehlgeschlagen - Container läuft möglicherweise noch nicht"
fi

# Status anzeigen
log_info "📊 Container-Status:"
docker-compose ps

# Logs anzeigen
log_info "📝 Letzte Logs:"
docker-compose logs --tail=20

# Deployment-Info
log_success "🎉 Webhook-Server erfolgreich deployed!"
log_info "🌐 URL: http://$DOMAIN:$PORT"
log_info "🏥 Health Check: http://$DOMAIN:$PORT/health"
log_info "📊 Status: http://$DOMAIN:$PORT/status"
log_info "📡 Stripe Webhook: http://$DOMAIN:$PORT/webhook/stripe"
log_info "📡 Payrexx Webhook: http://$DOMAIN:$PORT/webhook/payrexx"

# Nächste Schritte
log_info "📋 Nächste Schritte:"
case $ENVIRONMENT in
    production)
        log_info "1. Konfiguriere Stripe Webhook URL: https://$DOMAIN/webhook/stripe"
        log_info "2. Konfiguriere Payrexx Webhook URL: https://$DOMAIN/webhook/payrexx"
        log_info "3. Aktiviere SSL/HTTPS für Domain: $DOMAIN"
        log_info "4. Konfiguriere Firewall-Regeln für Port $PORT"
        log_info "5. Setze Monitoring und Alerting auf"
        ;;
    staging)
        log_info "1. Teste Webhook-Endpunkte mit Test-Daten"
        log_info "2. Validiere Stripe/Payrexx Integration"
        log_info "3. Prüfe Logs auf Fehler"
        ;;
    development)
        log_info "1. Entwickle und teste neue Features"
        log_info "2. Debugge mit detaillierten Logs"
        log_info "3. Verwende lokale Test-Daten"
        ;;
esac

log_info "📚 Dokumentation: https://github.com/swapshop/webhook-server"
log_info "🆘 Support: dev@swapshop.ch"

# Cleanup
rm -f "$SCRIPT_DIR/Dockerfile"
rm -f "$SCRIPT_DIR/docker-compose.yml"

log_success "🧹 Temporäre Dateien aufgeräumt"
log_success "✨ Deployment abgeschlossen!" 