# Use an official deb runtime as a base image
FROM debian:stable-slim

# Set environment variables (You can override these when running the container)
ENV NAME=ExampleScanner
ENV MODEL=MFC-L2700DW
ENV IPADDRESS=0.0.0.0
# Set the DEBIAN_FRONTEND environment variable to suppress debconf warnings
ENV DEBIAN_FRONTEND=noninteractive

# Your existing RUN command
RUN apt-get update -q > /dev/null && \
    apt-get install -qy --no-install-recommends apt-utils > /dev/null && \
    apt-get install -qy procps imagemagick wget curl libsane > /dev/null && \
    rm -rf /var/lib/apt/lists/*

# Copy the installation script into the image
COPY install_and_configure.sh /usr/local/bin/
COPY brscans.sh /usr/local/sbin/

# Set the script as executable
RUN chmod +x /usr/local/bin/install_and_configure.sh
RUN chmod +x /usr/local/sbin/brscans.sh

# Run the installation and configuration script
RUN /usr/local/bin/install_and_configure.sh -q

# Expose necessary ports for the Scan Key Tool
EXPOSE 54925/udp
EXPOSE 54921/tcp

# Set up a volume for scan storage
VOLUME ["/scans", "/var/brscans", "/var/log"]

# Set the service to run when the container starts
CMD ["/usr/local/sbin/brscans.sh", "-q", "-d"]
