FROM alpine:latest

# 安装必要依赖
RUN apk add --no-cache curl ca-certificates nginx

# 1. 配置 Nginx 自动跳转
RUN mkdir -p /run/nginx
RUN echo 'server { \
    listen 80; \
    location / { \
        return 301 https://nz.117.de5.net; \
    } \
}' > /etc/nginx/http.d/default.conf

# 2. 下载哪吒探针二进制文件 (跳过 install.sh 的服务注册环节)
WORKDIR /app
# 根据你的系统架构下载，这里以 amd64 为例
RUN curl -L "https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.tar.gz" -o nezha.tar.gz && \
    tar -zxvf nezha.tar.gz && \
    chmod +x nezha-agent

# 3. 设置环境变量 (保持你之前的配置)
ENV NZ_SERVER=nz.117.de5.net:443 \
    NZ_TLS=true \
    NZ_CLIENT_SECRET=p3joFK1jc3Z31YXqMXfNPvjjxx1lQknL

# 4. 暴露端口
EXPOSE 80

# 5. 直接运行：先启动 nginx，再直接运行哪吒代理
CMD ["sh", "-c", "nginx && ./nezha-agent -s ${NZ_SERVER} -p ${NZ_CLIENT_SECRET} --tls"]
