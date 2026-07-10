# VORTEX PROJECT FINAL

**VORTEX PROJECT** adalah core Railway satu layanan untuk dashboard web, SSH WebSocket, SSH SNI/SSL, VLESS WebSocket, dan Trojan WebSocket.

Project ini dibuat untuk berjalan di Railway dengan satu web service utama, lalu beberapa port internal dipakai untuk jalur koneksi yang berbeda.

---

## Fitur Utama

- Dashboard web melalui domain Railway.
- SSH WebSocket melalui Cloudflare Tunnel / Zero Trust.
- SSH SNI / SSL melalui Railway TCP Proxy.
- VLESS WebSocket.
- Trojan WebSocket.
- Generator config WS dan SNI.
- SSH User Manager dari dashboard.
- Database user tersimpan di `/data/users.txt`.
- Banner connect Dropbear untuk SSH WS dan SSH SNI.
- Console menu di Railway.
- Support volume Railway agar user tidak hilang saat redeploy/restart.

---

## Port Final

Jangan tertukar antara `PORT`, `SSH_PORT`, `SSH_SSL_PORT`, dan `WS_INTERNAL_PORT`.

```txt
8080 = Dashboard web / Node.js
22   = Dropbear SSH internal
2443 = SSH SNI / SSL via stunnel
8880 = SSH WebSocket / ws-proxy / Cloudflare Tunnel
```

Variable penting:

```env
PORT=8080
SSH_PORT=22
SSH_SSL_PORT=2443
WS_INTERNAL_PORT=8880
```

Catatan penting:

- `PORT` jangan diisi `22`.
- `PORT=8080` untuk dashboard web Railway.
- `SSH_PORT=22` untuk Dropbear internal.
- `SSH_SSL_PORT=2443` untuk SSH SNI / SSL.
- `WS_INTERNAL_PORT=8880` untuk SSH WS lewat Cloudflare Tunnel.

---

## Deploy ke Railway

1. Upload project ini ke GitHub.
2. Railway → New Project.
3. Pilih **Deploy from GitHub**.
4. Railway otomatis build dari `Dockerfile`.
5. Buka **Networking**.
6. Generate domain Railway untuk dashboard.
7. Pastikan domain Railway mengarah ke port `8080`.

Dashboard dibuka melalui:

```txt
https://domain-kamu.up.railway.app/
```

---

## Railway Volume

Agar user SSH tidak hilang saat restart/redeploy, pasang Volume Railway:

```txt
Mount path: /data
```

File user akan tersimpan di:

```txt
/data/users.txt
```

---

## Railway Variables

Masuk ke:

```txt
Railway → Variables → Raw Editor
```

Gunakan format satu variable satu baris.

Template final:

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

Contoh sesuai pola final:

```env
ADMIN_PASS=Vortex
CF_TUNNEL_TOKEN=token_cloudflare_kamu

DATA_DIR=/data

PORT=8080
SSH_PORT=22
SSH_SSL_PORT=2443
WS_INTERNAL_PORT=8880

PUBLIC_HOST=ssh-ws.badut.biz.id
SSH_PUBLIC_HOST=ssh-ws.badut.biz.id
SSH_PUBLIC_PATH=/

XRAY_PUBLIC_HOST=vortex.vigilante.biz.id
SNI_PUBLIC_HOST=vorte-x.up.railway.app

SSH_SNI_HOST=nozomi.proxy.rlwy.net
SSH_SNI_PORT=25845
```

Jika token Cloudflare pernah dibagikan ke orang lain atau muncul di chat publik, buat token baru di Cloudflare Zero Trust lalu ganti `CF_TUNNEL_TOKEN`.

---

## Cloudflare Tunnel untuk SSH WS

Untuk mode SSH WS, gunakan Cloudflare Zero Trust / Tunnel.

Public Hostname:

```txt
ssh-ws.domainkamu.com
```

Service:

```txt
HTTP
```

URL service:

```txt
localhost:8880
```

Variable terkait:

```env
PUBLIC_HOST=ssh-ws.domainkamu.com
SSH_PUBLIC_HOST=ssh-ws.domainkamu.com
SSH_PUBLIC_PATH=/
WS_INTERNAL_PORT=8880
```

