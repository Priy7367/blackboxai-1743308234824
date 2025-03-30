# Stage 1 - Build
FROM debian:stable-slim AS build
RUN apt-get update && apt-get install -y curl git unzip
RUN curl -s https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.9-stable.tar.xz | tar xJ -C /usr/local/
ENV PATH="/usr/local/flutter/bin:${PATH}"
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web

# Stage 2 - Serve
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]