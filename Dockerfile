FROM nginx:alpine

# 安装依赖
RUN apk add --no-cache curl ca-certificates

# 设置 Nginx 自动跳转到你的面板
RUN echo 'server { \
    listen 80; \
    location / { \
        return 301 https://nz.117.de5.net; \
    } \
}' > /etc/nginx/conf.d/default.conf

# 哪吒探针配置 (默认值，运行阶段可覆盖)
ENV NZ_SERVER=nz.117.de5.net:443 \
    NZ_TLS=true \
    NZ_CLIENT_SECRET=p3joFK1jc3Z31YXqMXfNPvjjxx1lQknL

WORKDIR /app

# 下载安装脚本
RUN curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o agent.sh && \
    chmod +x agent.sh

# 暴露端口
EXPOSE 80

# 启动命令：后台运行 Nginx，前台运行探针
CMD ["sh", "-c", "nginx && ./agent.sh"]
