#!/bin/bash
#--------------------------------------------------
# PostgreSQL Kurulum Alanı
#--------------------------------------------------


PG_ALREADY_INSTALLED="False"
export OE_DB_PORT
# Önce postgrelerin kurulu olup olmadığını kontrol edelim
if [ $INSTALL_PG_SERVER = "True" ]; then
    SERVER_RESULT=`sudo -E -u postgres bash -c "psql -X -p $OE_DB_PORT -c \"SELECT version();\""`
    if [ -z "$SERVER_RESULT" ]; then
        echo "$OE_DB_PORT Bağlantı noktasına hiçbir postgres veritabanı kurulu değil. Bu yüzden kurulumu başlatılacak"
    else
        if [[ $SERVER_RESULT == *"PostgreSQL $PG_VERSION"* ]]; then
            echo "Sisteminizde PostgreSQL $PG_VERSION versiyonu kurulu ve $OE_DB_PORT nolu port aktif görünüyor. Kurulumu iptal ediliyor. Sonraki aşamaya geçiliyor."
            PG_ALREADY_INSTALLED="True"
        else
            echo "$OE_DB_PORT numaralı bağlantı çalışıyor. Ve PostgreSQL $PG_VERSION versiyonu dışında bir sürüm. Yeni sürük tekrar kuruluma başlayacak!"
            exit 1
        fi
    fi
else
    CLIENT_RESULT=`psql -V`
    if [ -z "$CLIENT_RESULT" ]; then
        echo "PosgreSQL İstemcisi kurulu değil. Yükleme başlatılacak."
    else
        if [[ $CLIENT_RESULT == *"$PG_VERSION"* ]]; then
            echo "Zaten PostgreSQL İstemci sürümü $PG_VERSION sahibiz. Kurulum atlanıyor."
            PG_ALREADY_INSTALLED="True"
        else
            echo "Yüklü PostgreSQL İstemcisinin doğru sürümü değil. Gerekli $PG_VERSION versiyon, yüklü '$CLIENT_RESULT' versiyon. Yeniden yüklemeyi deneyeceğiz."
        fi
    fi
fi
echo -e "\n---- *********************************** ----"
echo -e "\n---- PostgreSQL Server Kuruluma Başladı ----"
echo -e "\n---- *********************************** ----"
if [ $PG_ALREADY_INSTALLED == "False" ]; then
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main"
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update
fi

if [ $INSTALL_PG_SERVER = "True" ]; then

    export PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
    export PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

    if [ $PG_ALREADY_INSTALLED == "False" ]; then
        echo -e "\n---- Install PostgreSQL Server ----"
        sudo apt-get install postgresql-$PG_VERSION -y

        # Edit postgresql.conf to change listen address to '*':
        sudo -u postgres sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

        # Edit postgresql.conf to change port to '$OE_DB_PORT':
        sudo -u postgres sed -i "s/port = 5432/port = $OE_DB_PORT/" "$PG_CONF"
    fi

    # PostgresSQL Server zaten kurulu olsa bile, onu ERP için optimize etmek ve DB kullanıcısı oluşturmak isteyebiliriz..
    export MEM=$(awk '/^MemTotal/ {print $2}' /proc/meminfo)
    export CPU=$(awk '/^processor/ {print $3}' /proc/cpuinfo | wc -l)
    export CONNECTIONS="100"

    # Set default client_encoding
    sudo -E -u postgres bash -c 'echo "client_encoding = utf8" >> "$PG_CONF"'

    # Set parameters for ERP/OLTP
    sudo -E -u postgres bash -c 'echo "effective_cache_size = $(( $MEM * 3 / 4 ))kB" >> "$PG_CONF"'
    sudo -E -u postgres bash -c 'echo "checkpoint_completion_target = 0.9" >> "$PG_CONF"'
    sudo -E -u postgres bash -c 'echo "shared_buffers = $(( $MEM / 4 ))kB" >> "$PG_CONF"'
    sudo -E -u postgres bash -c 'echo "maintenance_work_mem = $(( $MEM / 16 ))kB" >> "$PG_CONF"'
    sudo -E -u postgres bash -c 'echo "work_mem = $(( ($MEM - $MEM / 4) / ($CONNECTIONS * 3) ))kB" >> "$PG_CONF"'
    sudo -E -u postgres bash -c 'echo "random_page_cost = 4         # or 1.1 for SSD" >> "$PG_CONF"'
    sudo -E -u postgres bash -c 'echo "effective_io_concurrency = 2 # or 200 for SSD" >> "$PG_CONF"'
    sudo -E -u postgres bash -c 'echo "max_connections = $CONNECTIONS" >> "$PG_CONF"'

    # Şimdi yeni kullanıcı oluşturalım
    export OE_DB_USER
    export OE_DB_PASSWORD
 
    # Parola yetkilendirmesi eklemek için pg_hba.conf'a ekleyin:
    sudo -E -u postgres bash -c 'echo "host    all             $OE_DB_USER             all                     md5" >> "$PG_HBA"'

    # Tüm yeni yapılandırmaların yüklenmesi için yeniden başlatın:
    sudo service postgresql restart

    echo -e "\n---- ODOO PostgreSQL Kullanıcısını Oluşturma  ----"
    sudo -E -u postgres bash -c "psql -X -p $OE_DB_PORT -c \"CREATE USER $OE_DB_USER WITH CREATEDB NOCREATEROLE NOSUPERUSER PASSWORD '$OE_DB_PASSWORD';\""

    # Tüm yeni yapılandırmaların yüklenmesi için yeniden başlatın:
    sudo service postgresql restart
else
    echo -e "\n---- PostgreSQL İstemcisini Kurun ----"
    sudo apt-get install postgresql-client-$PG_VERSION -y
fi
