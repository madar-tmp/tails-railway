FROM debian:bullseye-slim

# Set environment defaults
ENV TAILSCALE_HOSTNAME="Railway-Server"
ENV TAILSCALE_ADDITIONAL_ARGS=""

# Install required tools
RUN apt-get update && apt-get install -y --fix-missing \
    nano \
    git \
    tmux \
    neofetch \
    ca-certificates \
    curl \
    wget \
    python3 \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Create a working directory and set permissions
WORKDIR /app
COPY start.sh .
RUN chmod +x start.sh

# Start the script
CMD ["./start.sh"]
