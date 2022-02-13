#!/bin/bash
set echo off
cd ~
mkdir ~/opt/
mkdir ~/opt/jellyfin
cd ~/opt/jellyfin
wget https://repo.jellyfin.org/releases/server/linux/stable/combined/jellyfin_10.7.7_amd64.tar.gz
tar xvzf jellyfin_10.7.7_amd64.tar.gz
ln -s jellyfin_10.7.7 jellyfin
mkdir data cache config log
cd ~
JELLYFINDIR=$(pwd)"/opt/jellyfin"
FFMPEGDIR="/usr/bin"
screen -S Jellyinstall -d -m $JELLYFINDIR/jellyfin/jellyfin \
-d $JELLYFINDIR/data \
-C $JELLYFINDIR/cache \
-c $JELLYFINDIR/config \
-l $JELLYFINDIR/log \
--ffmpeg $FFMPEGDIR/ffmpeg
clear
echo starting setup please wait
sleep 5
screen -X -S Jellyinstall kill
cd $JELLYFINDIR/config
cp system.xml system.bak
cp network.xml network.bak
http=$(shuf -i 8000-8999 -n1)
https=$(( http + 1 ))
sed -i "s/8096/$http/g" system.xml
sed -i "s/8920/$https/g" system.xml
sed -i "s/8096/$http/g" network.xml
sed -i "s/8920/$https/g" network.xml
cd ~
touch ~/start_jelly.sh
cat > ~/start_jelly.sh <<'EOF1'
#!/bin/bash
JELLYFINDIR=$(pwd)"/opt/jellyfin"
FFMPEGDIR="/usr/bin"
Jellyport=$(awk '{if(/<PublicPort>/) print substr($1,13,4)}' < ./opt/jellyfin/config/system.xml)
echo "starting Jellyfin - usage ~/stop_jelly.sh to stop jellyfin -  ~/start_jelly.sh to start"
echo -e "\nhttp://$(hostname -f):$Jellyport"
screen -S Jellyfin -d -m $JELLYFINDIR/jellyfin/jellyfin \
-d $JELLYFINDIR/data \
-C $JELLYFINDIR/cache \
-c $JELLYFINDIR/config \
-l $JELLYFINDIR/log \
--ffmpeg $FFMPEGDIR/ffmpeg
EOF1
chmod +x ~/start_jelly.sh
cat > ~/stop_jelly.sh <<'EOF2'
#!/bin/bash
screen -X -S Jellyfin kill
sleep 2
echo "stopped"
EOF2
chmod +x ~/stop_jelly.sh
~/start_jelly.sh to start
