FROM alpine:latest

RUN apk add --no-cache curl ca-certificates nginx unzip

RUN mkdir -p /run/nginx /var/www/localhost/html /app

COPY index.html /var/www/localhost/html/index.html
COPY config.yml /app/config.yml

# 关键修正：不再写死 5000，而是用 $PORT 占位
# 在启动时，我们会用脚本动态修改 Nginx 配置
RUN printf "server { \n\
    listen PORT_PLACEHOLDER; \n\
    server_name _; \n\
    root /var/www/localhost/html; \n\
    index index.html; \n\
    location / { \n\
        try_files \$uri \$uri/ =404; \n\
    } \n\
}" > /etc/nginx/http.d/default.conf

WORKDIR /app
RUN curl -L -f "https://gh-proxy.com/https://github.com/nezhahq/agent/releases/download/v1.15.0/nezha-agent_linux_amd64.zip" -o nezha.zip && \
    unzip nezha.zip && \
    chmod +x nezha-agent && \
    rm -f nezha.zip

# 默认端口设为 80，如果平台有要求会自动被替换
ENV PORT=80

# 启动命令：启动前先用 sed 把配置里的占位符换成真实的 $PORT
CMD ["sh", "-c", "sed -i \"s/PORT_PLACEHOLDER/${PORT}/g\" /etc/nginx/http.d/default.conf && \
    ./nezha-agent --config config.yml & nginx -g 'daemon off;'"]
