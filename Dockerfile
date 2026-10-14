# syntax=docker/dockerfile:1.7
FROM node:20-alpine@sha256:f598378b5240225e6beab68fa9f356db1fb8efe55173e6d4d8153113bb8f333c AS build-stage
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --no-audit --no-fund
COPY . .
ARG API_SERVER_NAME
ENV VUE_APP_API_SERVER_NAME=${API_SERVER_NAME}
RUN npm run build

# Production stage
FROM nginx:alpine@sha256:e7257f1ef28ba17cf7c248cb8ccf6f0c6e0228ab9c315c152f9c203cd34cf6d1 AS production-stage
COPY --from=build-stage --chown=nginx:nginx /app/dist /usr/share/nginx/html
COPY --chown=nginx:nginx nginx.conf /etc/nginx/nginx.conf
EXPOSE 8080
USER nginx
