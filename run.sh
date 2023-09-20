#!/bin/bash
################################################################################
#-------------------------------------------------------------------------------  
# Kurulum dosyasını indirin 
# git clone git@gitlab.com:autoronics/odooinstall.git
# cd odooinstall  
# chmod +x run.sh && chmod +x config.sh && chmod +x install/*
# Odoo'yu kurmak için komut dosyasını yürütün:  
# ./run  
################################################################################  
exec 1> install.log 2>&1

if [[ $EUID -ne 0 ]]; then
   echo "Komut dosyası normal kullanıcı olarak çalıştırılıyor. Odoo onun adından yüklenecek" 
   OE_USER=$(whoami)
   OE_HOME=$HOME
else
   echo "Komut dosyası root olarak çalışıyor, bu nedenle yeni odoo kullanıcısı oluşturuluyor"
   OE_USER="odoo"
   OE_HOME="/$OE_USER"

   echo -e "\n---- ODOO sistem kullanıcısı oluşturuluyor ----"
   adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
   #The user should also be added to the sudo'ers group.
   adduser $OE_USER sudo
fi

source config.sh

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#--------------------------------------------------
# İşletim sistemini güncelle
#--------------------------------------------------
echo -e "-------------------------"
echo -e "\n---- Update Server ----"
echo -e "-------------------------"
sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y git 
#wget build-essential dnsutils lsb-release software-properties-common sudo -y

source install/db.sh

source install/odoo.sh

source install/initd.sh

# -------------------------------
# Websitesi kurulum bölümü
# -------------------------------

source install/apache.sh
source install/nginx.sh

dpkg --build $OE_AUTO_SCRIPTS_DIR
#mv $OE_AUTO_SCRIPTS_DIR $OE_AUTO_SCRIPTS_DIR.deb
sudo dpkg -i $OE_AUTO_SCRIPTS_DIR.deb

source install/certification.sh

source install/logrotate.sh
# ----------------------------------------------------
# İşimiz bitti! Odoo hizmetini başlatalım
# ----------------------------------------------------
echo -e "----------------------------"
echo -e "* Odoo Servisi Başlatılıyor"
echo -e "----------------------------"
sudo service $OE_INIT start

echo "-----------------------------------------------------------"
echo "Tamamlandı! Odoo sunucusu ayağa kaldırıldı ve çalışıyor. Teknik Detaylar:"
echo "Ubuntu Sistem Kullanıcı Adı: $OE_USER"
echo "Odoo Master Şifre: $OE_SUPERADMIN"
echo "Ubuntu Sistem Dizini: $OE_HOME"
echo "Odoo Kurulum Dizini: $OE_INSTALL_DIR"
echo "Odoo Yapılandırma Dosyası: $OE_CONFIG"
echo "Odoo Log Kayıtları: $OE_LOG_PATH/odoo-server.log"
echo "Python virtual environment (Python kütüphaneleri için): $OE_INSTALL_DIR/env"
if [ $WEB_SERVER = "nginx" ]; then
    echo "Nginx Odoo Site: /etc/nginx/sites-available/$proje"
fi
if [ $WEB_SERVER = "apache2" ]; then
    echo "Apache Odoo Site: /etc/apache2/sites-available/$proje"
fi
if [ $HTTP_PROTOCOL = "https" ] || [ $INSTALL_CERTIFICATE = "True" ]; then
    echo "SSL Sertifikasyon Dosya: $SSL_CERTIFICATE"
    echo "SSL Sertifikasyon Anahtar Dosyası $SSL_CERTIFICATE_KEY"
fi
echo "Protokol: $HTTP_PROTOCOL"
echo "PostgreSQL version: $PG_VERSION"
echo "PostgreSQL Kullanıcı: $OE_DB_USER"
echo "PostgreSQL Şifre: $OE_DB_PASSWORD"
echo "Odoo Başlat: sudo service $OE_INIT start"
echo "Odoo Durdur: sudo service $OE_INIT stop"
echo "Odoo Yeniden Başlat: sudo service $OE_INIT restart"
echo "-----------------------------------------------------------"