Format SSH WS:

```txt
ssh-ws.domainkamu.com:443@username:password
```

Payload:

```txt
GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]Upgrade: websocket[crlf]User-Agent: [ua][crlf][crlf]
```

---

## Railway TCP Proxy untuk SSH SNI

Untuk mode SSH SNI / SSL, jangan pakai TCP Proxy port `8080` dan jangan pakai port `22`.

Yang benar:

```txt
Networking → Add TCP Proxy → pilih internal port 2443
```

Railway akan memberi endpoint seperti:

```txt
nozomi.proxy.rlwy.net:25845
```

Masukkan ke variable:

```env
SSH_SNI_HOST=nozomi.proxy.rlwy.net
SSH_SNI_PORT=25845
SSH_SSL_PORT=2443
```

Format SSH SNI:

```txt
nozomi.proxy.rlwy.net:25845@username:password
```

Ringkasan:

```txt
TCP Proxy 2443 = SSH SNI / SSL
TCP Proxy 22   = SSH plain/direct, bukan SNI
TCP Proxy 8080 = dashboard web, bukan SSH
```

---

## Xray VLESS dan Trojan

Xray WS dan Xray SNI sama-sama memakai WebSocket.

Bedanya hanya domain yang dipakai.

```txt
VLESS WS   = XRAY_PUBLIC_HOST + type=ws + path /vless-vortex
VLESS SNI  = SNI_PUBLIC_HOST  + type=ws + path /vless-vortex

Trojan WS  = XRAY_PUBLIC_HOST + type=ws + path /trojan-vortex
Trojan SNI = SNI_PUBLIC_HOST  + type=ws + path /trojan-vortex
```

Contoh VLESS WS:

```txt
vless://UUID@vortex.domainkamu.com:443?encryption=none&security=tls&sni=vortex.domainkamu.com&type=ws&host=vortex.domainkamu.com&path=%2Fvless-vortex#VORTEX-VLESS-WS
```

Contoh VLESS SNI:

```txt
vless://UUID@domain-railway-kamu.up.railway.app:443?encryption=none&security=tls&sni=domain-railway-kamu.up.railway.app&type=ws&host=domain-railway-kamu.up.railway.app&path=%2Fvless-vortex#VORTEX-VLESS-SNI
```

---

## Dashboard

Dashboard berjalan di domain Railway.

Fitur dashboard:

- Status server.
- Uptime.
- Traffic.
- Generator VLESS WS.
- Generator VLESS SNI.
- Generator Trojan WS.
- Generator Trojan SNI.
- SSH User Manager.
- Tombol config **SSH WS**.
- Tombol config **SSH SNI**.
- Hapus user dengan konfirmasi admin jika fitur tersebut aktif di versi script.

Buka dashboard:

```txt
https://domain-kamu.up.railway.app/
```

---

## SSH User Manager

User SSH dibuat dari dashboard.

Output config yang tersedia:

```txt
SSH WS
SSH SNI
```

SSH WS memakai:

```env
SSH_PUBLIC_HOST
SSH_PUBLIC_PATH
```

SSH SNI memakai:

```env
SSH_SNI_HOST
SSH_SNI_PORT
```

---

## Banner SSH

Banner connect dipakai oleh Dropbear.

File utama:

```txt
/etc/dropbear_banner
```

Fallback:

```txt
/etc/issue.net
/etc/motd
```

Banner SSH WS dan SSH SNI dibuat sama karena dua mode tersebut tetap berakhir ke Dropbear.

Untuk melihat banner dari Railway Console:

```bash
showbanner
```

---

## Console Commands

Jika masuk Railway Console, perintah yang tersedia:

```bash
menu
addssh
listssh
delssh
vortex-clean-expired
showbanner
```

---

## Healthcheck Railway

Versi final menonaktifkan healthcheck path dari `railway.toml` supaya Railway tidak menandai deployment merah hanya karena `/health` dicek terlalu cepat saat startup.

Jika dashboard tidak terbuka, cek:

```txt
Deploy Logs
```

Cari error seperti:

```txt
EADDRINUSE
SSH_SSL_PORT is not defined
```

