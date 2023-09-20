#!/bin/bash
# ------------------------------------------------------
# Sertifikasyon yükleme alanı
# ------------------------------------------------------


echo -e "---------------------------------"
echo -e "Gerektiğinde sertifikayı yükleyin"
echo -e "---------------------------------"

if [ $INSTALL_CERTIFICATE = "True" ] && [ ! -z "$DOMAIN_NAME" ]; then

    #--------------------------------------------------
    # Let's encrypt kütüphanesini yükleyin
    #--------------------------------------------------
    sudo apt-get install -y dnsutils dirmngr git wget

    # Alanın erişilebilir olup olmadığını kontrol edin
    PUBLIC_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
    REACHED_IP=`dig $DOMAIN_NAME A +short`
    if [[ $REACHED_IP == $PUBLIC_IP ]]; then
        INSTALL_CERTIFICATE="True"
    else
        INSTALL_CERTIFICATE="False"
        echo "ÖNEMLİ! Sertifikasyon yüklemesi başlatılmıyor, alan adınız global dns sorgusunda çözümlenemiyor çözülemeyen domain ${DOMAIN_NAME} ve ip ${PUBLIC_IP}"
    fi

    if [ $INSTALL_CERTIFICATE = "True" ]; then
        sudo add-apt-repository "deb http://ftp.debian.org/debian $(lsb_release -sc)-backports main"
        sudo apt-get update

        domains="-d $DOMAIN_NAME"
        for alias in ${DOMAIN_ALIASES[@]} ; do
            domains="$domains -d $alias"
        done
        if [ $WEB_SERVER = "apache2" ] ; then
            echo -e "Apache ile sertifikayı yapılandırma"
            sudo apt-get install python3-certbot-apache -y
            sudo certbot --apache $domains  --non-interactive --agree-tos --redirect -m $EMAIL
        fi

        if [ $WEB_SERVER = "nginx" ] ; then
            echo -e "Nginx ile sertifika yapılandırma"
            sudo apt-get install python3-certbot-nginx -y
            sudo certbot --nginx $domains  --non-interactive --agree-tos --redirect -m $EMAIL
        fi
    fi
fi
