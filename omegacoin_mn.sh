echo "=================================================================="
echo "PARANOID TRUTH OMEGA MN Install"
echo "=================================================================="
echo "Installing, and will take up to 3 min to run..."
#read -p 'Enter your masternode genkey you created in windows, then hit [ENTER]: ' GENKEY

echo -n "Installing pwgen..."
sudo apt-get install -y pwgen 

echo -n "Installing dns utils..."
sudo apt-get install -y dnsutils

PASSWORD="omega@passwd"
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

wget https://github.com/omegacoinnetwork/omegacoin/releases/download/0.12.5/omegacoincore-0.12.5-linux64.tar.gz

tar -zxvf omegacoincore-0.12.5-linux64.tar.gz
sudo cp omegacoincore-0.12.2/bin/omegacoind /usr/local/bin/
sudo cp omegacoincore-0.12.2/bin/omegacoin-cli /usr/local/bin/

echo "Loading wallet, 30 seconds wait..." 
omegacoind --daemon
sleep 30

cat <<EOF > ~/.omegacoincore/omegacoin.conf
rpcuser=omegacoin
EOF

echo "RELOADING WALLET..."
omegacoind --daemon
sleep 10

echo "making genkey..."
GENKEY=$(omegacoin-cli masternode genkey)

echo "mining info..."
omegacoin-cli getmininginfo
omegacoin-cli stop

echo "creating final config..." 

cat <<EOF > ~/.omegacoincore/omegacoin.conf

rpcuser=omegacoin
rpcpassword=$PASSWORD
rpcport=7778
rpcallowip=127.0.0.1
server=1
daemon=1
listenonion=0
addnode=142.208.127.121
addnode=154.208.127.121
addnode=142.208.122.127
listen=1
staking=0
port=7777
masternode=1
masternodeaddr=$WANIP:7777
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
sudo ufw allow 7778/tcp 
sudo ufw allow 7777/tcp
sudo ufw logging on 
sudo ufw status
sudo ufw enable
echo "basic security completed..."

echo "restarting wallet with new configs, 30 seconds..."
omegacoind --daemon
sleep 30

echo "omegacoin-cli getmininginfo:"
omegacoin-cli getmininginfo

echo "masternode status:"
omegacoin-cli masternode status

echo "INSTALLED WITH VPS IP: $WANIP:7777"
sleep 1
echo "INSTALLED WITH GENKEY: $GENKEY"
sleep 1
echo "rpcuser=omegacoin\nrpcpassword=$PASSWORD"