Solusi umum:

- Jika `EADDRINUSE`, pastikan `PORT=8080`, bukan `PORT=22`.
- Jika `SSH_SSL_PORT is not defined`, pastikan memakai versi hotfix terbaru dan variable `SSH_SSL_PORT=2443`.

---

## Troubleshooting Cepat

### Dashboard merah / gagal deploy

Pastikan:

```env
PORT=8080
SSH_PORT=22
SSH_SSL_PORT=2443
WS_INTERNAL_PORT=8880
```

Jangan isi:

```env
PORT=22
```

### SSH WS tidak connect

Cek Cloudflare Tunnel:

```txt
Public Hostname → HTTP → localhost:8880
```

Cek variable:

```env
SSH_PUBLIC_HOST=ssh-ws.domainkamu.com
SSH_PUBLIC_PATH=/
WS_INTERNAL_PORT=8880
```

### SSH SNI tidak connect

Cek TCP Proxy Railway.

Harus:

```txt
Internal port 2443
```

Bukan:

```txt
22
8080
8880
```

Cek variable:

```env
SSH_SSL_PORT=2443
SSH_SNI_HOST=host.proxy.rlwy.net
SSH_SNI_PORT=port_luar
```

### Xray SNI salah format

Xray SNI tetap WS.

Pastikan generator menghasilkan:

```txt
type=ws
host=SNI_PUBLIC_HOST
sni=SNI_PUBLIC_HOST
path=/vless-vortex atau /trojan-vortex
```

---

## Struktur Mode

```txt
Dashboard:
Railway domain → PORT 8080 → Node.js dashboard

SSH WS:
Cloudflare Tunnel public hostname → localhost:8880 → ws-proxy → Dropbear 22

SSH SNI:
Railway TCP Proxy external host:port → internal 2443 → stunnel → Dropbear 22

Xray:
Railway domain/custom domain → Node gateway → VLESS/Trojan WS path
```

---

## Catatan Penting

- Gunakan hanya untuk server milik sendiri dan penggunaan yang sah.
- Jangan membagikan `CF_TUNNEL_TOKEN`.
- Jika token sudah pernah tersebar, rotate token di Cloudflare Zero Trust.
- Simpan ZIP final yang stabil.
- Saat membuat project baru, ingat: SSH SNI memakai TCP Proxy internal port `2443`.

---

## Versi Stabil

Versi stabil terakhir:

```txt
VORTEX-PROJECT-FINAL-SSH-SSL-PORT-HOTFIX-V2
```

Perbaikan utama:

- Dashboard aman dari error `SSH_SSL_PORT is not defined`.
- SSH SNI memakai stunnel internal port `2443`.
- SSH WS dan SSH SNI banner disamakan.
- Xray SNI tetap format WebSocket.
- Tombol SSH WS / SSH SNI tersedia di SSH Manager.
- Tombol tabel user lebih compact untuk HP.


## Custom SSH Protocol Name

Versi ini mengganti tampilan awal client SSH:

```txt
SSH-2.0-dropbear_2022.83
```

menjadi:

```txt
SSH-2.0-VORTEX_CORE_2026
```

Opsional variable:

```env
SSH_PROTOCOL_NAME=VORTEX_CORE_2026
```

Nilainya wajib 16 karakter. Contoh aman:

```txt
VORTEX_CORE_2026
FREE_SERVER_2019
PREMIUM_SSH_2026
RAILWAY_SSH_2026
```


## Custom Dropbear Railway Compile

Script VPS custom Dropbear sudah diubah agar cocok untuk Railway/Docker.

- Tidak memakai `systemctl`.
- Tidak memakai `service`.
- Dropbear dicompile ulang di container.
- `SSH_PROTOCOL_NAME` boleh panjang, tidak wajib 16 karakter.

Variable:

```env
SSH_PROTOCOL_NAME=VORTEX_RAILWAY_PREMIUM
DROPBEAR_VERSION=2019.78
```

Contoh hasil client:

```txt
SSH-2.0-VORTEX_RAILWAY_PREMIUM
```

Kalau ingin gaya lain:

```env
SSH_PROTOCOL_NAME=SERVER_PREMIUM_ID_2019.78
```

