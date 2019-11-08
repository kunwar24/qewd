#!/usr/bin/env bash

# 7 November 2019

# YottaDB

ydbver="r128"
ydbversion=r1.28

echo "Installing YottaDB $ydbversion"

# Create a temporary directory for the installer
mkdir -p /tmp/tmp
cd /tmp/tmp
wget https://gitlab.com/YottaDB/DB/YDB/raw/master/sr_unix/ydbinstall.sh
chmod +x ydbinstall.sh

gtmroot=/usr/lib/yottadb
gtmcurrent=$gtmroot/current

#echo "mapping libncurses.so.5"
#ln -s /lib/x86_64-linux-gnu/libncurses.so.5 /lib/x86_64-linux-gnu/libncurses.so.6
#ln -s /lib/x86_64-linux-gnu/libtinfo.so.5.9 /lib/x86_64-linux-gnu/libtinfo.so.6
#echo "mapping done"

# make sure directory exists for links to current YottaDB
mkdir -p $gtmcurrent
./ydbinstall.sh --utf8 default --verbose --debug --linkenv $gtmcurrent --linkexec $gtmcurrent --force-install $ydbversion
echo "Configuring YottaDB $ydbversion"

ls -l /usr/lib/yottadb/current

gtmprof=$gtmcurrent/gtmprofile
gtmprofcmd="source $gtmprof"
$gtmprofcmd
tmpfile=`mktemp`

echo 'copying ' $gtmprofcmd ' to profile...'
echo $gtmprofcmd >> ~/.profile

rm $tmpfile
unset tmpfile gtmprofcmd gtmprof gtmcurrent gtmroot

cd /opt/qewd
mkdir sessiondb

echo 'Setting up local internal, unjournalled region for QEWD Session global'
/usr/local/lib/yottadb/$ydbver/mumps -run ^GDE < /opt/qewd/gde.txt
/usr/local/lib/yottadb/$ydbver/mupip create -region=qewdreg
/usr/local/lib/yottadb/$ydbver/mupip set -file -nojournal /opt/qewd/sessiondb/qewd.dat

echo 'YottaDB has been installed and configured, ready for use'

cd /opt/qewd

# NodeM

echo 'Installing NodeM'

npm install nodem

ln -sf $gtm_dist/libgtmshr.so /usr/local/lib/
ldconfig
#base=~/qewd
base=/opt/qewd
[ -f "$GTMCI" ] || export GTMCI="$(find $base -iname nodem.ci)"
export ydb_ci="$(find $base -iname nodem.ci)"
nodemgtmr="$(find $base -iname v4wnode.m | tail -n1 | xargs dirname)"
echo "$gtmroutines" | fgrep "$nodemgtmr" || export gtmroutines="$nodemgtmr $gtmroutines"

#echo 'base=~/qewd' >> ~/.profile
echo 'base=/opt/qewd' >> ~/.profile
echo '[ -f "$GTMCI" ] || export GTMCI="$(find $base -iname nodem.ci)"' >> ~/.profile
echo 'export ydb_ci="$(find $base -iname nodem.ci)"' >> ~/.profile
echo 'nodemgtmr="$(find $base -iname v4wnode.m | tail -n1 | xargs dirname)"' >> ~/.profile
echo 'echo "$gtmroutines" | fgrep "$nodemgtmr" || export gtmroutines="$nodemgtmr $gtmroutines"' >> ~/.profile
