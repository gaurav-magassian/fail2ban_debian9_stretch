FROM debian:stretch

# Set environment variables for non-interactive apt commands
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt to use archive mirrors since Stretch is EOL
RUN rm -f /etc/apt/sources.list.d/*.list && \
    echo "deb [trusted=yes] http://archive.debian.org/debian/ stretch main contrib non-free" > /etc/apt/sources.list && \
    echo "deb [trusted=yes] http://archive.debian.org/debian-security/ stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/10no-check-valid-until && \
    echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "30";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::AllowInsecureRepositories "true";' > /etc/apt/apt.conf.d/99insecure && \
    echo 'APT::Get::AllowUnauthenticated "true";' >> /etc/apt/apt.conf.d/99insecure

RUN apt-get update || true

RUN apt-get -y dist-upgrade || true

RUN apt-get clean

# Install some packages that are needed for fail2ban
RUN apt-get -y install \
    build-essential \
    libpq-dev \
    libsqlite3-dev \
    libxml2-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    zlib1g-dev \
    git \
    supervisor \
    openssh-server \
    vim \
    rsyslog


# SSH setup
RUN mkdir -p /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Enable syslog for auth logs
RUN sed -i '/auth,authpriv\.\*/s/^#//' /etc/rsyslog.conf

# Update package lists and install required packages
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y nginx fail2ban procps vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy fail2ban configuration files
COPY jail.local /etc/fail2ban/jail.local
COPY rails-auth.conf /etc/fail2ban/filter.d/rails-auth.conf
COPY rails-bruteforce.conf /etc/fail2ban/filter.d/rails-bruteforce.conf
COPY common-attacks.conf /etc/fail2ban/filter.d/common-attacks.conf

# Create necessary directories and set permissions
RUN mkdir -p /var/log/nginx && \
    touch /var/log/nginx/access.log /var/log/nginx/error.log && \
    chmod 644 /var/log/nginx/access.log /var/log/nginx/error.log

# Supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start supervisord
CMD ["/usr/bin/supervisord", "-n"]
