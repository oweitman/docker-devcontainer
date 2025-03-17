#!/bin/sh

set -e

# Prüfen, ob die Host-Keys bereits vorhanden sind.
# Wenn nicht, erzeugen wir sie mit ssh-keygen -A.
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "SSH host keys nicht gefunden. Erzeuge neue..."
    ssh-keygen -A
fi

chown -R dev:dev /home/dev/.vscode-server/
chown -R dev:dev /home/dev/.npm-global/
chown -R dev:dev /home/dev/sshfiles/
cp /home/dev/sshfiles/authorized_keys /home/dev/.ssh/authorized_keys 

# Anschließend führen wir den per CMD definierten Befehl aus,
# standardmäßig also: "/usr/sbin/sshd -D"
exec "$@"
# /usr/sbin/sshd -D 
