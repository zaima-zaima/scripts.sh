#参数：

# 参数一：mysql密码



yum groupinstall 'Development tools' -y
# 添加 Nginx 源
sudo yum install -y epel-release
# 安装 Nginx
sudo yum install -y nginx
# 启动 Nginx
nginx
# 配置防火墙规则
sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload

# yum自带源中没有Node.js,所以首先要获取Node.js资源：
curl --silent --location https://rpm.nodesource.com/setup_14.x | bash -

# 安装 Node.js
yum install -y nodejs

# 安装完成之后使用如下指令测试安装是否成功
node -v

# 安装pm2 node.js程序管理工具
npm i pm2 -g

# 安装wget

yum install -y wget

# 下载并安装 MySQL 源
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo yum -y localinstall mysql80-community-release-el7-3.noarch.rpm

# 如果上一步报错 执行下面的语句 之后 再次执行一下上面的安装Mysql的语句
# sudo yum module disable mysql

# 安装 MySQL
sudo yum install mysql-community-server -y

# 启动mysql
sudo systemctl start mysqld

# 创建网站根目录
mkdir /home/nginx/

# 创建nginx配置文件

cd /etc/nginx/conf.d
# 创建配置文件
touch ilovefe.conf