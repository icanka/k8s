# #!/bin/bash
#
# # Enable password auth in sshd so we can use ssh-copy-id

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
# ensure that the sshd service is restarted and running
if systemctl restart sshd; then
	echo "sshd restarted"
else
	echo "sshd restart failed"
	exit 1
fi
