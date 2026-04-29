#!/bin/bash

# 1. Start a web server on $PORT for Railway health checks
python3 -m http.server ${PORT:-10000} --directory /tmp &

# 2. Define a custom state DIRECTORY instead of just a state file
TS_DIR="/tmp/tailscale"
mkdir -p $TS_DIR
TS_SOCKET="$TS_DIR/tailscaled.sock"

# 3. Clean any corrupted/old state files before starting
rm -f $TS_DIR/tailscaled.state

# 4. Start Tailscale daemon using --statedir
tailscaled \
  --tun=userspace-networking \
  --statedir=$TS_DIR \
  --socket=$TS_SOCKET \
  --socks5-server=localhost:1055 \
  --verbose=1 & 

sleep 5

# 5. Bring Tailscale up 
tailscale --socket=$TS_SOCKET up \
  --authkey="${TAILSCALE_AUTHKEY}" \
  --hostname="${TAILSCALE_HOSTNAME:-Railway-Server}" \
  --advertise-exit-node \
  --ssh \
  --accept-dns=true \
  --force-reauth

# 6. Keep container alive
while true; do
  echo "$(date): Tailscale status - $(tailscale --socket=$TS_SOCKET status --json | jq -r '.Self.Online')"
  sleep 60
done
