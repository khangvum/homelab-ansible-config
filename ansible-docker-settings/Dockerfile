FROM ubuntu:24.04

LABEL org.opencontainers.image.authors="manhkhang0305@gmail.com"
LABEL org.opencontainers.image.version="1.0.0"

RUN apt update

# Set NTP region
RUN DEBIAN_FRONTEND=noninteractive \
    TZ=America/Toronto \
    apt-get install tzdata -y

# Install packages
RUN apt install \
    ansible -y \
    openssh-server -y \
    supervisor -y \
    locales -y \
    python3 -y \
    sshpass -y

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
RUN export LC_ALL=C.UTF-8

# Install required ansible-galaxy collections
RUN ansible-galaxy collection install \
    ansible.windows \
    community.general \
    community.windows

# Create the working directory
RUN mkdir /opt/ansible
ENV LANG=en_US.UTF-8  
ENV LANGUAGE=en_US:en  
ENV LC_ALL=en_US.UTF-8

# Expose port 22
EXPOSE 22

# Create sshd privilege separation
RUN mkdir /run/sshd
RUN chmod 0755 /run/sshd
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /opt/ansible/windows-config

# Start the services when the server starts
CMD ["/usr/bin/supervisord"]