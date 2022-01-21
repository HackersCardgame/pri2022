#!/bin/bash

green="\e[1;92m"
yellow="\e[1;93m"
red="\e[91m"
default="\e[39m"

SCRIPT=$(readlink -f "$0")
BASEPATH=$(dirname "$SCRIPT")

# ==============================================================================
function ShowAndExecute {
#show command
echo ================================================================================
echo -e "EXECUTING: ${yellow} $@ ${default}"
echo --------------------------------------------------------------------------------
#execute command
if [ "$2" = "" ]
then
  $1
else
  $1 "$2"
fi
#test if it worked or give an ERROR Message in red, return code of apt is stored in $?
rc=$?;
if [[ $rc != 0 ]]
  then
	  echo -e ${red}ERROR${default} $rc
	  echo ERROR: $@ >> $BASEPATH/log.txt
	  #exit 1 #REMOVED since pr-test crashes, TODO: reenable
	else
	  echo -e ${green}SUCCESS${default} $rc
	  echo SUCCESS: $@ >> $BASEPATH/log.txt
fi
}
# ==============================================================================



#ON CENTOS
################################################################################
if test -f "/bin/rpm"
then
  echo -e "${yellow}maybe centos${default}"

  ShowAndExecute "mysql_install_db"

  echo -e "${yellow}  mkdir -p /etc/my.cnf.d/${default}"
  mkdir -p /etc/my.cnf.d/
  ShowAndExecute "cp $BASEPATH/scripts/pci.cnf /etc/my.cnf.d/pci.cnf"

  sleep 5

  echo -e "executing ${yellow}cd '/usr' ; /usr/bin/mysqld_safe --datadir='/var/lib/mysql'${default}"
  pwd
  cd '/usr'
  pwd
  /usr/bin/mysqld_safe --datadir='/var/lib/mysql' &
  pwd
  echo -e "executed ${green}cd '/usr' ; /usr/bin/mysqld_safe --datadir='/var/lib/mysql'${default}"

  cd /builds/phase/pri42/tools/install

  sleep 5


  echo -e "${yellow}mysql < $BASEPATH/tables/centos-user.sql${default}"
  #mysql < $BASEPATH/tables/centos-user.sql
  ShowAndExecute 'mysql -e' "source $BASEPATH/tables/centos-user.sql;"

fi

# ubuntu has dofferent config structure for mysql, not yet using mariadb.conf.d
if test -f "/etc/apt/sources.list"
then
	if grep -q ubuntu "/etc/apt/sources.list"
	then
		echo -e "${yellow}  mkdir -p /etc/mysql/mysql.conf.d/${default}"
		mkdir -p /etc/mysql/mysql.conf.d/
		ShowAndExecute "cp $BASEPATH/scripts/pci.cnf /etc/mysql/mysql.conf.d/pci.cnf"
	fi
fi

#ON deiban-oid OPERATING SYSTEMS (Debian / UBuntu...)
################################################################################
if test -f "/etc/apt/sources.list"
then
  echo -e "${yellow}debianoid system detected${default}"

  ShowAndExecute "/etc/init.d/mysql stop"

  echo -e "${yellow}  mkdir -p /etc/mysql/mariadb.conf.d/${default}"
  mkdir -p /etc/mysql/mariadb.conf.d/
  
  ShowAndExecute "cp $BASEPATH/scripts/pci.cnf /etc/mysql/mariadb.conf.d/pci.cnf"
  
  chown -R mysql:mysql /var/lib/mysql
  
  ShowAndExecute "/etc/init.d/mysql start"

  ShowAndExecute 'mysql -e' "source $BASEPATH/tables/debian-user.sql;"

fi

#ON ALL OPERATING SYSTEMS
################################################################################

ShowAndExecute 'mysql -e' "SELECT @@max_heap_table_size;"
ShowAndExecute 'mysql -e' "SELECT @@tmp_table_size;"
echo -e "${yellow}HEAP AND TEMP TABLE MUST BE > 2GB${default}"

$BASEPATH/create-databases.sh

#DEBIAN-oid systems
if test -f "/etc/apt/sources.list"
then
  $BASEPATH/fill-databases.sh
fi


#CENTOS
if test -f "/bin/rpm"
then
	scl enable rh-python36 $BASEPATH/fill-databases.sh
fi

cat $BASEPATH/log.txt

