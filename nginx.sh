# install nginx

sudo yum install -y yum-utils

# create and config nginx.repo file

touch /etc/yum.repos.d/nginx.repo

echo '[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true' > /etc/yum.repos.d/nginx.repo

sudo yum-config-manager --enable nginx-mainline

sudo yum install -y nginx

# nginx configure

touch /etc/nginx/conf.d/strap.conf

echo '
server{
    listen 3221;
    location / {
        root /home/tmp;
    }
}
' > /etc/nginx/conf.d/strap.conf

# open 3221 port

firewall-cmd --zone=public --add-port=3221/tcp --permanent

systemctl restart firewalld.service

firewall-cmd --reload
nginx -s reload
