echo "=================================================================="
echo "CRYPTOSH DiscountCoin MN Install"
echo "=================================================================="

#read -p 'Enter your masternode genkey you created in windows, then hit [ENTER]: ' GENKEY

echo -n "Installing pwgen..."
sudo apt-get install -y pwgen

echo -n "Installing dns utils..."
sudo apt-get install -y dnsutils

PASSWORD="DiscountCoin@passwd"
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
sudo apt-get install build-essential libtool automake autoconf unzip -y
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

mkdir DiscountCoin
cd DiscountCoin
wget https://discountco.in/binaries/DiscountCoin-LinuxDaemon.zip
unzip DiscountCoin-LinuxDaemon.zip
sudo chmod 777 DiscountCoind
sudo cp DiscountCoind /usr/local/bin/discountcoind

echo "Loading wallet, 30 seconds wait..."
discountcoind --daemon
sleep 30
discountcoind stop
sleep 30
cat <<EOF > ~/.DiscountCoin/DiscountCoin.conf
rpcuser=DiscountCoin
rpcpassword=3a76std7sa6da8sfd8
EOF

echo "RELOADING WALLET..."
discountcoind --daemon
sleep 10

echo "making genkey..."
GENKEY=$(discountcoind masternode genkey)

echo "mining info..."
discountcoind getmininginfo
discountcoind stop

echo "creating final config..."

cat <<EOF > ~/.DiscountCoin/DiscountCoin.conf

rpcuser=DiscountCoin
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
server=1
daemon=1
listenonion=0
listen=1
staking=0
port=9448
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
sudo ufw allow 9448/tcp
sudo ufw logging on
sudo ufw status
echo y | sudo ufw enable
echo "basic security completed..."

echo "restarting wallet with new configs, 30 seconds..."
discountcoind --daemon
sleep 30


echo "discountcoind getmininginfo:"
discountcoind getmininginfo

echo "masternode status:"
discountcoind masternode status

echo "INSTALLED WITH VPS IP: $WANIP:9448"
sleep 1
echo "INSTALLED WITH GENKEY: $GENKEY"
sleep 1
echo "rpcuser=discountCoin\nrpcpassword=$PASSWORD"