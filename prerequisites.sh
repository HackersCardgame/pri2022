#!/bin/bash

green="\e[1;92m"
yellow="\e[1;93m"
red="\e[91m"
default="\e[39m"

SCRIPT=$(readlink -f "$0")
BASEPATH=$(dirname "$SCRIPT")

echo ********************************************************************************
echo ********************************************************************************
echo LC_ALL: $LC_ALL
echo LC_CTYPE: $LC_CTYPE
echo ********************************************************************************
echo ********************************************************************************


# ==============================================================================
function ShowAndExecute {
echo ================================================================================
echo -e "EXECUTING: ${yellow} $@ ${default}"
echo --------------------------------------------------------------------------------
#execute command
if [ "$2" = "" ]
then
  $1 >/dev/null
else
  $1 "$2"
fi
#test if it worked or give an ERROR Message in red, return code of apt is stored in $?
rc=$?;
if [[ $rc != 0 ]]
  then
	  echo -e ${red}ERROR${default} $rc
		echo ERROR: $1 >>$BASEPATH/log.txt
		if [ "$2" = "" ]
	  echo -e ${red}trying a second time ${yellow}$1 "$2" ${default}
		then
			$1 >/dev/null
		else
			$1 "$2"
		fi
		if [[ $rc != 0 ]]
			then
				echo -e ${red}SECOND ERROR${default} $rc
				echo ERROR 2: $1 >>$BASEPATH/log.txt
				echo giving up
			else
				echo -e ${green}SUCCESS${default} $rc
				echo SUCCESS 2: $1 >>$BASEPATH/log.txt
    fi
	  #exit 1 #REMOVED since pr-test crashes, TODO: reenable
	else
	  echo -e ${green}SUCCESS${default} $rc
		echo SUCCESS 1: $1 >>$BASEPATH/log.txt
fi
}
# ==============================================================================



if test -f "/bin/rpm"
then
  echo maybe centos

  ShowAndExecute "yum -y update"

#only centos!!!
 # export LC_ALL="en_US.UTF-8"
 # export LC_CTYPE="en_US.UTF-8"

  
echo "
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
" > /etc/yum.repos.d/MariaDB.repo

  yum install MariaDB-server MariaDB-client MariaDB-devel -y

#GPG key retrieval failed: [Errno 14] curl#6 - "Could not resolve host: yum.mariadb.org; Unknown error"
#so lets try twice since manually it works

echo "
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
" > /etc/yum.repos.d/MariaDB.repo


  ShowAndExecute "yum -y install MariaDB-server MariaDB-client MariaDB-devel"
  ShowAndExecute "yum -y install openssl-devel"
  ShowAndExecute "yum -y install readline-devel"
  ShowAndExecute "yum -y install pcre2-devel"
  ShowAndExecute "yum -y install centos-release-scl"
  ShowAndExecute "yum -y install devtoolset-8-gcc"
  ShowAndExecute "yum -y install  devtoolset-8-gcc-c++"
  ShowAndExecute "yum -y install rh-python36"
  ShowAndExecute "yum -y install rh-python36-python-pip"
  ShowAndExecute "yum -y install epel-release"
  
  ShowAndExecute "yum -y install openssl-devel"
  ShowAndExecute "yum -y install openssl-devel"
  ShowAndExecute "yum -y install openssl-devel"
  ShowAndExecute "yum -y install openssl-devel"

  ShowAndExecute "yum -y install psmisc"

  #yum -y install python-pip

  ShowAndExecute "ln -s /usr/bin/mysql_config /usr/bin/mariadb_config"

  scl enable rh-python36 bash <<EOF
    pip3 install requests
    pip3 install lxml
    pip3 install distance
    pip3 install wget
    pip3 install termcolor
    pip3 install cmd2
    pip3 install iso639
    scl enable devtoolset-8 bash <<EOF2
      pip3 install mysqlclient
EOF2
EOF

  echo possibly all packages installed
fi


if test -f "/etc/apt/sources.list"
then
  echo debianoid system detected
  
  echo "
if you are using debain stretch add the following line to /etc/apt/sources.list

   deb http://ftp.ch.debian.org/debian/ stretch-backports main contrib

and then type

   sudo apt-get update
   sudo apt-get install clang-6.0
"

  export DEBIAN_FRONTEND=noninteractive

  #std ubuntu mirrir is fucking slow, taking the swiss one
  sed -i -e 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/mirror.init7.net\/ubuntu\//g' /etc/apt/sources.list

  ShowAndExecute "apt-get -y update"
  ShowAndExecute "apt-get -y upgrade"
  
  ShowAndExecute "apt-get purge python3-mysqldb"

  ShowAndExecute "apt-get install -y apt-utils"
  ShowAndExecute "apt-get install -y psmisc"

  ShowAndExecute "apt-get install -y time"
  ShowAndExecute "apt-get install -y curl"
  ShowAndExecute "apt-get install -y python3-dateutil"
  
#ubuntu
apt-get install -y mysql-server

  ShowAndExecute "apt-get install -y mysql"
  ShowAndExecute "apt-get install -y mysql-client"
  ShowAndExecute "apt-get install -y libmysqlclient-dev"

#debian
  ShowAndExecute "apt-get install -y default-mysql-server"
  ShowAndExecute "apt-get install -y default-libmysqlclient-dev"
  ShowAndExecute "apt-get install -y default-mysql-client"

#debian && ubuntu
  ShowAndExecute "apt-get install -y libmariadb-dev"

  ShowAndExecute "apt-get install -y g++"
  ShowAndExecute "apt-get install -y build-essential"
  ShowAndExecute "apt-get install -y libssl-dev"
  ShowAndExecute "apt-get install -y libpcre2-dev"
  ShowAndExecute "apt-get install -y libreadline-dev"
  ShowAndExecute "apt-get install -y libreadline"
  ShowAndExecute "apt-get install -y libreadline7"

  ShowAndExecute "apt-get install -y python3"
  ShowAndExecute "apt-get install -y python3-pip"
  
  ShowAndExecute "apt-get install -y libssl-dev"

  ShowAndExecute "apt-get install -y valkyrie valgrind vim-gtk3"

  ShowAndExecute "pip3 install requests"
  ShowAndExecute "pip3 install lxml"
  ShowAndExecute "pip3 install distance"
  ShowAndExecute "pip3 install wget"
  ShowAndExecute "pip3 install termcolor"
  ShowAndExecute "pip3 install iso639"
  ShowAndExecute "pip3 install mysqlclient"


#for old debian (stretch)
	if grep -q stretch "/etc/apt/sources.list"
	then
		echo "deb http://ftp.ch.debian.org/debian/ stretch-backports main contrib" >> /etc/apt/sources.list
		ShowAndExecute "apt-get -y update"
		ShowAndExecute "apt-get -y install clang-6.0"
	fi

  echo possibly all packages installed
fi

cat $BASEPATH/log.txt
