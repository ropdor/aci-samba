#!/usr/bin/env bash
set -e

# Start the build based on alpine
acbuild --debug begin docker://alpine:3.5

# In the event of the script exiting, end the build
acbuildEnd() {
    export EXIT=$?
    sudo acbuild --debug end && exit $EXIT 
}
trap acbuildEnd EXIT

# Name the ACI
acbuild --debug set-name hyp3rv0id/samba

# Install samba
sudo acbuild --debug run apk update
sudo acbuild --debug run apk add samba

acbuild --debug port add smb139 tcp 139
acbuild --debug port add smb445 tcp 445

# Add a mount point for smb.conf
acbuild --debug mount add smbconf /etc/samba/smb.conf

# Add a mount point for state dir
acbuild --debug mount add state /var/lib/samba

# Run samba in the foreground
acbuild --debug set-exec -- /usr/sbin/smbd -FS

# Save the ACI
sudo acbuild --debug write --overwrite samba-latest-linux-amd64.aci
