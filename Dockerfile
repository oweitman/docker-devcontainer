#node_dev_container:latest
FROM node:20-bullseye
RUN apt update && apt install openssh-server sudo -y
RUN groupadd dev && \
    useradd -rm -d /home/dev -s /bin/bash -g dev -G sudo,dev -u 1001 dev && \
    echo 'dev:dev' | chpasswd && \
    echo 'export NPM_CONFIG_PREFIX=/home/dev/.npm-global' >> /home/dev/.bashrc && \
    echo "export PATH=/home/dev/.npm-global/bin:${PATH}" >> /home/dev/.bashrc

RUN sed -i'' -e's/^#PermitRootLogin prohibit-password$/PermitRootLogin yes/' /etc/ssh/sshd_config \
        && sed -i'' -e's/^#PasswordAuthentication yes$/PasswordAuthentication yes/' /etc/ssh/sshd_config \
        && sed -i'' -e's/^#PermitEmptyPasswords no$/PermitEmptyPasswords yes/' /etc/ssh/sshd_config \
        && sed -i'' -e's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

RUN mkdir -p /home/dev/.ssh && \
    chmod 0700 /home/dev/.ssh && \
    chown dev:dev /home/dev/.ssh && \
    mkdir -p /home/dev/.npm-global && \
    chmod 0755 /home/dev/.npm-global && \
    chown dev:dev /home/dev/.npm-global && \
    mkdir -p /home/dev/projects && \
    chmod 0755 /home/dev/projects && \
    chown dev:dev /home/dev/projects && \
    mkdir -p /home/dev/.vscode-server && \
    chmod 0755 /home/dev/.vscode-server && \
    chown dev:dev /home/dev/.vscode-server && \
    mkdir -p /var/run/sshd 

COPY entrypoint.sh /run/entrypoint.sh
RUN chmod +x /run/entrypoint.sh
VOLUME ["/home/dev/sshfiles","/home/dev/projects","/home/dev/.npm-global","/home/dev/.vscode-server"]
EXPOSE 8081
EXPOSE 9229
EXPOSE 22
ENTRYPOINT ["/run/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
