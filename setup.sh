## MySQL repo ##
wget -qO - http://repo.mysql.com/RPM-GPG-KEY-mysql-2023 | gpg --dearmor > /usr/share/keyrings/mysql.gpg
echo "deb [signed-by=/usr/share/keyrings/mysql.gpg] http://repo.mysql.com/apt/debian $(lsb_release -sc) mysql-8.0" > /etc/apt/sources.list.d/mysql.list

## PHP repo ##
wget -qO - https://ftp.mpi-inf.mpg.de/mirrors/linux/mirror/deb.sury.org/repositories/php/apt.gpg | gpg --dearmor > /usr/share/keyrings/deb.sury.org-php.gpg
echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://ftp.mpi-inf.mpg.de/mirrors/linux/mirror/deb.sury.org/repositories/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

## Install packages ##
apt-get update
apt-get install -y unzip openssl nginx mysql-server php8.1 php8.1-fpm php8.1-mysqli php8.1-cli php8.1-curl php8.1-gd php8.1-mbstring php8.1-pdo php8.1-xml php8.1-zip

## Group for FPM pool ##
groupadd wintercms

## Add user without sudo ##
useradd -d /home/kvitee -m -s $(which bash) -G wintercms kvitee

## Get composer installer script and checksum to verify it ##
curl -sS https://getcomposer.org/installer -o composer-setup.php
curl -sS https://composer.github.io/installer.sha384sum -o checksums

## Verify installer ##
if sha384sum --check --status checksums; then
  echo "Installer verified."
else
  echo "Installer corrupted!"
  exit 1
fi

## Install composer ##
php8.1 composer-setup.php --install-dir=/usr/local/bin --filename=composer

## Remove unnecessarry files ##
rm composer-setup.php checksums

## Create FPM pool ##
cp wintercms.conf /etc/php/8.1/fpm/pool.d/

## Create Nginx config ##
rm /etc/nginx/sites-enabled/default
cp domain.ru /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/domain.ru /etc/nginx/sites-enabled/

## Restart services ##
systemctl restart nginx php8.1-fpm

## Make directories for CMS ##
mkdir /var/www/wintercms

## Set owner and access permissions ##
chown kvitee:www-data /var/www/wintercms
chmod 755 /var/www/wintercms

## Setup database for CMS ##
echo "
  CREATE USER winter@localhost;
  CREATE DATABASE winterdb;
  GRANT ALL PRIVILEGES ON winterdb.* TO winter@localhost;
" | mysql


## All commands below should be executed as kvitee ##
su kvitee

## Change dir to wintercms installation ##
cd /var/www/wintercms

## Create Winter CMS instance ##
composer create-project wintercms/winter .

## Generate .env file ##
./artisan winter:env

## Edit .env ##
sed -i -e 's/DEBUG=true/DEBUG=false/' -e 's/DB_DATABASE="winter"/DB_DATABASE="winterdb"/' .env

## Run migrations ##
./artisan winter:up

## Install nvm for new user ##
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.bashrc

## Install required NodeJS versions ##
nvm install 16
nvm install 20

## Use Node.js of version 20.x ##
nvm use 20

## Clone Next.js project ##
git clone -b "v1.0.0" --single-branch https://github.com/kvitee/nextjs-test.git ~/nextjs-test
cd ~/nextjs-test

## Install dependencies ##
npm i

## Build project ##
npm run build

## Start server ##
pm2 start next --name "nextjs" -- start --port=4187
pm2 save
