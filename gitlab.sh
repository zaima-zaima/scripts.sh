#!/bin/bash

# 定义变量
LOGFILE="/var/log/gitlab-install.log"
PASSWORD=$1  # 第一个参数：GitLab root 密码
REPO_PATH=$2  # 第二个参数：GitLab 仓库存储位置

# 日志记录
exec > >(tee -i $LOGFILE) 2>&1
exec 2>&1

# 检查参数是否传递
if [ -z "$PASSWORD" ] || [ -z "$REPO_PATH" ]; then
    echo "使用方法: $0 <GitLab root 密码> <仓库存储路径>"
    exit 1
fi

# 安装必要的软件包
sudo yum install -y curl policycoreutils-python openssh-server perl
if [ $? -ne 0 ]; then
    echo "安装依赖软件包失败，退出..."
    exit 1
fi

# 启用并启动 SSH 服务
sudo systemctl enable sshd
sudo systemctl start sshd

# 配置防火墙规则并重载
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --reload

# 安装并启用 Postfix 服务
sudo yum install -y postfix
if [ $? -ne 0 ]; then
    echo "安装 Postfix 失败，退出..."
    exit 1
fi
sudo systemctl enable postfix
sudo systemctl start postfix

# 安装 GitLab EE 版本
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
if [ $? -ne 0 ]; then
    echo "添加 GitLab 仓库失败，退出..."
    exit 1
fi

sudo yum install -y gitlab-ee
if [ $? -ne 0 ]; then
    echo "安装 GitLab 失败，退出..."
    exit 1
fi

# 停止 GitLab 服务，修改配置文件
sudo gitlab-ctl stop

# 配置 GitLab 密码和仓库存储路径
sudo sed -i "s/# git_data_dirs:.*/git_data_dirs:\n  default:\n    path: \"$REPO_PATH\"/" /etc/gitlab/gitlab.rb
sudo gitlab-rails runner "user = User.where(id: 1).first; user.password = '$PASSWORD'; user.password_confirmation = '$PASSWORD'; user.save!"

# 重新配置并启动 GitLab
sudo gitlab-ctl reconfigure
sudo gitlab-ctl start

# 输出初始 root 密码
echo "GitLab root 密码已设置为: $PASSWORD"
echo "GitLab 仓库存储位置为: $REPO_PATH"
