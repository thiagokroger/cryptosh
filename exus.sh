echo "=================================================================="
echo "CRYPTOSH EXUS MN Install"
echo "=================================================================="

#read -p 'Enter your masternode genkey you created in windows, then hit [ENTER]: ' GENKEY

echo -n "Installing pwgen..."
sudo apt-get install -y pwgen

echo -n "Installing dns utils..."
sudo apt-get install -y dnsutils

PASSWORD="exus@passwd"
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

wget https://github.com/exuscoin/exus/releases/download/v1.0.0.4/exusd-1.0.0.4-ubuntu-16.04.tar.gz


tar -zxvf exusd-1.0.0.4-ubuntu-16.04.tar.gz
sudo cp exusd /usr/local/bin/

echo "Loading wallet, 30 seconds wait..."
exusd --daemon
sleep 30

cat <<EOF > ~/.exus/exus.conf
rpcuser=exus
rpcpassword=3a76std7sa6da8sfd8
EOF

echo "RELOADING WALLET..."
exusd --daemon
sleep 10

echo "making genkey..."
GENKEY=$(exusd masternode genkey)

echo "mining info..."
exusd getmininginfo
exusd stop

echo "creating final config..."

cat <<EOF > ~/.exus/exus.conf

rpcuser=exus
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
server=1
daemon=1
listenonion=0
listen=1
staking=0
port=15876
masternode=1
masternodeaddr=$WANIP:15876
masternodeprivkey=$GENKEY

EOF

echo "setting basic security..."
sudo apt-get install fail2ban -y
sudo apt-get install -y ufw
sudo apt-get update -y

#fail2ban:
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "restarting wallet with new configs, 30 seconds..."
exusd --daemon
sleep 30

echo "exusd getmininginfo:"
exusd getmininginfo

echo "masternode status:"
exusd masternode status

echo "INSTALLED WITH VPS IP: $WANIP:15876"
sleep 1
echo "INSTALLED WITH GENKEY: $GENKEY"
sleep 1
echo "rpcuser=exus\nrpcpassword=$PASSWORD"