#!/bin/sh
cd ~
pwd=`pwd`
if [ ! -d "${pwd}/MQTT" ]; then
sudo apt install nmap -y
pip install paho-mqtt==1.6.1 pyyaml fastapi uvicorn --break-system-package
rm  -rf *
mkdir Desktop
mkdir MQTT 
fi
wget https://raw.githubusercontent.com/joshchunghung/bgtest/main/checkconnect.py -O ${pwd}/MQTT/checkconnect.py
wget https://raw.githubusercontent.com/joshchunghung/bgtest/main/getYML.py -O ${pwd}/MQTT/getYML.py
if [ ! -e "/etc/network/interfaces.d/eth0" ]; then
sudo bash<<!

apt install nmap -y

echo "auto eth0" >> /etc/network/interfaces.d/eth0
echo "iface eth0 inet static" >> /etc/network/interfaces.d/eth0
echo "address 192.168.1.254/16">> /etc/network/interfaces.d/eth0
echo "gateway 192.168.1.1">> /etc/network/interfaces.d/eth0
echo "metric 800" >>  /etc/network/interfaces.d/eth0

echo "FallbackNTP=10.136.156.2" >> /etc/systemd/timesyncd.conf


echo "[Unit]" > /etc/systemd/system/piconnect.service
echo "Description= Pi connect " >> /etc/systemd/system/piconnect.service
echo "After=network.target" >> /etc/systemd/system/piconnect.service

echo "[Service]" >> /etc/systemd/system/piconnect.service
echo "User=pi" >> /etc/systemd/system/piconnect.service
echo "WorkingDirectory=/home/pi/MQTT" >> /etc/systemd/system/piconnect.service
echo "ExecStart=/usr/bin/python /home/pi/MQTT/checkconnect.py" >> /etc/systemd/system/piconnect.service
echo "Restart=on-failure" >> /etc/systemd/system/piconnect.service
echo "RestartSec=5s" >> /etc/systemd/system/piconnect.service

echo "[Install]" >> /etc/systemd/system/piconnect.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/piconnect.service

##
echo "[Unit]" > /etc/systemd/system/api.service 
echo "Description=api" >>/etc/systemd/system/api.service 
echo "After=network.target" >>/etc/systemd/system/api.service 

echo "[Service]" >>/etc/systemd/system/api.service 
echo "User=pi" >>/etc/systemd/system/api.service 
echo "WorkingDirectory=/home/pi/MQTT" >>/etc/systemd/system/api.service 
echo "LimitNOFILE=4096" >>/etc/systemd/system/api.service 
echo "ExecStart=/home/pi/.local/bin/uvicorn main:app  --host 0.0.0.0 --port 8000" >>/etc/systemd/system/api.service 
echo "Restart=on-failure" >>/etc/systemd/system/api.service 
echo "RestartSec=5s" >>/etc/systemd/system/api.service 

echo "[Install]" >>/etc/systemd/system/api.service 
echo "WantedBy=multi-user.target" >>/etc/systemd/system/api.service 


echo "[Unit]" > /etc/systemd/system/testSocket.service
echo "Description= Pi connect" >> /etc/systemd/system/testSocket.service 
echo "After=network.target" >> /etc/systemd/system/testSocket.service 

echo "[Service]" >> /etc/systemd/system/testSocket.service 
echo "User=pi" >> /etc/systemd/system/testSocket.service 
echo "WorkingDirectory=/home/pi/MQTT" >> /etc/systemd/system/testSocket.service 
echo "ExecStart=/usr/bin/python /home/pi/MQTT/getData.py" >> /etc/systemd/system/testSocket.service 
echo "Restart=on-failure" >> /etc/systemd/system/testSocket.service 
echo "RestartSec=5s" >> /etc/systemd/system/testSocket.service 

echo "[Install]" >> /etc/systemd/system/testSocket.service 
echo "WantedBy=multi-user.target" >> /etc/systemd/system/testSocket.service 


exit
!

fi
sudo chmod 644 /etc/systemd/system/piconnect.service
sudo systemctl daemon-reload
sudo systemctl start  piconnect.service
sudo systemctl enable piconnect.service
sudo chmod 644 /etc/systemd/system/testSocket.service
sudo systemctl daemon-reload
sudo systemctl start  testSocket.service
sudo systemctl enable testSocket.service

(crontab -l ; echo "@reboot sleep 30;python /home/pi/MQTT/getYML.py") | crontab
(crontab -l ; echo "0 * * * * sudo systemctl restart testSocket.service") | crontab
sudo shutdown now
fi




