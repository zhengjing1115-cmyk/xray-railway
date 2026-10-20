# xray-railway

Personal Xray (VLESS + WebSocket) node for Railway. TLS is terminated by
Railway's edge on the generated `*.up.railway.app` domain (port 443);
Xray itself serves plain WebSocket on `$PORT` behind it.

## Environment variables (set in Railway, never commit real values)

- `UUID` — VLESS client id
- `WSPATH` — WebSocket path, e.g. `/01b60a80e559`
- `SUBPATH` — secret path that serves a base64 subscription body
  (via VLESS fallback to a local static server), e.g. `/d478d710a5137244b9`

After the public domain is generated, redeploy once so the entrypoint can
build the subscription link from `RAILWAY_PUBLIC_DOMAIN`.
