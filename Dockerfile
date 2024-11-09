# Pulling Ubuntu image
FROM ubuntu:latest

# Update packages and Install cron
RUN apt-get update && apt-get upgrade -y
RUN apt-get install curl unzip zip nano libssl-dev apache2 -y
RUN systemctl enable apache2

RUN curl -L -o /usr/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux64

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Setting up work directory
WORKDIR /src

# Copy the the app source into the container
COPY ./scripts /src/scripts

ENV AWSKEY=admin
ENV AWSSECRET=admin
ENV AWSREGION=us-east-1
ENV PTUSERNAME=admin
ENV PTPASSWORD=admin
ENV PTSERVER=peertube.tv
ENV DISCORD=admin
ENV AWSINSTANCE=i
ENV RUNEVERY=600

# Ensure the scripts are executable
RUN chmod +x /src/scripts/*.sh
RUN chmod +x /usr/bin/jq

EXPOSE 80

# Run cron, and tail the primary cron log
ENTRYPOINT printenv > /etc/environment && /src/scripts/start.sh && /src/scripts/peertube-check.sh