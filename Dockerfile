FROM alpine:latest

# 安装必要依赖
RUN apk add --no-cache curl ca-certificates nginx unzip

# 1. 配置 Nginx 自动跳转
RUN mkdir -p /run/nginx
RUN echo 'server { \
    listen 80; \
    location / { \
        return 301 https://nz.117.de5.net; \
    } \
}' > /etc/nginx/http.d/default.conf

# 2. 下载哪吒探针二进制文件
WORKDIR /app

# 使用 -f 参数：如果下载链接失效或返回 404，curl 会直接报错退出
# 使用 gh-proxy 代理以确保 GitHub Actions 内部网络稳定
RUN curl -L -f "https://gh-proxy.com/https://github.com/nezhahq/agent/releases/download/v1.15.0/nezha-agent_linux_amd64.zip" -o nezha.zip && \
    unzip nezha.zip && \
    chmod +x nezha-agent && \
    rm -f nezha.zip

# 3. 设置环境变量 (由 Dockerfile 提供默认值)
ENV NZ_SERVER=nz.117.de5.net:443 \
    NZ_TLS=true \
    NZ_CLIENT_SECRET=p3joFK1jc3Z31YXqMXfNPvjjxx1lQknL

# 4. 暴露端口
EXPOSE 80

# 5. 启动命令
CMD ["sh", "-c", "nginx && ./nezha-agent -s ${NZ_SERVER} -p ${NZ_CLIENT_SECRET} --tls"]
