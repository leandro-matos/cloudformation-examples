#!/bin/bash

## Ensure users' dot files are not group or world writable
for i in `find /home/ -name ".*" -perm /g+w,o+w`; do chmod go-w $i; done

## Ensure at/cron is restricted to authorized users
rm /etc/at.deny
touch /etc/cron.allow
touch /etc/at.allow
chmod og-rwx /etc/cron.allow
chmod og-rwx /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow

## Ensure HTTP server is not enabled
systemctl stop apache2 && systemctl disable apache2
apt-get purge apache2 apache2-utils -y

## auditd configuration , Ensure no pending OS security updates
apt update && apt install -y auditd linux-aws
echo "-w /etc/sudoers -p wa -k scope" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/sudoers.d/ -p wa -k scope" >> /etc/audit/rules.d/audit.rules
echo "-w /sbin/insmod -p x -k modules " >> /etc/audit/rules.d/audit.rules
echo "-w /sbin/rmmod -p x -k modules" >> /etc/audit/rules.d/audit.rules
echo "-w /sbin/modprobe -p x -k modules " >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit arch=b64 -S init_module -S delete_module -k modules" >> /etc/audit/rules.d/audit.rules
echo "-e 2" >> /etc/audit/rules.d/audit.rules
systemctl restart auditd

## Ensure permissions are configured
chmod 600 /etc/ssh/sshd_config
chmod 750 /home/ubuntu/
chmod 600 /boot/grub/grub.cfg

## Ensure source routed packets are not accepted, Ensure core dumps are restricted
echo 0 > /proc/sys/net/ipv4/conf/default/accept_source_route
echo 'fs.suid_dumpable = 0' >> /etc/sysctl.conf
sysctl -p
