# Используем официальный образ nginx на Alpine (очень легкий)
FROM nginx:alpine

# Удаляем дефолтную конфигурацию nginx, которая слушает на порту 80
RUN rm /etc/nginx/conf.d/default.conf

# Устанавливаем openssl и создаем самоподписанные сертификаты для HTTPS
RUN apk add --no-cache openssl \
    && mkdir -p /etc/ssl/private \
    && openssl req -x509 -nodes -days 365 \
        -subj "/C=US/ST=Dev/L=Local/O=Example/OU=Local/CN=localhost" \
        -addext "subjectAltName = DNS:localhost,IP:127.0.0.1" \
        -newkey rsa:2048 \
        -keyout /etc/ssl/private/nwgate-selfsigned.key \
        -out /etc/ssl/certs/nwgate-selfsigned.crt

# Копируем нашу кастомную конфигурацию nginx (см. шаг 2)
COPY nginx.conf /etc/nginx/conf.d

# Копируем собранный статический сайт из текущей директории (хоста)
# в директорию, которую nginx будет раздавать
COPY . /usr/share/nginx/html

# Сообщаем Docker, что контейнер слушает на портах 80 и 443
EXPOSE 80 443

# Команда для запуска nginx при старте контейнера
CMD ["nginx", "-g", "daemon off;"]
