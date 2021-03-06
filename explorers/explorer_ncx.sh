
echo "=================================================================="
echo "CRYPTOSH NodeCircle MN Install"
echo "=================================================================="

#read -p 'Enter your masternode genkey you created in windows, then hit [ENTER]: ' GENKEY

echo -n "Installing pwgen..."
sudo apt-get install -y pwgen

echo -n "Installing dns utils..."
sudo apt-get install -y dnsutils


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
sudo apt-get install libminiupnpc-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

wget https://github.com/nodecircle/NodeCircle/releases/download/v1.0.0/nodecircle-1.0.0-x86_64-linux-gnu.tar.gz

mkdir nodecircle-1.0.0
tar -zxvf nodecircle-1.0.0-x86_64-linux-gnu.tar.gz
sudo rm -rf /usr/local/bin/nodecircle-cli
sudo rm -rf /usr/local/bin/nodecircled
sudo cp nodecircle-1.0.0/bin/nodecircle-cli /usr/local/bin/
sudo cp nodecircle-1.0.0/bin/nodecircled /usr/local/bin/

rm -rdf /root/.nodecircle
mkdir /root/.nodecircle

echo "creating final config..."

cat <<EOF > ~/.nodecircle/nodecircle.conf

server=1
listen=1
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
rpcallowip=127.0.0.1
rpcuser=local
rpcpassword=local@123
rpcport=18774

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
sudo ufw allow 18775/tcp
sudo ufw allow 18774/tcp
sudo ufw allow 3001/tcp
sudo ufw allow 80/tcp
sudo ufw logging on
sudo ufw status
echo y | sudo ufw enable
echo "basic security completed..."

echo "restarting wallet with new configs, 30 seconds..."
nodecircled --daemon
sleep 30


echo "nodecircle-cli getinfo"
nodecircle-cli getinfo

*/1 * * * * cd /root/newexplorer/explorer && /usr/bin/nodejs scripts/sync.js index update > /dev/null 2>&1
*/2 * * * * cd /root/newexplorer/explorer && /usr/bin/nodejs scripts/sync.js market > /dev/null 2>&1
*/5 * * * * cd /root/newexplorer/explorer && /usr/bin/nodejs scripts/peers.js > /dev/null 2>&1
