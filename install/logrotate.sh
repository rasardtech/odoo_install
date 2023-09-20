#!/bin/bash
# ------------------------------------------------------
# Logrotate kurulum bölümü
# ------------------------------------------------------


echo -e "Install logrotate"

    #--------------------------------------------------
    # Logrotate kütüphanesi yükleniyor
    #--------------------------------------------------
    sudo apt-get install -y logrotate

cat <<EOF > /etc/logrotate.d/odoo
#Path odoo logs
   $OE_LOG_PATH/*.log {
        rotate 5
        size 100M
        daily
        compress
        delaycompress
        missingok
        notifempty
        su odoo odoo
}

EOF
