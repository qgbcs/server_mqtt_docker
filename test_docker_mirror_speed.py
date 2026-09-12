#!/usr/bin/env python3
import ssl
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
import urllib.error
import urllib.request

# 2026年常用 Docker 镜像源候选清单
MIRRORS = [
    "https://docker.1panel.live",
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me",
    "https://docker.m.daocloud.io",
    "https://docker.hlmirror.com",
    "https://docker.cloudlayer.icu",
    "https://dockerhub.jobcher.com",
    "https://docker.chenby.cn",
]


def test_mirror(url, timeout=3):
    test_url = f"{url.rstrip('/')}/v2/"
    start = time.time()

    # 跳过证书校验，避免因 SSL 证书链问题误判
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    req = urllib.request.Request(
        test_url, headers={"User-Agent": "Docker-Client/24.0.0"}
    )

    try:
        with urllib.request.urlopen(req, timeout=timeout, context=ctx) as resp:
            code = resp.getcode()
            elapsed = (time.time() - start) * 1000
            return url, code in (200, 401), code, elapsed
    except urllib.error.HTTPError as e:
        elapsed = (time.time() - start) * 1000
        # v2 接口未授权返回 401 属正常响应
        return url, e.code in (200, 401), e.code, elapsed
    except Exception as e:
        elapsed = (time.time() - start) * 1000
        err_msg = type(e).__name__
        return url, False, err_msg, elapsed


def main():
    print("🚀 开始并发测试 Docker 镜像源...\n")
    results = []

    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(test_mirror, m): m for m in MIRRORS}
        for future in as_completed(futures):
            results.append(future.result())

    # 按【可用状态优先 + 延迟从小到大】排序
    results.sort(key=lambda x: (not x[1], x[3]))

    print(f"{'状态':<6} | {'延迟 (ms)':<10} | {'响应/错误':<15} | {'镜像地址'}")
    print("-" * 65)
    for url, is_ok, status, elapsed in results:
        flag = "✅ 可用" if is_ok else "❌ 失败"
        print(f"{flag:<6} | {elapsed:<10.1f} | {str(status):<15} | {url}")


if __name__ == "__main__":
    main()