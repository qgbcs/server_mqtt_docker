# 使用 2026 年可用的国内镜像源替代 ustc
#FROM docker.1panel.live/library/python:3.10-slim
FROM docker.m.daocloud.io/library/python:3.10-slim
# 备用方案：
# FROM docker.1ms.run/library/python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOME=/home/qgb

# 替换 apt 源和 pip 源为清华大学镜像，加速依赖下载
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources 2>/dev/null || true \
    && sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list 2>/dev/null || true \
    && apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates openssh-client \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip \
    && pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple paho-mqtt ecdsa prompt_toolkit Pygments

# 【致命错误修复】：Docker COPY 指令无法读取构建上下文 (.) 之外的绝对路径。
# 必须使用相对路径，在此已修正为相对路径。
COPY git.py /opt/git.py
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && mkdir -p /home/qgb/github

VOLUME ["/home/qgb/github"]
EXPOSE 1177

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["https://github.com/qgbcs/multi_mqtt"]