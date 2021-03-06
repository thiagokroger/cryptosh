echo "=================================================================="
echo "Cryptosh NORTHERN MN Install"
echo "=================================================================="
echo "Installing, and will take up to 3 min to run..."
#read -p 'Enter your masternode genkey you created in windows, then hit [ENTER]: ' GENKEY

echo -n "Installing pwgen..."
sudo apt-get install -y pwgen

echo -n "Installing dns utils..."
sudo apt-get install -y dnsutils

PASSWORD="northern@passwd"
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

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install git -y
sudo apt-get install nano -y
sudo apt-get install build-essential libtool automake autoconf -y
sudo apt-get install autotools-dev autoconf pkg-config libssl-dev -y
sudo apt-get install libgmp3-dev libevent-dev bsdmainutils libboost-all-dev -y
sudo apt-get install libzmq3-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo apt-get install libdb5.3-dev libdb5.3++-dev -y

echo "Packages complete..."

rm -rf northern-1.0.0-x86_64-linux-gnu.tar.gz
rm -rdf /root/.northern
northern-cli stop
sleep 30
sudo rm -rf /usr/local/bin/northernd
sudo rm -rf /usr/local/bin/northern-cli

wget https://github.com/zabtc/Northern/releases/download/1.0.0/northern-1.0.0-x86_64-linux-gnu.tar.gz

tar -zxvf northern-1.0.0-x86_64-linux-gnu.tar.gz
sudo cp northernd /usr/local/bin/
sudo cp northern-cli /usr/local/bin/

echo "Loading wallet, 30 seconds wait..."
northernd --daemon
sleep 30
northern-cli stop
sleep 30
cat <<EOF > ~/.northern/northern.conf
rpcuser=northern
rpcpassword=3a76std7sa6da8sfd8
EOF

echo "RELOADING WALLET..."
northernd --daemon
sleep 10

echo "making genkey..."
GENKEY=$(northern-cli masternode genkey)

echo "mining info..."
northern-cli getmininginfo
northern-cli stop

echo "creating final config..."

cat <<EOF > ~/.northern/northern.conf

rpcuser=northern
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
server=1
daemon=1
listenonion=0
listen=1
staking=0
port=60151
masternode=1
masternodeaddr=$WANIP:60151
masternodeprivkey=$GENKEY
addnode=207.246.69.246
addnode=209.250.233.104
addnode=45.77.82.101
addnode=138.68.167.127
addnode=45.77.218.53
addnode=207.246.86.118
addnode=128.199.44.28
addnode=139.59.164.167
addnode=139.59.177.56
addnode=206.189.58.89
addnode=207.154.202.113
addnode=140.82.54.227


EOF

echo "setting basic security..."
sudo apt-get install fail2ban -y
sudo apt-get install -y ufw
sudo apt-get update -y

#fail2ban:
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

#add a firewall
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 60151/tcp
sudo ufw logging on
sudo ufw status
echo y | sudo ufw enable
echo "basic security completed..."

echo "restarting wallet with new configs, 30 seconds..."
northernd --daemon
sleep 30

echo "northern-cli getmininginfo:"
northern-cli getmininginfo

echo "masternode status:"
northern-cli masternode status

echo "INSTALLED WITH VPS IP: $WANIP:60151"
sleep 1
echo "INSTALLED WITH GENKEY: $GENKEY"
sleep 1
echo "rpcuser=northern\nrpcpassword=$PASSWORD"
