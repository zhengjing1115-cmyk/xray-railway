#!/bin/sh
set -e
UUID="${UUID:-00000000-0000-4000-8000-000000000000}"
WSPATH="${WSPATH:-/ws}"
SUBPATH="${SUBPATH:-/sub}"
PORT="${PORT:-8080}"
DOMAIN="${RAILWAY_PUBLIC_DOMAIN:-}"

mkdir -p /www /usr/local/etc
# tiny static server that serves the subscription file via xray fallback
httpd -p 127.0.0.1:18081 -h /www || true

if [ -n "$DOMAIN" ]; then
  ENC=$(printf '%s' "$WSPATH" | sed 's|/|%2F|g')
  LINK="vless://${UUID}@${DOMAIN}:443?encryption=none&security=tls&sni=${DOMAIN}&type=ws&host=${DOMAIN}&path=${ENC}#Railway-Xray"
  printf '%s' "$LINK" | base64 | tr -d '\n' > "/www${SUBPATH}"
  echo "SUB URL: https://${DOMAIN}${SUBPATH}"
fi
echo "UUID=${UUID}"
echo "WSPATH=${WSPATH}"
echo "PORT=${PORT}"

cat > /usr/local/etc/xray.json <<EOF
{
  "log": {"loglevel": "warning"},
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "${UUID}"}],
        "decryption": "none",
        "fallbacks": [
          {"path": "${SUBPATH}", "dest": "127.0.0.1:18081"},
          {"dest": "127.0.0.1:18081"}
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {"path": "${WSPATH}"}
      }
    }
  ],
  "outbounds": [{"protocol": "freedom", "tag": "direct"}]
}
EOF
exec xray run -c /usr/local/etc/xray.json
