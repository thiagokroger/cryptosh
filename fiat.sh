
echo "=================================================================="
echo "NodeCircle MN Install"
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
sudo apt-get install libgmp3-dev libevent-dev bsdmainutils libboost-all-dev libminiupnpc-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb5.3-dev libdb5.3++-dev -y

echo "Packages complete..."

sudo apt-get install fail2ban -y
sudo apt-get install -y ufw

sudo systemctl enable fail2ban
sudo systemctl start fail2ban

sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw logging on
sudo ufw status
echo y | sudo ufw enable
echo "basic security completed..."

echo "flat complete"
