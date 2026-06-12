FROM ubuntu:22.04 AS build
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip
RUN git clone https://github.com/flutter/flutter.git /flutter -b stable --depth 1
ENV PATH="/flutter/bin:${PATH}"
RUN flutter doctor
WORKDIR /app
COPY pubspec.yaml .
RUN flutter pub get
COPY . .
RUN flutter create . --platforms web
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
