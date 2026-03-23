FROM python:3.12-slim

WORKDIR /app

# Нужны сертификаты для TLS (wss://).
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Ядро прокси использует только cryptography (остальные зависимости не нужны для headless режима).
# Увеличиваем таймаут и ретраи, чтобы сборка была устойчивее к сетевым флапам.
RUN pip install --no-cache-dir --prefer-binary --timeout 120 --retries 10 "cryptography==46.0.5"

# Копируем только модуль прокси, чтобы образ был компактным.
COPY proxy ./proxy

RUN mkdir -p /data

EXPOSE 1080

# По умолчанию слушаем на всех интерфейсах контейнера.
CMD ["python","-u","-m","proxy.tg_ws_proxy","--host","0.0.0.0","--port","1080","--log-file","/data/proxy.log"]

