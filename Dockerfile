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
RUN curl -L -f "https://gh-proxy.com/https://github.com/nezhahq/agent/releases/download/v1.15.0/nezha-agent_linux_amd64.zip" -o nezha.zip && \
    unzip nezha.zip && \
    chmod +x nezha-agent && \
    rm -f nezha.zip

# 3. 设置默认环境变量
ENV NZ_SERVER=nz.117.de5.net:443 \
    NZ_TLS=true \
    NZ_CLIENT_SECRET=p3joFK1jc3Z31YXqMXfNPvjjxx1lQknL

# 4. 暴露跳转服务的 80 端口
EXPOSE 80

# 5. 启动命令 (修正版：直接使用命令行参数启动)
# 根据 v1.15.0 帮助文档，直接传递参数是最稳妥的启动方式
CMD ["sh", "-c", "nginx && ./nezha-agent --server ${NZ_SERVER} --password ${NZ_CLIENT_SECRET} --tls"]
