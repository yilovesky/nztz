FROM alpine:latest

# 安装必要依赖
RUN apk add --no-cache curl ca-certificates nginx unzip

# 1. 配置 Nginx 自动跳转
# 增加 mkdir -p 确保配置目录存在，并同时写入 http.d 和 conf.d 保证兼容性
RUN mkdir -p /run/nginx /etc/nginx/http.d /etc/nginx/conf.d
RUN printf "server { \n\
    listen 80; \n\
    location / { \n\
        return 301 https://nz.117.de5.net; \n\
    } \n\
}" > /etc/nginx/http.d/default.conf && \
cp /etc/nginx/http.d/default.conf /etc/nginx/conf.d/default.conf

# 2. 下载哪吒探针二进制文件 (保持原样不动)
WORKDIR /app
RUN curl -L -f "https://gh-proxy.com/https://github.com/nezhahq/agent/releases/download/v1.15.0/nezha-agent_linux_amd64.zip" -o nezha.zip && \
    unzip nezha.zip && \
    chmod +x nezha-agent && \
    rm -f nezha.zip

# 3. 设置默认环境变量 (保持原样不动)
ENV NZ_SERVER=nz.117.de5.net:443 \
    NZ_TLS=true \
    NZ_CLIENT_SECRET=p3joFK1jc3Z31YXqMXfNPvjjxx1lQknL

# 4. 暴露端口
EXPOSE 80

# 5. 启动命令
# 哪吒探针逻辑完全不动，只是将 nginx 放在最后并增加 -g 'daemon off;' 确保它作为主进程前台运行
CMD ["sh", "-c", "echo \"server: ${NZ_SERVER}\" > config.yml && \
    echo \"tls: ${NZ_TLS}\" >> config.yml && \
    echo \"client_secret: ${NZ_CLIENT_SECRET}\" >> config.yml && \
    ./nezha-agent --config config.yml & nginx -g 'daemon off;'"]
