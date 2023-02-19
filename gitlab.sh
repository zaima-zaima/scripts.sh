sudo yum install -y curl policycoreutils-python openssh-server perl

sudo systemctl enable sshd

sudo systemctl start sshd

sudo firewall-cmd --permanent --add-service=http

sudo firewall-cmd --permanent --add-service=https

sudo systemctl reload firewalld

sudo yum install postfix

sudo systemctl enable postfix

sudo systemctl start postfix

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

sudo yum install -y gitlab-ee

sudo firewall-cmd --zone=public --add-port=80/tcp --permanent

sudo gitlab-ctl stop

sudo gitlab-ctl reconfigure

sudo gitlab-ctl start

cat /etc/gitlab/initial_root_password