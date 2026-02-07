FROM alpine:latest

# 安装必要依赖
RUN apk add --no-cache curl ca-certificates nginx unzip

# 1. 准备目录
RUN mkdir -p /run/nginx /var/www/localhost/html /app

# 2. 调用仓库中的文件 (index.html 和 config.yml)
COPY index.html /var/www/localhost/html/index.html
COPY config.yml /app/config.yml

# 3. 编写 Nginx 模板 (注意：这里我们用了一个占位符 MY_PORT)
RUN printf "server { \n\
    listen MY_PORT; \n\
    server_name _; \n\
    root /var/www/localhost/html; \n\
    index index.html; \n\
    location / { \n\
        try_files \$uri \$uri/ =404; \n\
    } \n\
}" > /etc/nginx/http.d/default.conf

# 4. 下载哪吒探针二进制文件 (保持原有正常逻辑)
WORKDIR /app
RUN curl -L -f "https://gh-proxy.com/https://github.com/nezhahq/agent/releases/download/v1.15.0/nezha-agent_linux_amd64.zip" -o nezha.zip && \
    unzip nezha.zip && \
    chmod +x nezha-agent && \
    rm -f nezha.zip

# 5. 设置默认环境变量 (如果平台没给端口，默认用 80)
ENV PORT=80

# 6. 启动命令：在启动瞬间把配置里的 MY_PORT 替换为平台实际的 $PORT
CMD ["sh", "-c", "sed -i \"s/MY_PORT/${PORT}/g\" /etc/nginx/http.d/default.conf && \
    ./nezha-agent --config config.yml & nginx -g 'daemon off;'"]
