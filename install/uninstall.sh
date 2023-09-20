#!/bash/bash
#-----------------------------------
# Odoo kaldırma ayarları
#-----------------------------------


#1. Stop odoo service
sudo service odoo-server stop

#2. Delete all odoo files in the corresponding directory
sudo rm -R /opt/odoo
#3. Delete the configuration file
sudo rm -f /etc/odoo-server.conf
sudo rm -f /etc/odoo.conf

#4. If the odoo system is linked to startup

update-rc.d -f odoo-server remove
sudo rm -f /etc/init.d/odoo-server

#5. Delete users and user groups

userdel -r postgres
groupdel postgres


#6 Delete the database

sudo apt-get remove postgresql -y
sudo apt-get --purge remove postgresql\* -y
sudo rm -r -f /etc/postgresql/
sudo rm -r -f /etc/postgresql-common/
sudo rm -r -f /var/lib/postgresql/
