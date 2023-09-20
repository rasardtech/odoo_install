#!/bin/bash  
################################################################################  
# Bu script Ubuntu 16.04, 18.04 and 20.04 Ubuntu sürümlerinde çalışmaktadır.  
# Yazar: Autoronics | Cantay Aktura  
#-------------------------------------------------------------------------------  
# Kurulum dosyasını indirin 
# git clone git@gitlab.com:autoronics/odooinstall.git
# cd odooinstall  
# chmod +x run.sh && chmod +x config.sh && chmod +x install/*
# Odoo'yu kurmak için komut dosyasını yürütün:  
# ./run  
################################################################################  
OE_SUPERADMIN="admin"  # Odoo varsayılan süper yönetici şifresini ayarlama
IS_ENTERPRISE="False"  # Odoo Enterprise'ı kurmak istiyorsanız bunu True olarak ayarlayın!

# Yüklemek istiyorsanız true, ihtiyacınız yoksa veya zaten kuruluysa false olarak ayarlayın.

PROJECT_NAME="dyesol"  #Proje adını giriniz
WEBSITE_NAME="dyesol.rasard.pro" #We

HTTP_PROTOCOL="https"
HTTPS_PORT="443"

INSTALL_CERTIFICATE="True"
ENABLE_SSL="True"


EMAIL="info@rasard.com"
CRON_SCRIPT="/etc/cron.daily/certbot-renew"

PUBLIC_IP="144.91.105.127" #MANUEL OLARAK AYARLA
DOMAIN_NAME="dyesol.rasard.pro" # DNS YAPILANDIRILMASI YAPILMALIDIR!
DOMAIN_ALIASES=("dyesol.rasard.pro") 

# odoo kurulum patikası /userpath/15.0/odoo & /odoo/15.0/odoo
OE_VERSION="16.0"
OE_INSTALL_DIR="$OE_HOME/$OE_VERSION"
OE_REPO="$OE_INSTALL_DIR/odoo"

OE_PORT="8100"
OE_NETRPC_PORT="8101"
OE_LONGPOOL_PORT="8102"
OE_WORKERS="4"
# Yüklemek istediğiniz Odoo sürümünü seçin. Örnek: 9.0, 8.0, 7.0 veya saas-6. 'Trunk' kullanılırken ana sürüm yüklenecek
#ÖNEMLİ! Bu komut dosyası, özellikle Odoo 9.0 için gerekli olan ekstra kitaplıkları içerir.


INSTALL_WKHTMLTOPDF="True" # PDF yazıcısı

# Postgresql Kurulum Ayarları
INSTALL_PG_SERVER="True" # false ise, yalnızca istemci kurulacaktır
OE_DB_HOST="localhost"
OE_DB_PORT="5432"
OE_DB_USER="dyesolodoodb"
OE_DB_PASSWORD="ed^9%dgDM4r^"
PG_VERSION="15"

#Webserver varsayılan kurulum yapılandırması
WEB_SERVER="nginx" # veya "apache2"


#!/bin/bash
##fixed parameters
#odoo

if [ $DOMAIN_NAME == "localhost" ]; then
  proje="odoo-$PROJECT_NAME"
else
  proje="$DOMAIN_ALIASES"
fi

if [ $IS_ENTERPRISE = "True" ]; then
    OE_CONFIG="$OE_INSTALL_DIR/$proje-enterprise.conf"
    OE_INIT="$proje-enterprise"
    OE_WEBSERV_CONF="$proje-enterprise.conf"
    OE_WEBSERVER_HOST="$proje-e"
    OE_ADDONS_PATH="$OE_INSTALL_DIR/all_addons,$OE_INSTALL_DIR/enterprise/addons,$OE_REPO/addons"
    OE_LOG_PATH="$OE_INSTALL_DIR/logs/enterprise"
    OE_TEXT="Enterprise"
else
    OE_CONFIG="$OE_INSTALL_DIR/$proje.conf"
    OE_INIT="$proje"
    OE_WEBSERV_CONF="$proje.conf"
    OE_WEBSERVER_HOST="$proje"
    OE_ADDONS_PATH="$OE_INSTALL_DIR/all_addons,$OE_REPO/addons"
    OE_LOG_PATH="$OE_INSTALL_DIR/logs/community"
    OE_TEXT="Community"
fi

if [ $OE_VERSION = "11.0" ] || [ $OE_VERSION = "12.0" ] || [ $OE_VERSION = "13.0" ] || [ $OE_VERSION = "14.0" ] || [ $OE_VERSION = "15.0" ] || [ $OE_VERSION = "16.0" ]; then
    PYTHON_VERSION="3"
else
    PYTHON_VERSION="2"
fi
PYTHON_VERSION="3"
