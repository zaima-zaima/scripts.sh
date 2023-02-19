sudo yum install -y curl policycoreutils-python openssh-server perl

sudo systemctl enable sshd

sudo systemctl start sshd

sudo firewall-cmd --permanent --add-service=http

sudo firewall-cmd --permanent --add-service=https

sudo systemctl reload firewalld

sudo yum install postfix

sudo systemctl enable postfix

sudo systemctl start postfix

echo "[gitlab-ce]\nname=Gitlab CE Repository\nbaseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el'\$releasever'/\ngpgcheck=0\nenabled=1" >> /etc/yum.repos.d/gitlab-ce.repo

yum makecache

# curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

sudo yum install -y gitlab-ce

sudo firewall-cmd --zone=public --add-port=80/tcp --permanent

sudo gitlab-ctl stop

sudo gitlab-ctl reconfigure

sudo gitlab-ctl start

cat /etc/gitlab/initial_root_password