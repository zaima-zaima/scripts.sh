#!/bin/bash

# 启动日志记录，将所有输出保存到日志文件中
exec > >(tee -i /var/log/timemachine_setup.log)
exec 2>&1

# 检查是否提供了Time Machine的大小、密码和备份目录参数
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "用法: $0 <TimeMachine大小 (如: 500G)> <密码> <备份目录>"
  exit 1
fi

# 验证输入的大小格式是否正确 (例如500G)
if [[ ! $1 =~ ^[0-9]+[GM]$ ]]; then
  echo "错误: 无效的大小格式，请使用类似 500G 或 2T 的格式."
  exit 1
fi

# 将参数赋值给变量
TIME_MACHINE_SIZE=$1
USER_PASSWORD=$2
BACKUP_DIR=$3

# 确保备份目录路径存在，如果不存在则创建
mkdir -p $BACKUP_DIR
if [ $? -ne 0 ]; then
  echo "错误: 创建备份目录 $BACKUP_DIR 失败"
  exit 1
fi

# 安装samba和avahi
yum install samba avahi -y
if [ $? -ne 0 ]; then
  echo "错误: 安装samba和avahi失败"
  exit 1
fi

# 创建timeMachine用户并设置密码
useradd timeMachine
if [ $? -ne 0 ]; then
  echo "错误: 创建用户失败"
  exit 1
fi

# 设置用户密码
echo "timeMachine:$USER_PASSWORD" | chpasswd
if [ $? -ne 0 ]; then
  echo "错误: 设置用户密码失败"
  exit 1
fi

# 设置备份目录的权限
chown timeMachine $BACKUP_DIR
chmod u=rwx $BACKUP_DIR
if [ $? -ne 0 ]; then
  echo "错误: 设置目录权限失败"
  exit 1
fi

# 写入samba配置文件
cat <<EOL > /etc/samba/smb.conf
# See smb.conf.example for a more detailed config file or
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
   path = $BACKUP_DIR
   valid users = timeMachine
   fruit:time machine = yes
   fruit:time machine max size = $TIME_MACHINE_SIZE
   read only = no
EOL

# 添加用户到samba
smbpasswd -a timeMachine
if [ $? -ne 0 ]; then
  echo "错误: 添加samba用户失败"
  exit 1
fi

# 启动并设置samba服务自启动
systemctl start smb.service
if systemctl is-active --quiet smb.service; then
  echo "Samba服务启动成功"
else
  echo "错误: Samba服务启动失败" >&2
  exit 1
fi
systemctl enable smb.service

# 配置防火墙以允许samba服务
firewall-cmd --permanent --zone=public --add-service=samba
if [ $? -ne 0 ]; then
  echo "错误: 防火墙配置失败"
  exit 1
fi
firewall-cmd --reload

# 检测并配置SELinux状态
if grep -q '^SELINUX=enforcing' /etc/selinux/config; then
  setsebool -P samba_enable_home_dirs 1
  restorecon -R $BACKUP_DIR
  echo "SELinux设置已更新"
else
  echo "SELinux未启用，跳过配置"
fi

# 安装CIFS工具包
yum install -y cifs-utils
if [ $? -ne 0 ]; then
  echo "错误: 安装CIFS工具包失败"
  exit 1
fi

# 检查系统版本
if [ -f /etc/redhat-release ]; then
  VERSION_ID=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release)
  echo "检测到的CentOS/RHEL版本: $VERSION_ID"
fi

# 脚本完成
echo "Time Machine设置已完成，大小为 $TIME_MACHINE_SIZE，备份目录为 $BACKUP_DIR"
