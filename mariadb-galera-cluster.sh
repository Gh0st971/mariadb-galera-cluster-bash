#!/bin/bash
#
#   CONFIGURE MARIADB GALERA CLUSTER
#   TESTED ON UBUNTU 22.01 MINIMAL
#

## Parameter setup ##

CLUSTER_NAME=cluster_name
NODE_NAME=cluster_member_name
NODE_IP=10.0.0.4

CLUSTER_IP[0]=$NODE_IP
CLUSTER_IP[1]=10.0.0.5
CLUSTER_IP[2]=10.0.0.6
# Add more if needed
# CLUSTER_IP[99]=10.0.0.103


## DO NOT EDIT AFTER THIS ##

# Root check
if [[ $EUID -ne 0 ]]; then
	echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	echo "@@    Please run this script as root !   @@"
	echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	exit;
fi

MARIADB_SERVER_CONF=/etc/mysql/mariadb.conf.d/50-server.cnf
MARIADB_GALERA_CONF=/etc/mysql/mariadb.conf.d/60-galera.cnf

sudo cp $MARIADB_SERVER_CONF $MARIADB_SERVER_CONF.bak

sudo sed -e '/bind-address/ s/^#*/#/' -i $MARIADB_SERVER_CONF

CLUSTER_STRING="gcomm://"$(IFS=, ; echo "${CLUSTER_IP[*]}")

sudo echo '[galera]
wsrep_on                 = ON
wsrep_cluster_name       = \"'$CLUSTER_NAME'\"
wsrep_provider           = /usr/lib/galera/libgalera_smm.so
wsrep_cluster_address    = \"'$CLUSTER_STRING'\"
binlog_format            = row
default_storage_engine   = InnoDB
innodb_autoinc_lock_mode = 2
bind-address = 0.0.0.0
wsrep_node_address=\"'$NODE_IP'\"
wsrep_node_name=\"'$NODE_NAME'\"' > $MARIADB_GALERA_CONF

sudo galera_new_cluster
sudo systemctl restart mariadb 

wsrep_node_address=\"'$IP'\"
wsrep_node_name=\"'$IP'\"' > /etc/mysql/conf.d/cluster.cnf"

sudo service mysql stop"
sudo service mysql start --wsrep-new-cluster