Catatan: deploy/start pertama bisa lebih lama karena compile Dropbear.


## Hardcoded Dropbear Compile

Versi ini tidak membutuhkan variable `SSH_PROTOCOL_NAME` dan `DROPBEAR_VERSION`.

Nama protocol SSH sudah di-hardcode langsung di `entrypoint.sh`:

```txt
SSH-2.0-SERVER_PREMIUM_ID_2019.78
```

Kalau ingin mengganti nama, edit satu baris di `entrypoint.sh`:

```bash
CUSTOM_IDENT="SERVER_PREMIUM_ID_2019.78"
```

Karena Dropbear dicompile dari source, panjang nama bebas dan tidak wajib 16 karakter.


## Colored Railway Console Menu

Railway Console menggunakan warna ANSI, bukan HTML `<font color="">`.

Perbaikan ini membuat:

- `/etc/profile.d/vortexbanner.sh` berwarna.
- `/usr/local/sbin/menu` berwarna.
- Menu otomatis yang muncul saat buka console tidak hitam-putih lagi.

Catatan:
- Banner connect HTTP Custom/DarkTunnel tetap memakai HTML dari `/etc/dropbear_banner`.
- Banner Railway Console memakai ANSI color dari `vortexbanner.sh` dan `menu`.


## SSH-SNI Style Console Menu

Versi ini mengikuti gaya console Dropbear-main:

- Saat Railway Console dibuka, menu langsung tampil.
- Menu memakai warna ANSI terminal.
- Tampilan dibuat seperti `SSH-SNI MANAGER`.
- Banner connect `/etc/dropbear_banner` tidak diubah.

Yang diubah hanya:

```txt
/usr/local/sbin/menu
/etc/profile.d/vortexbanner.sh
```

Yang tidak diubah:

```txt
/etc/dropbear_banner
```


## Console Auto Menu Like Dropbear-main

Saya cek `Dropbear-main.zip`. Menu langsung tampil saat console dibuka karena `entrypoint.sh` menambahkan perintah `menu` ke:

```txt
/root/.bashrc
```

Versi ini mengikuti cara yang sama:

- `/usr/local/sbin/menu` memakai script Python ANSI color seperti Dropbear-main.
- `/root/.bashrc` otomatis menjalankan `menu` saat shell interaktif dibuka.
- `/etc/dropbear_banner` tidak disentuh.
- Banner connect HTTP Custom/DarkTunnel tetap aman.

Yang berubah hanya tampilan console/menu.


## VORTEX Own Colored Console Menu

Versi ini tidak memakai tampilan menu lama dari Dropbear-main.

Yang dipakai dari Dropbear-main hanya teknik auto-load console melalui:

```txt
/root/.bashrc
```

Tampilan menu sudah dikembalikan ke gaya VORTEX sendiri:

- `VORTEX PROJECT RAILWAY`
- warna ANSI terminal
- menu Tambah/List/Hapus/Clean/Exit
- langsung tampil saat Railway Console dibuka

Banner connect tidak diubah:

```txt
/etc/dropbear_banner
```


## Clean Mobile Console Menu

Menu console dibuat ulang agar rapi di HP dan Railway Console.

Perubahan:
- Menggunakan ASCII box `+---+` agar tidak pecah.
- Tetap berwarna dengan ANSI color.
- Tidak memakai emoji/box unicode yang bikin lebar terminal kacau.
- Auto tampil tetap lewat `/root/.bashrc`.

Banner connect tetap tidak diubah:

```txt
/etc/dropbear_banner
```


## Colored Console Submenus

Menu 1, 2, 3, dan 4 sekarang berwarna sampai isi input/output-nya.

File yang diwarnai:

```txt
scripts/addssh
scripts/listssh
scripts/delssh
scripts/vortex-clean-expired
```

Jadi bukan cuma menu utama yang berwarna, tetapi proses tambah user, list user, hapus user, dan clean expired juga ikut berwarna.

Banner connect tetap tidak diubah:

```txt
/etc/dropbear_banner
```


## Neat VORTEX Console Menu

Menu utama dibuat ulang agar mirip style VORTEX yang disukai, tetapi lebih rapi di HP.

