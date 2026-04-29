#!/bin/bash
#

# CRITICAL: Start a web server on $PORT for Railway/Render health checks
python3 -m http.server ${PORT:-10000} --directory /tmp &

# Define custom paths for non-root environment
TS_SOCKET="/tmp/tailscaled.sock"
TS_STATE="/tmp/tailscaled.state"

# Start Tailscale daemon in userspace mode with custom socket
tailscaled \
  --tun=userspace-networking \
  --socket=$TS_SOCKET \
  --state=$TS_STATE \
  --verbose=1 & 

sleep 5

# Bring Tailscale up using the specific socket
# Added --ssh and --advertise-exit-node as requested
tailscale --socket=$TS_SOCKET up \
  --authkey="${TAILSCALE_AUTHKEY}" \
  --hostname="${TAILSCALE_HOSTNAME:-railway-node}" \
  --advertise-exit-node \
  --ssh \
  --accept-dns=true

# Keep container alive
while true; do
  echo "$(date): Tailscale status - $(tailscale --socket=$TS_SOCKET status --json | jq -r '.Self.Online')"
  sleep 60
done
