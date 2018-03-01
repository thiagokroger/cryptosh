echo "=================================================================="
echo "CRYPTOSH ZEX MN Install"
echo "=================================================================="
echo "Installing, and will take up to 3 min to run..."
#read -p 'Enter your masternode genkey you created in windows, then hit [ENTER]: ' GENKEY

echo -n "Installing pwgen..."
sudo apt-get install -y pwgen

echo -n "Installing dns utils..."
sudo apt-get install -y dnsutils

PASSWORD="zexcoin@passwd"
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
sudo apt-get install git nano rpl wget python-virtualenv -qq -y > /dev/null 2>&1
sudo apt-get install build-essential libtool automake autoconf -qq -y > /dev/null 2>&1
sudo apt-get install autotools-dev autoconf pkg-config libssl-dev -qq -y > /dev/null 2>&1
sudo apt-get install libgmp3-dev libevent-dev bsdmainutils libboost-all-dev -qq -y > /dev/null 2>&1
sudo apt-get install software-properties-common python-software-properties -qq -y > /dev/null 2>&1
sudo add-apt-repository ppa:bitcoin/bitcoin -y > /dev/null 2>&1
sudo apt-get update -qq -y > /dev/null 2>&1
sudo apt-get install libdb4.8-dev libdb4.8++-dev -qq -y > /dev/null 2>&1
sudo apt-get install libminiupnpc-dev -qq -y > /dev/null 2>&1
sudo apt-get install libzmq5 -qq -y > /dev/null 2>&1
sudo apt-get update
sudo apt-get -y install python-virtualenv
sudo apt-get -y install virtualenv

echo "Packages complete..."


echo "Downloading wallet"

wget https://github.com/thiagokroger/cryptosh/raw/master/compiled/zexcoin.tar.gz

tar -zxvf zexcoin.tar.gz
sudo cp zexcoin/zexcoind /usr/local/bin/
sudo cp zexcoin/zexcoin-cli /usr/local/bin/

echo "Loading wallet, 30 seconds wait..."
zexcoind --daemon
sleep 30

zexcoin-cli stop
sleep 10
cat <<EOF > ~/.zexcoincore/zexcoin.conf
rpcuser=zexcoin
rpcpassword=3a76std7sa6da8sfd8
EOF

echo "RELOADING WALLET..."
zexcoind --daemon
sleep 10

echo "making genkey..."
GENKEY=$(zexcoin-cli masternode genkey)

echo "mining info..."
zexcoin-cli getmininginfo
zexcoin-cli stop
sleep 10

echo "creating final config..."

cat <<EOF > ~/.zexcoincore/zexcoin.conf

rpcuser=zexcoin
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
rpcport=7737
server=1
daemon=1
listenonion=0
listen=1
staking=0
port=7736
masternode=1
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
sudo ufw allow 7737/tcp
sudo ufw allow 7736/tcp
sudo ufw logging on
sudo ufw status
sudo ufw enable
echo "basic security completed..."

echo "restarting wallet with new configs, 30 seconds..."
echo "forcing stop..."
zexcoin-cli stop
sleep 10
zexcoind --daemon
sleep 60




echo "Installing sentinel..."
cd /root/.zexcoincore

wget https://github.com/thiagokroger/cryptosh/raw/master/sentinel/zexcoin/sentinel.tar.gz

tar -zxvf sentinel.tar.gz && cd sentinel


virtualenv ./venv
./venv/bin/pip install -r requirements.txt

crontab -l > zex
#echo new cron into cron file
echo "* * * * * cd /root/.zexcoincore && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1" >> zex
#install new cron file
crontab zex
rm zex

SENTINEL_DEBUG=1 ./venv/bin/python bin/sentinel.py
echo "Sentinel Installed"



echo "zexcoin-cli getmininginfo:"
zexcoin-cli getmininginfo

echo "masternode status:"
zexcoin-cli masternode status

echo "INSTALLED WITH VPS IP: $WANIP:7736"
sleep 1
echo "INSTALLED WITH GENKEY: $GENKEY"
sleep 1
echo "rpcuser=zexcoin\nrpcpassword=$PASSWORD"