#!/bin/sh
cd ~
pwd=`pwd`
if [ ! -d "${pwd}/MQTT" ]; then
pip install paho-mqtt pyyaml fastapi uvicorn --break-system-package
rm  -rf *
mkdir Desktop
mkdir MQTT 
fi

if [ ! -e "/etc/network/interfaces.d/eth0" ]; then
sudo bash<<!
echo "auto eth0" >> /etc/network/interfaces.d/eth0
echo "iface eth0 inet static" >> /etc/network/interfaces.d/eth0
echo "address 192.168.1.254/16">> /etc/network/interfaces.d/eth0
echo "gateway 192.168.1.1">> /etc/network/interfaces.d/eth0
echo "metric 800" >>  /etc/network/interfaces.d/eth0

echo "FallbackNTP=10.136.156.1" >> /etc/systemd/timesyncd.conf

rm -rf /etc/rc.local 
echo '#!/bin/sh -e' >> /etc/rc.local
echo "sudo ifconfig wlan0 down" >> /etc/rc.local
echo "sudo ifconfig wlan0 hw ether e4:5f:01:f4:a9:fb" >> /etc/rc.local
echo "sudo ifconfig wlan0 up" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
chmod +x /etc/rc.local
exit
!




fi

sudo reboot 
fi

