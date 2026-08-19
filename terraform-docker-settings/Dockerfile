FROM ubuntu:24.04

LABEL org.opencontainers.image.authors="manhkhang0305@gmail.com"
LABEL org.opencontainers.image.version="1.0.0"

RUN apt update

# Set NTP region
RUN DEBIAN_FRONTEND=noninteractive \
    TZ=America/Toronto \
    apt-get install tzdata -y

# Install packages
RUN apt install -y \
    openssh-server \
    locales \
    sshpass \
    wget \
    gnupg \
    lsb-release

# Install Terraform from HashiCorp's official repository
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt update && apt install -y terraform

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
RUN export LC_ALL=C.UTF-8

# Create the working directory
RUN mkdir /opt/terraform
ENV LANG=en_US.UTF-8  
ENV LANGUAGE=en_US:en  
ENV LC_ALL=en_US.UTF-8

WORKDIR /opt/terraform

# Keep the container running interactively
CMD ["bash"]