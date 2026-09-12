#FROM python:3.11-slim
FROM docker.mirrors.ustc.edu.cn/library/python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOME=/home/qgb

RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates openssh-client \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir paho-mqtt ecdsa prompt_toolkit Pygments

COPY /home/qgb/.local/bin/git.py /opt/git.py
COPY server_mqtt_docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && mkdir -p /home/qgb/github

VOLUME ["/home/qgb/github"]
EXPOSE 1177

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["https://xxx.com/qgbcs/multi_mqtt"]
