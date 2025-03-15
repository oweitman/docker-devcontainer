# 1. Basis: Debian Bookworm
FROM debian:bookworm

# Keine interaktiven Abfragen während apt-get install
ENV DEBIAN_FRONTEND=noninteractive

# 2. System-Updates & benötigte Pakete
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      openssh-server && \
    rm -rf /var/lib/apt/lists/*

# 3. Node.js 22 installieren
#    (Setze voraus, dass deb.nodesource.com/setup_22.x existiert / funktionieren kann.)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 4. Benutzer und Pfade einrichten
#    - SSH Server-Pfad
#    - Benutzer "dev" anlegen
#    - Projektverzeichnis anlegen
RUN mkdir -p /var/run/sshd
RUN useradd -m -s /bin/bash dev && echo 'dev:dev' | chpasswd

# 5. SSH-Konfiguration: temporär root-Login + PW-Auth aktivieren (Demo!)
RUN sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config && \
    echo 'root:root' | chpasswd

# 6. Globale NPM-Installation einrichten (für den Nutzer dev)
RUN mkdir -p /home/dev/.npm-global && chown dev:dev /home/dev/.npm-global

USER dev
RUN npm config set prefix /home/dev/.npm-global
ENV PATH="/home/dev/.npm-global/bin:${PATH}"

# Zurück zu root, um den SSH-Dienst beim Start zu kontrollieren
USER root

# 7. Volumes:
#   /home/dev/projects    -> Projektverzeichnis
#   /home/dev/.npm-global -> globale Node-Module
#   /home/dev/.ssh        -> SSH-Hostkeys (persistent)
VOLUME ["/home/dev/projects", "/home/dev/.npm-global", "/home/dev/.ssh"]

# 8. Entry-Script: Erstellt Host-Keys, falls nicht vorhanden, und startet SSH
#    (damit bei jedem Start sichergestellt ist, dass Keys existieren,
#     auch wenn der Container komplett neu ist)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]

# Port 22 für SSH
EXPOSE 22
EXPOSE 8081
