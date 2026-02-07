# 使用轻量级的 Nginx 镜像作为基础
FROM nginx:alpine

# 安装 curl 用于下载探针
RUN apk add --no-cache curl ca-certificates

# 1. 配置 Nginx 自动跳转
# 创建一个简单的重定向配置
RUN echo 'server { \
    listen 80; \
    location / { \
        return 301 https://nz.117.de5.net; \
    } \
}' > /etc/nginx/conf.d/default.conf

# 2. 准备哪吒探针脚本
WORKDIR /app
ENV NZ_SERVER=nz.117.de5.net:443 \
    NZ_TLS=true \
    NZ_CLIENT_SECRET=p3joFK1jc3Z31YXqMXfNPvjjxx1lQknL

RUN curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o agent.sh && \
    chmod +x agent.sh

# 3. 启动脚本：同时启动 Nginx 和 哪吒探针
# 注意：使用 sh -c 运行多个命令，nginx 以后台模式运行，agent.sh 在前台运行
CMD nginx && sh ./agent.sh
