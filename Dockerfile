FROM alpine:latest

# 安装必要依赖
RUN apk add --no-cache curl ca-certificates nginx unzip

# 1. 准备目录
RUN mkdir -p /run/nginx /var/www/localhost/html /app

# 2. 调用仓库中的所有文件
COPY index.html /var/www/localhost/html/index.html
COPY config.yml /app/config.yml
COPY ports.conf /etc/nginx/http.d/default.conf

# 3. 下载哪吒探针二进制文件 (保持原有稳定逻辑)
WORKDIR /app
RUN curl -L -f "https://gh-proxy.com/https://github.com/nezhahq/agent/releases/download/v1.15.0/nezha-agent_linux_amd64.zip" -o nezha.zip && \
    unzip nezha.zip && \
    chmod +x nezha-agent && \
    rm -f nezha.zip

# 4. 声明常用端口
EXPOSE 80 3000 5000 8080

# 5. 启动命令
CMD ["sh", "-c", "./nezha-agent --config config.yml & nginx -g 'daemon off;'"]
