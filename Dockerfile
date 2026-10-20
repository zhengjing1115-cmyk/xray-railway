FROM alpine:3.20
RUN apk add --no-cache curl unzip ca-certificates
RUN curl -fsSL -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip" \
 && unzip -o /tmp/xray.zip -d /tmp/xray \
 && install -m 755 /tmp/xray/xray /usr/local/bin/xray \
 && rm -rf /tmp/xray /tmp/xray.zip
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
