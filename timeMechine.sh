yum install samba avahi -y # 安装samba服务以及avahi #

useradd timeMachine # 设置用户 #

passwd timeMachine # 设置用户密码 #

cd /

mkdir data

cd data

mkdir backup

chown timeMachine /data/backup

chmod u=rwx /data/backup

echo "# See smb.conf.example for a more detailed config file or
# read the smb.conf manpage.
# Run 'testparm' to verify the config is correct after
# you modified it.

[global]
        workgroup = SAMBA
        security = user

        passdb backend = tdbsam

        printing = cups
        printcap name = cups
        load printers = yes
        cups options = raw

        vfs objects = catia fruit streams_xattr
        min protocol = SMB3_11
        smb encrypt = required
        ea support = yes
        fruit:metadata = stream
        fruit:model = MacSamba
        fruit:posix_rename = yes
        fruit:veto_appledouble = no
        fruit:wipe_intentionally_left_blank_rfork = yes
        fruit:delete_empty_adfiles = yes
        fruit:aapl = yes

[homes]
        comment = Home Directories
        valid users = %S, %D%w%S
        browseable = No
        read only = No
        inherit acls = Yes

[printers]
        comment = All Printers
        path = /var/tmp
        printable = Yes
        create mask = 0600
        browseable = No

[print$]
        comment = Printer Drivers
        path = /var/lib/samba/drivers
        write list = @printadmin root
        force group = @printadmin
        create mask = 0664
        directory mask = 0775

[TimeMachine]
   path = /data/backup
   valid users = timeMachine
   fruit:time machine = yes
   fruit:time machine max size = 500G
   read only = no
" > /etc/samba/smb.conf

smbpasswd -a timeMachine

systemctl start smb.service

systemctl enable smb.service

firewall-cmd --permanent --zone=public --add-service=samba

firewall-cmd --reload

echo "
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled

# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted 


" > /etc/selinux/config

yum install -y cifs-utils

poweroff --r now