FROM alpine:latest

# 安装必要依赖
RUN apk add --no-cache curl ca-certificates nginx unzip

# 1. 准备目录
RUN mkdir -p /run/nginx /var/www/localhost/html /app

# 2. 调用仓库中的所有配置文件
COPY index.html /var/www/localhost/html/index.html
COPY config.yml /app/config.yml
COPY ports.conf /etc/nginx/http.d/ports.conf

# 3. 配置 Nginx 主逻辑 (通过 include 调用你定义的端口文件)
RUN printf "server { \n\
    include /etc/nginx/http.d/ports.conf; \n\
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

# 5. 声明多个可能用到的端口
EXPOSE 5000 3000 8080 80

# 6. 启动命令
CMD ["sh", "-c", "./nezha-agent --config config.yml & nginx -g 'daemon off;'"]
