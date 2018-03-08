echo "=================================================================="
echo "CRYPTOSH Protoncoin MN Install"
echo "=================================================================="

#read -p 'Enter your masternode genkey you created in windows, then hit [ENTER]: ' GENKEY

echo -n "Installing pwgen..."
sudo apt-get install -y pwgen

echo -n "Installing dns utils..."
sudo apt-get install -y dnsutils

PASSWORD="protoncoin@passwd"
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

wget https://github.com/protoncoin/protoncoin/releases/download/v1.0.4/protoncoin-linux64-v1.0.4.tar.gz

tar -zxvf protoncoin-linux64-v1.0.4.tar.gz -C proton-1.0.4
sudo cp proton-1.0.4/protond /usr/local/bin/
sudo cp proton-1.0.4/proton-cli /usr/local/bin/

echo "Loading wallet, 30 seconds wait..."
protond --daemon
sleep 30

cat <<EOF > ~/.protoncore/proton.conf
rpcuser=protoncoin
rpcpassword=3a76std7sa6da8sfd8
EOF

echo "RELOADING WALLET..."
protond --daemon
sleep 10

echo "making genkey..."
GENKEY=$(proton-cli masternode genkey)

echo "mining info..."
proton-cli getmininginfo
proton-cli stop

echo "creating final config..."

cat <<EOF > ~/.protoncore/proton.conf

rpcuser=protoncoin
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
server=1
daemon=1
listenonion=0
listen=1
staking=0
rpcport=17866
port=17817
masternode=1
masternodeaddr=$WANIP:17817
masternodeprivkey=$GENKEY

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
sudo ufw allow 17866/tcp
sudo ufw allow 17817/tcp
sudo ufw logging on
sudo ufw status
echo y | sudo ufw enable
echo "basic security completed..."

echo "restarting wallet with new configs, 30 seconds..."
protond --daemon
sleep 30




echo "Installing sentinel..."
cd /root/.protoncore

sudo git clone https://github.com/protoncoin/proton_sentinel.git

cd proton_sentinel


virtualenv ./venv
./venv/bin/pip install -r requirements.txt

echo "proton_conf=/root/.protoncore/proton.conf" >> /root/.protoncore/proton_sentinel/sentinel.conf

crontab -l > proton
#echo new cron into cron file
echo "* * * * * cd /root/.protoncore/proton_sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1" >> proton
#install new cron file
crontab proton
rm proton

SENTINEL_DEBUG=1 ./venv/bin/python bin/sentinel.py
echo "Sentinel Installed"


echo "proton-cli getmininginfo:"
proton-cli getmininginfo

echo "masternode status:"
proton-cli masternode status

echo "INSTALLED WITH VPS IP: $WANIP:17817"
sleep 1
echo "INSTALLED WITH GENKEY: $GENKEY"
sleep 1
echo "rpcuser=protoncoin\nrpcpassword=$PASSWORD"