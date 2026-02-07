FROM alpine:latest

# 安装必要依赖
RUN apk add --no-cache curl ca-certificates nginx unzip

# 1. 准备目录
RUN mkdir -p /run/nginx /var/www/localhost/html /app

# 2. 调用仓库中的网站文件
COPY index.html /var/www/localhost/html/index.html

# 3. 调用仓库中的哪吒配置文件
COPY config.yml /app/config.yml

# 4. 配置 Nginx 指向 index.html
RUN echo 'server { \
    listen 80; \
    root /var/www/localhost/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ =404; \
    } \
}' > /etc/nginx/http.d/default.conf

# 5. 下载哪吒探针二进制文件 (保持原有下载逻辑)
WORKDIR /app
RUN curl -L -f "https://gh-proxy.com/https://github.com/nezhahq/agent/releases/download/v1.15.0/nezha-agent_linux_amd64.zip" -o nezha.zip && \
    unzip nezha.zip && \
    chmod +x nezha-agent && \
    rm -f nezha.zip

# 6. 暴露端口
EXPOSE 80

# 7. 启动命令
# 直接使用仓库里的 config.yml 启动探针，同时运行 nginx
CMD ["sh", "-c", "./nezha-agent --config config.yml & nginx -g 'daemon off;'"]
