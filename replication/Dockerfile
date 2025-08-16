# Use the MariaDB base image
FROM mariadb:10.6.20

# Install Chrony and gosu
RUN apt-get update && apt-get install -y \
    chrony \
    gosu \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create the MariaDB log directory
RUN mkdir -p /var/log/mariadb

# Define the entrypoint so Chrony starts along with MariaDB
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["mysqld"]