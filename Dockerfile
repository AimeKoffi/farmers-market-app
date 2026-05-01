# ─── Stage 1 : Build Flutter Web ───────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copier les dépendances en premier (meilleur cache Docker)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copier le code source
COPY . .

# Compiler pour le web en injectant l'URL de l'API via dart-define
# L'URL pointe vers le proxy Nginx local (même origine → pas de CORS)
RUN flutter build web --release \
    --dart-define=API_URL=http://localhost/api

# ─── Stage 2 : Servir avec Nginx ───────────────────────────────────────────
FROM nginx:alpine

# App Flutter compilée
COPY --from=builder /app/build/web /usr/share/nginx/html

# Config Nginx : serve Flutter SPA + proxy /api/ → container API
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
