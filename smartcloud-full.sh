
echo "=================================================================="
echo "Smrtc MN Install"
echo "=================================================================="

echo -n "Installing pwgen..."
sudo apt-get update
sudo apt-get install -y pwgen

echo -n "Installing dns utils..."
sudo apt-get install -y dnsutils

PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w20 | head -n1)
WANIP=$(dig +short myip.opendns.com @resolver1.opendns.com)

#begin optional swap section
echo "Setting up disk swap..."
free -h
sudo fallocate -l 4G /swapfile
ls -lh /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab sudo bash -c "
echo 'vm.swappiness = 10' >> /etc/sysctl.conf"
free -h
echo "SWAP setup complete..."
#end optional swap section

echo "Installing packages and updates..."

sudo apt-get install git -y
sudo apt-get install nano -y
sudo apt-get install libtool -y
sudo apt-get install autotools-dev pkg-config libssl-dev -y
sudo apt-get install libgmp3-dev libevent-dev bsdmainutils libboost-all-dev -y
sudo apt-get install libzmq3-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo apt-get install libdb5.3-dev libdb5.3++-dev -y

echo "Packages complete..."

cd ~
rm -rdf smrtc
mkdir smrtc
cd smrtc
wget https://github.com/telostia/smartcloud-guides/releases/download/0.001/smrtc-linux.tar.gz
tar -xvf smrtc-linux.tar.gz
rm smrtc-linux.tar.gz
chmod +x smrtc*
cp smrtc* /usr/local/bin

rm -rdf /root/.smrtc
mkdir /root/.smrtc

cat <<EOF > ~/.smrtc/smrtc.conf
rpcuser=smrtc
rpcpassword=3a76std7sa6da8sfd8
EOF

echo "LOADING WALLET..."
smrtcd --daemon
sleep 30

echo "making genkey..."
GENKEY=$(smrtc-cli masternode genkey)

smrtc-cli stop
sleep 30

echo "creating final config..."

cat <<EOF > ~/.smrtc/smrtc.conf
addnode=139.99.159.113
addnode=139.99.197.135
addnode=139.99.202.60
addnode=139.99.197.112
addnode=139.99.196.73
addnode=139.99.158.38
rpcuser=Smrtc
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
server=1
daemon=1
listenonion=0
listen=1
staking=0
port=9887
masternode=1
masternodeprivkey=$GENKEY

EOF

echo "LOADING WALLET..."
smrtcd --daemon
sleep 30


echo "mining info..."
smrtc-cli getmininginfo
smrtc-cli stop


echo "setting basic security..."
sudo apt-get install fail2ban -y
sudo apt-get install -y ufw

#fail2ban:
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

#add a firewall
sudo ufw allow 9887/tcp
echo y | sudo ufw enable
echo "basic security completed..."

echo "restarting wallet with new configs, 30 seconds..."
smrtcd --daemon
sleep 30


crontab -l > cronconfig
#echo new cron into cron file
echo "* * * * * smrtcd --daemon >/dev/null 2>&1" >> cronconfig
#install new cron file
crontab cronconfig
rm cronconfig

echo "smrtc-cli getmininginfo:"
smrtc-cli getmininginfo

echo "masternode status:"
echo "smrtc-cli masternode status"
smrtc-cli masternode status

echo "INSTALLED WITH VPS IP: $WANIP:9887"
sleep 1
echo "INSTALLED WITH GENKEY: $GENKEY"
sleep 1
echo "rpcuser=Smrtc\nrpcpassword=$PASSWORD"
