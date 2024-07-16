#!/bin/bash

echo "Cài đặt các ứng dụng cần thiết"
sudo apt-get update -y
sudo apt-get install nginx -y
sudo apt-get install wget git npm -y
sudo apt-get install unzip -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install nodejs -y

# Lấy phiên bản của Node.js
node_version=$(node --version | cut -d 'v' -f 2)

# So sánh phiên bản với v12
if [[ "$node_version" > "12" ]]; then
    echo "Phiên bản Node.js ($node_version) lớn hơn v12. Tiếp tục chạy."
    # Thực hiện các lệnh tiếp theo ở đây
else
    echo "Phiên bản Node.js ($node_version) không lớn hơn v12. Dừng các lệnh tiếp theo."
    exit 1
fi

echo "Nhập tên Project"

read themename

echo "Nhập tên trang web"

read webname

cd /home

mkdir Projects

cd /root

echo "Giải nén file codetheme.zip"

unzip codetheme.zip -d $themename

mv $themename /home/Projects/

configix() {
var=/etc/nginx/conf.d/$themename.conf
    cat <<EOF >$var
server {
    listen       80;
    server_name  $webname;

    #access_log  /var/log/nginx/log.access.log;
    #error_log  /var/log/nginx/log.error.log;
    root        /home/Projects/$themename/dist;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.html?\$args;
    }

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    location ~ /\.ht {
        deny  all;
    }
}

EOF
}
echo "Tạo file config"

configix

cd /home/Projects/$themename
echo "Khởi chạy npm build"
npm i
npm run build
echo "Khởi động lại nginx"
sudo systemctl restart nginx
echo "Dọn dẹp tài nguyên"
cd /root
rm -rf conf.txt
echo "Thiết lập hoàn tất"
