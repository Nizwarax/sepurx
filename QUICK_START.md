# QUICK START - VORTEX PROJECT FINAL

## 1. Deploy

Upload ke GitHub, lalu deploy dari Railway.

## 2. Volume

Tambahkan Railway Volume:

```txt
/data
```

## 3. Variables

Paste ke Railway Variables → Raw Editor:

```env
ADMIN_PASS=Vortex
CF_TUNNEL_TOKEN=token_cloudflare_kamu

DATA_DIR=/data

PORT=8080
SSH_PORT=22
SSH_SSL_PORT=2443
WS_INTERNAL_PORT=8880

PUBLIC_HOST=ssh-ws.domainkamu.com
SSH_PUBLIC_HOST=ssh-ws.domainkamu.com
SSH_PUBLIC_PATH=/

XRAY_PUBLIC_HOST=vortex.domainkamu.com
SNI_PUBLIC_HOST=domain-railway-kamu.up.railway.app

SSH_SNI_HOST=host.proxy.rlwy.net
SSH_SNI_PORT=port_tcp_proxy_2443
```

## 4. SSH WS

Cloudflare Zero Trust:

```txt
Public Hostname: ssh-ws.domainkamu.com
Service: HTTP
URL: localhost:8880
```

## 5. SSH SNI

Railway Networking:

```txt
Add TCP Proxy → internal port 2443
```

Masukkan hasilnya ke:

```env
SSH_SNI_HOST=host.proxy.rlwy.net
SSH_SNI_PORT=portnya
```

## 6. Jangan Salah Port

```txt
8080 = dashboard
22   = Dropbear
2443 = SSH SNI SSL
8880 = SSH WS
```

## Custom SSH Protocol Name

```env
SSH_PROTOCOL_NAME=VORTEX_CORE_2026
```

Nilai harus 16 karakter.

## Custom Dropbear Railway Compile

```env
SSH_PROTOCOL_NAME=VORTEX_RAILWAY_PREMIUM
DROPBEAR_VERSION=2019.78
```

Tidak wajib 16 karakter.

## Hardcoded Dropbear Compile

Nama SSH protocol sudah di-hardcode:

```txt
SSH-2.0-SERVER_PREMIUM_ID_2019.78
```

Tidak perlu variable `SSH_PROTOCOL_NAME`.
