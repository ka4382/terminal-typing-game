FROM ubuntu:22.04

# Set non-interactive to avoid prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y bash coreutils bc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create app directory and data directory
WORKDIR /app

# Create volume mount point for persistent data
VOLUME /root/.typing_game

# Copy the game script
COPY typing_game.sh /app/

# Make script executable
RUN chmod +x /app/typing_game.sh

# Set the entrypoint
ENTRYPOINT ["/app/typing_game.sh"]