Perubahan:
- Fixed width 42 kolom.
- Tidak memakai emoji dan unicode berat.
- Border tidak maju-mundur.
- Tetap berwarna semua.
- Submenu 1/2/3/4 tetap berwarna.
- Auto tampil lewat `/root/.bashrc`.

Banner connect tetap tidak diubah:

```txt
/etc/dropbear_banner
```


## Final Liked Console Menu

Menu console dibuat mengikuti model tampilan yang disukai:

```txt
+------------------------------------------------------+
| VORTEX PROJECT RAILWAY - SSH MANAGER                 |
+------------------------------------------------------+
| Core    : Dropbear / SSH WS / SSH SNI                 |
| Storage : /data/users.txt                            |
+------------------------------------------------------+
| 1. Tambah SSH User                                   |
| 2. List SSH User                                     |
| 3. Hapus SSH User                                    |
| 4. Clean Expired User                                |
| x. Exit Console Menu                                 |
+------------------------------------------------------+
```

Perbaikan:
- langsung tampil saat Railway Console dibuka melalui `/root/.bashrc`;
- tetap berwarna;
- border rapi di HP;
- submenu tetap memakai script berwarna;
- banner connect `/etc/dropbear_banner` tidak disentuh.


## Thick Border Console Menu

Menu console dibuat ulang dengan border tebal seperti request:

```txt
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ VORTEX PROJECT RAILWAY • SSH MANAGER                ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ ● Core     : Dropbear • SSH WS • SSH SNI             ┃
┃ ● Storage  : /data/users.txt                         ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ 1. Tambah SSH User                                   ┃
┃ 2. List SSH User                                     ┃
┃ 3. Hapus SSH User                                    ┃
┃ 4. Clean Expired User                                ┃
┃ x. Exit Console Menu                                 ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

Tetap auto tampil saat Railway Console dibuka lewat `/root/.bashrc`.

Banner connect tetap tidak diubah:

```txt
/etc/dropbear_banner
```


## Integrated Stable Console UI

Perbaikan final console:

- Tidak ada judul dobel.
- Menu utama dan submenu memakai style yang sama.
- Semua menu 1/2/3/4 berwarna.
- Border stabil pakai ASCII `||` agar tidak pecah di terminal HP.
- Auto tampil saat Railway Console dibuka lewat `/root/.bashrc`.
- Banner connect tidak diubah.

File baru:

```txt
scripts/vortex-ui.sh
scripts/menu
scripts/addssh
scripts/listssh
scripts/delssh
scripts/vortex-clean-expired
```


## Console UI Self-contained Fix

Memperbaiki error:

```txt
v_box_top: command not found
v_box_line_raw: command not found
```

Penyebabnya helper `vortex-ui.sh` tidak ikut terbaca di container.

Perbaikan:
- fungsi UI sekarang ditanam langsung di `menu`, `addssh`, `listssh`, `delssh`, dan `vortex-clean-expired`;
- tidak bergantung lagi ke `/usr/local/sbin/vortex-ui.sh`;
- tidak ada judul dobel;
- semua menu tetap berwarna;
- banner connect tetap tidak diubah.


## Thick Neat Console UI Fix

Perbaikan final:
- Border tebal memakai double-line box `╔ ═ ║ ╚`.
- Lebar menu dipendekkan agar rapi di HP.
- List user dan delete user dibuat table pendek agar tidak melebar.
- Tidak ada judul dobel.
- Semua menu tetap berwarna.
- Auto tampil saat Railway Console dibuka.
- Banner connect tidak diubah.

Jika terminal HP tetap memecah unicode, gunakan mode landscape atau font monospace normal.


## Heavy Line Console UI

Console UI sekarang memakai karakter box yang diminta:

```txt
┃ ━ ┏ ┓ ┗ ┛
```

Perbaikan:
- Menu utama memakai `┃ ━ ┏ ┓ ┗ ┛`.
- Submenu add/list/delete/clean memakai style tebal yang sama.
- Tidak ada judul dobel.
- Auto tampil saat Railway Console dibuka.
- Banner connect `/etc/dropbear_banner` tidak disentuh.
