#!/bin/bash

# 1. Start a dummy web server on $PORT for Railway health checks
python3 -m http.server ${PORT:-10000} --directory /tmp &

# 2. Define custom paths for non-root environment
TS_SOCKET="/tmp/tailscaled.sock"
TS_STATE="/tmp/tailscaled.state"

# 3. Start Tailscale daemon in userspace mode WITH a SOCKS5 proxy
# This proxy allows you to route traffic (like VNC or web apps) through Tailscale
tailscaled \
  --tun=userspace-networking \
  --socket=$TS_SOCKET \
  --state=$TS_STATE \
  --socks5-server=localhost:1055 \
  --verbose=1 & 

sleep 5

# 4. Bring Tailscale up with SSH and Exit Node advertised
tailscale --socket=$TS_SOCKET up \
  --authkey="${TAILSCALE_AUTHKEY}" \
  --hostname="${TAILSCALE_HOSTNAME:-Railway-Server}" \
  --advertise-exit-node \
  --ssh \
  --accept-dns=true

# 5. Keep container alive and log status
while true; do
  echo "$(date): Tailscale status - $(tailscale --socket=$TS_SOCKET status --json | jq -r '.Self.Online')"
  sleep 60
done
