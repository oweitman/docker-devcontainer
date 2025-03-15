#!/usr/bin/env bash
set -e

# Prüfen, ob die Host-Keys bereits vorhanden sind.
# Wenn nicht, erzeugen wir sie mit ssh-keygen -A.
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "SSH host keys nicht gefunden. Erzeuge neue..."
    ssh-keygen -A
fi

# Anschließend führen wir den per CMD definierten Befehl aus,
# standardmäßig also: "/usr/sbin/sshd -D"
exec "$@"
